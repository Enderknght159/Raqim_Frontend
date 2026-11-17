import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/section_loader.dart';
import '../../../../core/storage/screen_cache.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../shared/permissions.dart';
import '../../../admin/data/admin_repository.dart';
import '../../../admin/domain/admin_models.dart';
import '../../../admin/presentation/admin_shell.dart';
import '../../../admin/presentation/screens/record_entry_sheet.dart';
import '../../data/teacher_roster_service.dart';
import '../../domain/teacher_models.dart';
import '../widgets/teacher_roster_row.dart';
import '../widgets/teacher_session_picker.dart';
import '../widgets/teacher_session_records_sheet.dart';
import '../widgets/teacher_student_actions_sheet.dart';

/// Teacher home: course → session → my students → records.
///
/// The shell (session card, summary, bulk actions, filters) paints as soon as
/// the roster is known; the selected-session data then fills in through two
/// independent [AsyncSection]s, so a slow attendance or records query never
/// hides the other one:
///
/// * `teacher-today-attendance-<sessionId>` — the roster rows + attendance.
/// * `teacher-today-records-<sessionId>` — the session summary chips, driven by
///   the records request (kept above the fold so «متبقّون» and the row strips
///   are correct without scrolling).
///
/// Both requests are filtered to the teacher's roster ids, and their joined
/// maps live in state so a toggle repaints the row immediately instead of
/// waiting for the section to revalidate.
class TeacherTodayScreen extends StatefulWidget {
  const TeacherTodayScreen({super.key});

  @override
  State<TeacherTodayScreen> createState() => _TeacherTodayScreenState();
}

class _TeacherTodayScreenState extends State<TeacherTodayScreen> {
  /// Session-only key: survives tab switches, cleared when the account changes
  /// (the auth cubit clears [ScreenCache]).
  static const String _selectionCacheKey = 'teacher-today-selection';

  TeacherSessionSelection? _selection;

  /// Page-level: bulk actions, filters, the picker and the row summaries all
  /// depend on it, so it is loaded once for the page.
  List<TeacherRosterEntry> _roster = const [];

  /// Roster-scoped joins of the two session requests below.
  Map<int, AdminAttendanceRow> _attendance = const {};
  Map<int, List<AdminSessionRecord>> _records = const {};
  bool _attendanceReady = false;

  final Set<int> _attendanceBusy = <int>{};
  int? _teamFilter;
  bool _remainingOnly = false;
  bool _loadingRoster = true;
  String? _rosterError;

  /// Bumped after a write so the matching section refetches on its own.
  int _attendanceRevision = 0;
  int _recordsRevision = 0;

  AdminRepository get _repo => AdminRepositoryScope.of(context);

  String _attendanceKey(int sessionId) =>
      'teacher-today-attendance-$sessionId';

  String _recordsKey(int sessionId) => 'teacher-today-records-$sessionId';

  Set<int> get _rosterIds => {for (final entry in _roster) entry.student.id};

  Map<int, AdminAttendanceRow> _attendanceByStudent(
    Iterable<AdminAttendanceRow> rows,
  ) {
    final ids = _rosterIds;
    return {
      for (final row in rows)
        if (ids.contains(row.studentId)) row.studentId: row,
    };
  }

  Map<int, List<AdminSessionRecord>> _recordsByStudent(
    Iterable<AdminSessionRecord> records,
  ) {
    final ids = _rosterIds;
    final byStudent = <int, List<AdminSessionRecord>>{};
    for (final record in records) {
      if (!ids.contains(record.studentId)) continue;
      byStudent.putIfAbsent(record.studentId, () => []).add(record);
    }
    return byStudent;
  }

  @override
  void initState() {
    super.initState();
    _selection = ScreenCache.instance.read<TeacherSessionSelection>(
      _selectionCacheKey,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRoster());
  }

  /// Paints the last session payload from the section cache before the network
  /// answers, so returning to the tab never shows an empty attendance list.
  void _restoreCachedSessionData() {
    final selection = _selection;
    if (selection == null) return;
    final sessionId = selection.session.id;
    if (!_attendanceReady) {
      final cached = ScreenCache.instance.read<List<AdminAttendanceRow>>(
        _attendanceKey(sessionId),
      );
      if (cached != null) {
        _attendance = _attendanceByStudent(cached);
        _attendanceReady = true;
      }
    }
    if (_records.isEmpty) {
      final cached = ScreenCache.instance.read<List<AdminSessionRecord>>(
        _recordsKey(sessionId),
      );
      if (cached != null) _records = _recordsByStudent(cached);
    }
  }

  Future<void> _loadRoster() async {
    if (!mounted) return;
    setState(() {
      _loadingRoster = true;
      _rosterError = null;
    });
    try {
      final roster = await TeacherRosterService(_repo).load();
      if (!mounted) return;
      setState(() {
        _roster = roster;
        _loadingRoster = false;
        _restoreCachedSessionData();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingRoster = false;
        _rosterError = '$error';
      });
    }
  }

  /// Pull-to-refresh: the roster is page-level, the session data belongs to the
  /// two sections and revalidates through their revisions.
  Future<void> _refresh() async {
    await _loadRoster();
    if (!mounted) return;
    setState(() {
      _attendanceRevision++;
      _recordsRevision++;
    });
  }

  Future<void> _selectSession() async {
    final result = await showTeacherSessionPicker(
      context,
      repository: _repo,
      current: _selection,
    );
    if (result == null || !mounted) return;
    ScreenCache.instance.write(_selectionCacheKey, result);
    setState(() {
      _selection = result;
      _teamFilter = null;
      _remainingOnly = false;
      // The sections remount on the new cache key; never show the previous
      // session's attendance or records in the meantime.
      _attendance = const {};
      _records = const {};
      _attendanceReady = false;
      _restoreCachedSessionData();
    });
  }

  /// Attendance request owned by the attendance section. The filtered map is
  /// published to state because row actions, the bulk action and the summary
  /// chips read it outside that section.
  Future<List<AdminAttendanceRow>> _loadAttendance(int sessionId) async {
    final rows = await _repo.sessionAttendance(sessionId);
    if (!mounted || _selection?.session.id != sessionId) return rows;
    setState(() {
      _attendance = _attendanceByStudent(rows);
      _attendanceReady = true;
    });
    return rows;
  }

  /// Records request owned by the records section; same roster-id filter and
  /// the same state hand-off as [_loadAttendance].
  Future<List<AdminSessionRecord>> _loadRecords(int sessionId) async {
    final records = await _repo.sessionRecords(sessionId);
    if (!mounted || _selection?.session.id != sessionId) return records;
    setState(() {
      _records = _recordsByStudent(records);
    });
    return records;
  }

  Future<void> _toggleAttendance(
    TeacherRosterEntry entry, {
    bool revalidate = true,
  }) async {
    final selection = _selection;
    if (selection == null || _attendanceBusy.contains(entry.student.id)) return;
    final removing = _attendance.containsKey(entry.student.id);
    _attendanceBusy.add(entry.student.id);
    setState(() {});
    try {
      if (removing) {
        await _repo.removeAttendance(selection.session.id, entry.student.id);
      } else {
        await _repo.addManualAttendance(selection.session.id, entry.student.id);
      }
      final rows = await _repo.sessionAttendance(selection.session.id);
      if (!mounted || _selection?.session.id != selection.session.id) return;
      AdminAttendanceRow? added;
      if (!removing) {
        added = rows
            .where((row) => row.studentId == entry.student.id)
            .firstOrNull;
      }
      setState(() {
        _attendance = _attendanceByStudent(rows);
        _attendanceReady = true;
        if (revalidate) _attendanceRevision++;
      });
      if (removing) {
        _notice('أُلغي حضور ${entry.student.name}');
      } else if (added != null) {
        _showAttendanceBanner(entry, added);
      }
    } catch (error) {
      if (!mounted) return;
      _notice('تعذّر تسجيل الحضور: $error');
    } finally {
      _attendanceBusy.remove(entry.student.id);
      if (mounted) setState(() {});
    }
  }

  /// Small floating snackbar showing the recorded time plus a one-tap
  /// «تعديل الوقت» action (same affordance as the supervisor attendance mode).
  void _showAttendanceBanner(TeacherRosterEntry entry, AdminAttendanceRow row) {
    final time = row.arrivalTime;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 8),
          content: Text(
            time == null
                ? 'سُجّل حضور ${entry.student.name}'
                : 'سُجّل حضور ${entry.student.name} · ${formatTime(time)}',
          ),
          action: SnackBarAction(
            label: 'تعديل الوقت',
            onPressed: () => _editAttendanceTime(entry, current: time),
          ),
        ),
      );
  }

  Future<void> _editAttendanceTime(
    TeacherRosterEntry entry, {
    DateTime? current,
  }) async {
    final selection = _selection;
    if (selection == null || _attendanceBusy.contains(entry.student.id)) {
      return;
    }
    final time = current ?? _attendance[entry.student.id]?.arrivalTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: time == null
          ? TimeOfDay.now()
          : TimeOfDay.fromDateTime(time),
    );
    if (picked == null || !mounted) return;
    final active = _selection;
    if (active == null) return;
    final at = DateTime(
      active.session.date.year,
      active.session.date.month,
      active.session.date.day,
      picked.hour,
      picked.minute,
    );
    _attendanceBusy.add(entry.student.id);
    setState(() {});
    try {
      if (_attendance.containsKey(entry.student.id)) {
        await _repo.updateAttendanceTime(
          active.session.id,
          entry.student.id,
          at,
        );
      } else {
        await _repo.addManualAttendance(
          active.session.id,
          entry.student.id,
          time: at,
        );
      }
      final rows = await _repo.sessionAttendance(active.session.id);
      if (!mounted || _selection?.session.id != active.session.id) return;
      setState(() {
        _attendance = _attendanceByStudent(rows);
        _attendanceReady = true;
        _attendanceRevision++;
      });
      _notice('وقت حضور ${entry.student.name}: ${formatTime(at)}');
    } catch (error) {
      if (!mounted) return;
      _notice('تعذّر تعديل وقت الحضور: $error');
    } finally {
      _attendanceBusy.remove(entry.student.id);
      if (mounted) setState(() {});
    }
  }

  Future<void> _openComposer({
    TeacherRosterEntry? entry,
    TeacherRecordKind? kind,
  }) async {
    final selection = _selection;
    if (selection == null) {
      _notice('اختر الدورة والجلسة أولًا');
      return;
    }
    final kinds = <RecordEntryKind>[];
    if (entry != null) {
      final allowed = kind == null ? entry.recordKinds : [kind];
      for (final item in allowed) {
        final mapped = _toEntryKind(item);
        if (mapped != null) kinds.add(mapped);
      }
    } else {
      final profile = currentProfile(context);
      final caps = profile?.capabilitiesForMode(teacher: true);
      if (caps?['memorization']?.canEdit == true) {
        kinds.add(RecordEntryKind.memorization);
      }
      if (caps?['matn']?.canEdit == true) kinds.add(RecordEntryKind.matn);
      if (caps?['points']?.canEdit == true) {
        kinds.add(RecordEntryKind.transaction);
      }
    }
    if (kinds.isEmpty) {
      _notice('لا توجد صلاحية كتابة لهذا الطالب/النوع');
      return;
    }
    await showRecordEntrySheet(
      context,
      selection.session.id,
      initialStudent: entry?.student,
      allowedKinds: kinds,
      teacherMode: true,
      onSaved: _reloadRecords,
    );
  }

  /// A record write only changes the records section; the attendance rows keep
  /// their data and simply repaint with the new summaries.
  void _reloadRecords() {
    if (!mounted) return;
    setState(() => _recordsRevision++);
  }

  RecordEntryKind? _toEntryKind(TeacherRecordKind kind) => switch (kind) {
    TeacherRecordKind.quranTasmi => RecordEntryKind.memorization,
    TeacherRecordKind.matn => RecordEntryKind.matn,
    TeacherRecordKind.points => RecordEntryKind.transaction,
    TeacherRecordKind.attendance => null,
  };

  void _openStudentActions(TeacherRosterEntry entry) {
    final selection = _selection;
    if (selection == null) return;
    showTeacherStudentActionsSheet(
      context,
      entry: entry,
      attendance: _attendance[entry.student.id],
      records: _records[entry.student.id] ?? const [],
      onToggleAttendance: () => _toggleAttendance(entry),
      onRecord: (kind) => _openComposer(entry: entry, kind: kind),
      onShowRecords: () => _showRecords(entry),
      onAdjustAttendanceTime: (current) =>
          _editAttendanceTime(entry, current: current),
      onOpenProfile: () =>
          context.push('/teacher/students/${entry.student.id}'),
    );
  }

  void _showRecords(TeacherRosterEntry entry) {
    showTeacherSessionRecordsSheet(
      context,
      entry: entry,
      records: _records[entry.student.id] ?? const [],
    );
  }

  void _notice(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<TeacherRosterEntry> get _visibleRoster {
    return _roster.where((entry) {
      if (!entry.matchesTeam(_teamFilter)) return false;
      if (_remainingOnly &&
          (_records[entry.student.id] ?? const []).isNotEmpty) {
        return false;
      }
      return true;
    }).toList();
  }

  List<({int id, String name})> get _teams {
    final byId = <int, String>{};
    for (final entry in _roster) {
      for (final team in entry.teams) {
        byId[team.id] = team.name;
      }
    }
    final items = byId.entries.map((e) => (id: e.key, name: e.value)).toList();
    items.sort((a, b) => a.name.compareTo(b.name));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final selection = _selection;

    return ResponsivePage(
      padding: const EdgeInsets.all(16),
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _sessionCard(context, tokens),
            const SizedBox(height: 12),
            if (selection == null)
              _chooseSessionEmpty(context)
            else ...[
              if (_roster.isNotEmpty || _loadingRoster) ...[
                _summarySection(context, tokens, selection),
                const SizedBox(height: 12),
              ],
              _actionsRow(context),
              const SizedBox(height: 8),
              _filters(context, tokens),
              const SizedBox(height: 8),
              _rosterBody(context, tokens, selection.session.id),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  /// Records request, rendered above the fold as the session summary chips: the
  /// attendance figure comes from the attendance section (published to state) so
  /// neither request blocks the other. It must stay in the first screenful —
  /// rows, the «متبقّون» filter and the row strips all read its result.
  Widget _summarySection(
    BuildContext context,
    AppTokens tokens,
    TeacherSessionSelection selection,
  ) {
    return AsyncSection<List<AdminSessionRecord>>(
      cacheKey: _recordsKey(selection.session.id),
      revision: _recordsRevision,
      skeleton: _summarySkeleton,
      load: () => _loadRecords(selection.session.id),
      builder: (context, records) {
        // Until the roster is known the counts would lie (0 students).
        if (_roster.isEmpty) {
          return _loadingRoster ? _summarySkeleton : const SizedBox.shrink();
        }
        return _summary(
          context,
          tokens,
          records: [
            for (final record in records)
              if (_rosterIds.contains(record.studentId)) record,
          ],
        );
      },
      errorBuilder: (context, retry) =>
          _summary(context, tokens, records: const [], retry: retry),
    );
  }

  static const Widget _summarySkeleton = Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      Skeleton(width: 84, height: 24, radius: 999),
      Skeleton(width: 72, height: 24, radius: 999),
      Skeleton(width: 86, height: 24, radius: 999),
    ],
  );

  Widget _summary(
    BuildContext context,
    AppTokens tokens, {
    required List<AdminSessionRecord> records,
    VoidCallback? retry,
  }) {
    final total = _roster.length;
    final present = _attendance.length;
    final recorded = {for (final record in records) record.studentId};
    final remaining = _roster
        .where((entry) => !recorded.contains(entry.student.id))
        .length;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (_attendanceReady)
          AppChip(
            label: 'حاضر $present/$total',
            icon: Icons.how_to_reg_outlined,
            color: tokens.brand,
          )
        else
          const Skeleton(width: 84, height: 24, radius: 999),
        if (retry == null) ...[
          AppChip(
            label: 'سجلات ${records.length}',
            icon: Icons.fact_check_outlined,
            color: tokens.info,
          ),
          AppChip(
            label: 'متبقّون $remaining',
            icon: Icons.pending_actions_outlined,
            color: tokens.reward,
          ),
        ] else
          AppChip(
            label: 'تعذّرت السجلات · إعادة',
            icon: Icons.refresh,
            color: tokens.dangerText,
            onTap: retry,
          ),
      ],
    );
  }

  /// Roster shell states (loading / error / no teams) stay page-level; once the
  /// roster is known the rows become the attendance section.
  Widget _rosterBody(
    BuildContext context,
    AppTokens tokens,
    int sessionId,
  ) {
    if (_roster.isEmpty && _loadingRoster) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionSkeleton(height: 48, lines: 2),
          SizedBox(height: 8),
          SectionSkeleton(height: 48, lines: 2),
        ],
      );
    }
    if (_roster.isEmpty && _rosterError != null) {
      return _errorCard(context, tokens);
    }
    if (_roster.isEmpty) {
      return const EmptyState(
        title: 'لا حلقات مرتبطة بك',
        message: 'تواصل مع إدارة المسجد لتعيين حلقاتك.',
        icon: Icons.groups_outlined,
      );
    }
    return AsyncSection<List<AdminAttendanceRow>>(
      cacheKey: _attendanceKey(sessionId),
      revision: _attendanceRevision,
      skeleton: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionSkeleton(height: 48, lines: 2),
          SizedBox(height: 8),
          SectionSkeleton(height: 48, lines: 2),
        ],
      ),
      load: () => _loadAttendance(sessionId),
      builder: (context, rows) {
        // Filter by the roster ids. Once the request has published, state is
        // the freshest copy (toggles update it before the section revalidates).
        final byStudent = _attendanceReady
            ? _attendance
            : _attendanceByStudent(rows);
        final visible = _visibleRoster;
        if (visible.isEmpty) {
          return const EmptyState(
            title: 'لا طلاب مطابقين',
            message: 'جرّب تغيير الفلتر أو إلغاء «المتبقّون».',
            icon: Icons.filter_alt_off_outlined,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final entry in visible) ...[
              TeacherRosterRow(
                entry: entry,
                attendance: byStudent[entry.student.id],
                records: _records[entry.student.id] ?? const [],
                attendanceBusy: _attendanceBusy.contains(entry.student.id),
                onOpen: () => _openStudentActions(entry),
                onToggleAttendance: () => _toggleAttendance(entry),
                onRecord: (kind) => _openComposer(entry: entry, kind: kind),
                onShowRecords: () => _showRecords(entry),
              ),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }

  Widget _sessionCard(BuildContext context, AppTokens tokens) {
    final selection = _selection;
    return AppCard(
      onTap: _selectSession,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tokens.brandTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.event_note_outlined, color: tokens.brandText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selection?.courseName ?? 'اختر الدورة والجلسة',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  selection == null
                      ? 'الدورة أولًا، ثم الجلسة'
                      : 'الجلسة ${selection.session.index} · ${selection.dateLabel}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppChip(
            label: selection == null ? 'اختيار' : 'تبديل',
            icon: Icons.swap_horiz,
            color: tokens.info,
            onTap: _selectSession,
          ),
        ],
      ),
    );
  }

  Widget _chooseSessionEmpty(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.today_outlined, size: 56, color: tokens.brandText),
          const SizedBox(height: 12),
          Text(
            'ابدأ باختيار الدورة والجلسة',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'سنعرض بعدها طلابك وأزرار التسجيل المسموحة فقط.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'اختر الدورة والجلسة',
            icon: Icons.arrow_forward,
            expand: false,
            onPressed: _selectSession,
          ),
        ],
      ),
    );
  }

  Widget _actionsRow(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final visible = _visibleRoster;
    // Never offer a bulk write before attendance is known: the targets are
    // derived from the already-present map.
    final canBulkAttendance =
        _attendanceReady &&
        visible.isNotEmpty &&
        visible.any((entry) => entry.attendanceAllowed);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        AppButton(
          label: 'إضافة سجل',
          icon: Icons.add,
          expand: false,
          onPressed: () => _openComposer(),
        ),
        AppButton(
          label: 'الكل حاضر',
          icon: Icons.done_all,
          variant: AppButtonVariant.secondary,
          expand: false,
          onPressed: canBulkAttendance ? _markAllPresent : null,
        ),
        if (_remainingOnly)
          AppChip(
            label: 'عرض الكل',
            icon: Icons.filter_alt_off_outlined,
            color: tokens.textMuted,
            onTap: () => setState(() => _remainingOnly = false),
          ),
      ],
    );
  }

  Future<void> _markAllPresent() async {
    final selection = _selection;
    if (selection == null) return;
    final targets = _visibleRoster
        .where((entry) => entry.attendanceAllowed)
        .where((entry) => !_attendance.containsKey(entry.student.id))
        .toList();
    if (targets.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الكل حاضر'),
        content: Text(
          'سيتم تسجيل حضور ${targets.length} طالبًا في هذه الجلسة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    for (final entry in targets) {
      // Each write updates the local attendance map; one revalidation at the
      // end is enough for the whole batch.
      await _toggleAttendance(entry, revalidate: false);
    }
    if (!mounted) return;
    setState(() => _attendanceRevision++);
  }

  Widget _filters(BuildContext context, AppTokens tokens) {
    final teams = _teams;
    // Wrap (not a horizontal scroller) so the «المتبقّون» filter is never
    // hidden off-screen when the teacher has several teams.
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        AppChip(
          label: 'الكل',
          color: _teamFilter == null ? tokens.brand : tokens.textMuted,
          onTap: () => setState(() => _teamFilter = null),
        ),
        for (final team in teams)
          AppChip(
            label: team.name,
            color: _teamFilter == team.id ? tokens.brand : tokens.textMuted,
            onTap: () => setState(() => _teamFilter = team.id),
          ),
        AppChip(
          label: 'المتبقّون',
          icon: Icons.pending_actions_outlined,
          color: _remainingOnly ? tokens.reward : tokens.textMuted,
          onTap: () => setState(() => _remainingOnly = !_remainingOnly),
        ),
      ],
    );
  }

  Widget _errorCard(BuildContext context, AppTokens tokens) {
    return AppCard(
      child: Row(
        children: [
          Icon(Icons.error_outline, color: tokens.dangerText),
          const SizedBox(width: 8),
          Expanded(child: Text(_rosterError ?? 'تعذّر التحميل')),
          TextButton(onPressed: _loadRoster, child: const Text('إعادة')),
        ],
      ),
    );
  }
}
