import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../admin/data/admin_repository.dart';
import '../../../admin/domain/admin_models.dart';
import '../../../student/domain/models/student_models.dart';

/// What the attendance screen last did, so the UI can show the undo/adjust
/// banner without keeping duplicate state in the widget.
enum AttendanceEventKind { registered, removed, failed, duplicate }

class AttendanceEvent {
  const AttendanceEvent({
    required this.kind,
    required this.studentId,
    required this.studentName,
    this.time,
    this.message,
  });

  final AttendanceEventKind kind;
  final int studentId;
  final String studentName;
  final DateTime? time;
  final String? message;
}

class SessionAttendanceState {
  const SessionAttendanceState({
    this.loading = true,
    this.session,
    this.members = const [],
    this.attendance = const [],
    this.registered = const {},
    this.pending = const {},
    this.scanning = false,
    this.query = '',
    this.filter,
    this.error,
    this.lastScan,
    this.lastScanOk = true,
    this.event,
    this.eventId = 0,
  });

  final bool loading;
  final AdminSessionRow? session;
  final List<AdminSessionMember> members;
  final List<AdminAttendanceRow> attendance;
  final Map<int, DateTime> registered;
  final Set<int> pending;
  final bool scanning;
  final String query;
  final String? filter;
  final Object? error;
  final String? lastScan;
  final bool lastScanOk;
  final AttendanceEvent? event;
  final int eventId;

  bool get isReady => session != null && !loading && error == null;

  /// Roster fallback when the server has no course roster yet: the students
  /// already scanned in this session still need to be visible.
  List<AdminSessionMember> get roster {
    if (members.isNotEmpty) return members;
    return [
      for (final row in attendance)
        AdminSessionMember(
          studentId: row.studentId,
          name: row.name,
          arrivalTime: row.arrivalTime,
        ),
    ];
  }

  AttendanceCategory? categoryOf(int studentId) {
    for (final row in attendance) {
      if (row.studentId == studentId) return row.category;
    }
    return null;
  }

  bool matchesFilter(AdminSessionMember member) {
    switch (filter) {
      case 'مبكر':
        return categoryOf(member.studentId) == AttendanceCategory.early;
      case 'في الوقت':
        return categoryOf(member.studentId) == AttendanceCategory.onTime;
      case 'متأخر':
        return categoryOf(member.studentId) == AttendanceCategory.late;
      case 'غائب':
        return !registered.containsKey(member.studentId);
      default:
        return true;
    }
  }

  List<AdminSessionMember> get visible {
    final q = query.trim().toLowerCase();
    return [
      for (final member in roster)
        if ((q.isEmpty ||
                member.name.toLowerCase().contains(q) ||
                member.barcode.toLowerCase().contains(q) ||
                member.studentId.toString().contains(q)) &&
            matchesFilter(member))
          member,
    ];
  }

  SessionAttendanceState copyWith({
    bool? loading,
    AdminSessionRow? session,
    List<AdminSessionMember>? members,
    List<AdminAttendanceRow>? attendance,
    Map<int, DateTime>? registered,
    Set<int>? pending,
    bool? scanning,
    String? query,
    String? filter,
    bool clearFilter = false,
    Object? error,
    bool clearError = false,
    String? lastScan,
    bool? lastScanOk,
    AttendanceEvent? event,
    int? eventId,
  }) {
    return SessionAttendanceState(
      loading: loading ?? this.loading,
      session: session ?? this.session,
      members: members ?? this.members,
      attendance: attendance ?? this.attendance,
      registered: registered ?? this.registered,
      pending: pending ?? this.pending,
      scanning: scanning ?? this.scanning,
      query: query ?? this.query,
      filter: clearFilter ? null : (filter ?? this.filter),
      error: clearError ? null : (error ?? this.error),
      lastScan: lastScan ?? this.lastScan,
      lastScanOk: lastScanOk ?? this.lastScanOk,
      event: event ?? this.event,
      eventId: eventId ?? this.eventId,
    );
  }
}

/// Owns the attendance screen state: roster, registered map, per-student
/// pending operations, scanning and the transient undo event.
class SessionAttendanceCubit extends Cubit<SessionAttendanceState> {
  SessionAttendanceCubit(this._repository, {required this.sessionId})
    : super(const SessionAttendanceState());

  final AdminRepository _repository;
  final int sessionId;
  int _eventId = 0;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final results = await Future.wait<Object>([
        _repository.sessionRow(sessionId),
        _repository.sessionMembers(sessionId),
        _repository.sessionAttendance(sessionId),
      ]);
      final session = results[0] as AdminSessionRow;
      final members = results[1] as List<AdminSessionMember>;
      final attendance = results[2] as List<AdminAttendanceRow>;
      final registered = <int, DateTime>{
        for (final row in attendance)
          if (row.arrivalTime != null) row.studentId: row.arrivalTime!,
      };
      emit(
        SessionAttendanceState(
          loading: false,
          session: session,
          members: members,
          attendance: attendance,
          registered: registered,
        ),
      );
    } catch (error) {
      emit(state.copyWith(loading: false, error: error));
    }
  }

  void setQuery(String value) => emit(state.copyWith(query: value));

  void setFilter(String? value) => emit(
    value == null
        ? state.copyWith(clearFilter: true)
        : state.copyWith(filter: value),
  );

  Future<void> register(
    AdminSessionMember member, {
    DateTime? at,
    bool silent = false,
  }) async {
    final current = state;
    if (!current.isReady || current.pending.contains(member.studentId)) return;
    final previous = current.registered[member.studentId];
    emit(
      current.copyWith(
        pending: {...current.pending, member.studentId},
        clearError: true,
      ),
    );
    final time = at ?? DateTime.now();
    try {
      if (previous == null) {
        await _repository.addManualAttendance(
          sessionId,
          member.studentId,
          time: time,
        );
      } else {
        await _repository.updateAttendanceTime(
          sessionId,
          member.studentId,
          time,
        );
      }
      _emitRegistered(member, time, silent: silent);
    } on ApiException catch (error) {
      if (error.code == 'E14') {
        // Already registered on the server (double tap / retry): treat as a
        // successful no-op instead of showing an error.
        _emitRegistered(member, time, silent: true);
      } else {
        _emitFailure(member, error);
      }
    } catch (error) {
      _emitFailure(member, error);
    }
  }

  Future<void> handleScan(String code) async {
    final value = code.trim();
    final current = state;
    if (value.isEmpty || current.scanning || !current.isReady) return;
    emit(current.copyWith(scanning: true, clearError: true));
    try {
      final result = await _repository.addAttendanceByBarcode(sessionId, value);
      if (result == null) {
        _emitScanFailure(value);
        return;
      }
      final time = DateTime.now();
      final member = current.roster
          .where((m) => m.studentId == result.studentId)
          .firstOrNull;
      final resolved =
          member ??
          AdminSessionMember(studentId: result.studentId, name: result.name);
      final eventId = ++_eventId;
      emit(
        state.copyWith(
          scanning: false,
          registered: {...state.registered, result.studentId: time},
          lastScan: result.name,
          lastScanOk: true,
          event: AttendanceEvent(
            kind: result.created
                ? AttendanceEventKind.registered
                : AttendanceEventKind.duplicate,
            studentId: result.studentId,
            studentName: result.name,
            time: time,
          ),
          eventId: eventId,
        ),
      );
      // Keep the roster row visible for first-session scans.
      if (!state.members.any((m) => m.studentId == resolved.studentId)) {
        emit(state.copyWith(members: [...state.members, resolved]));
      }
    } catch (error) {
      _emitScanFailure(value, error: error);
    }
  }

  Future<void> undo(int studentId, {DateTime? previousTime}) async {
    final current = state;
    if (!current.isReady || current.pending.contains(studentId)) return;
    final member = current.roster
        .where((m) => m.studentId == studentId)
        .firstOrNull;
    if (member == null) return;
    final time = previousTime ?? current.registered[studentId];
    emit(current.copyWith(pending: {...current.pending, studentId}));
    try {
      await _repository.removeAttendance(sessionId, studentId);
      final next = {...state.registered}..remove(studentId);
      emit(
        state.copyWith(
          registered: next,
          pending: {...state.pending}..remove(studentId),
          event: AttendanceEvent(
            kind: AttendanceEventKind.removed,
            studentId: studentId,
            studentName: member.name,
            time: time,
          ),
          eventId: ++_eventId,
        ),
      );
    } catch (error) {
      _emitFailure(member, error);
    }
  }

  Future<void> adjustTime(AdminSessionMember member, DateTime time) async {
    final current = state;
    if (!current.isReady || current.pending.contains(member.studentId)) return;
    final previous = current.registered[member.studentId];
    emit(current.copyWith(pending: {...current.pending, member.studentId}));
    try {
      if (previous == null) {
        await _repository.addManualAttendance(
          sessionId,
          member.studentId,
          time: time,
        );
      } else {
        await _repository.updateAttendanceTime(
          sessionId,
          member.studentId,
          time,
        );
      }
      _emitRegistered(member, time);
    } catch (error) {
      _emitFailure(member, error);
    }
  }

  Future<void> remove(AdminSessionMember member) async {
    final current = state;
    if (!current.isReady || current.pending.contains(member.studentId)) return;
    final previous = current.registered[member.studentId];
    emit(current.copyWith(pending: {...current.pending, member.studentId}));
    try {
      await _repository.removeAttendance(sessionId, member.studentId);
      final next = {...state.registered}..remove(member.studentId);
      emit(
        state.copyWith(
          registered: next,
          pending: {...state.pending}..remove(member.studentId),
          event: AttendanceEvent(
            kind: AttendanceEventKind.removed,
            studentId: member.studentId,
            studentName: member.name,
            time: previous,
          ),
          eventId: ++_eventId,
        ),
      );
    } catch (error) {
      _emitFailure(member, error);
    }
  }

  void clearScan() {
    if (!state.isReady || state.scanning) return;
    emit(state.copyWith(lastScan: ''));
  }

  void _emitRegistered(
    AdminSessionMember member,
    DateTime time, {
    bool silent = false,
  }) {
    final eventId = _eventId + 1;
    emit(
      state.copyWith(
        registered: {...state.registered, member.studentId: time},
        pending: {...state.pending}..remove(member.studentId),
        event: silent
            ? null
            : AttendanceEvent(
                kind: AttendanceEventKind.registered,
                studentId: member.studentId,
                studentName: member.name,
                time: time,
              ),
        eventId: eventId,
        clearError: true,
      ),
    );
    if (!silent) _eventId = eventId;
  }

  void _emitFailure(AdminSessionMember member, Object error) {
    emit(
      state.copyWith(
        pending: {...state.pending}..remove(member.studentId),
        event: AttendanceEvent(
          kind: AttendanceEventKind.failed,
          studentId: member.studentId,
          studentName: member.name,
          message: error is ApiException
              ? error.message()
              : 'تعذر تسجيل الحضور',
        ),
        eventId: ++_eventId,
      ),
    );
  }

  void _emitScanFailure(String code, {Object? error}) {
    emit(
      state.copyWith(
        scanning: false,
        lastScan: code,
        lastScanOk: false,
        event: AttendanceEvent(
          kind: AttendanceEventKind.failed,
          studentId: 0,
          studentName: code,
          message: error is ApiException
              ? error.message()
              : 'لا يوجد طالب بهذا الباركود',
        ),
        eventId: ++_eventId,
      ),
    );
  }
}
