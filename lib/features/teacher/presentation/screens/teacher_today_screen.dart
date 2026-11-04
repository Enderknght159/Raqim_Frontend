import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../shared/permissions.dart';
import '../../../admin/data/admin_repository.dart';
import '../../../admin/domain/admin_models.dart';
import '../../../admin/presentation/admin_shell.dart';
import '../../../admin/presentation/screens/record_entry_sheet.dart';
import '../../data/teacher_roster_service.dart';
import '../../domain/teacher_models.dart';
import '../widgets/teacher_roster_row.dart';
import '../widgets/teacher_session_picker.dart';
import '../widgets/teacher_student_actions_sheet.dart';

/// Teacher home: course → session → my students → records.
class TeacherTodayScreen extends StatefulWidget {
  const TeacherTodayScreen({super.key});

  @override
  State<TeacherTodayScreen> createState() => _TeacherTodayScreenState();
}

class _TeacherTodayScreenState extends State<TeacherTodayScreen> {
  TeacherSessionSelection? _selection;
  List<TeacherRosterEntry> _roster = const [];
  Map<int, AdminAttendanceRow> _attendance = const {};
  Map<int, List<AdminSessionRecord>> _records = const {};
  final Set<int> _attendanceBusy = <int>{};
  int? _teamFilter;
  bool _remainingOnly = false;
  bool _loading = true;
  String? _error;

  AdminRepository get _repo => AdminRepositoryScope.of(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRoster());
  }

  Future<void> _loadRoster() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final roster = await TeacherRosterService(_repo).load();
      if (!mounted) return;
      setState(() {
        _roster = roster;
        _loading = false;
      });
      if (_selection != null) await _loadSessionData(silent: true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$error';
      });
    }
  }

  Future<void> _selectSession() async {
    final result = await showTeacherSessionPicker(
      context,
      repository: _repo,
      current: _selection,
    );
    if (result == null || !mounted) return;
    setState(() {
      _selection = result;
      _teamFilter = null;
      _remainingOnly = false;
    });
    await _loadSessionData();
  }

  Future<void> _loadSessionData({bool silent = false}) async {
    final selection = _selection;
    if (selection == null || !mounted) return;
    if (!silent) setState(() => _loading = true);
    try {
      final results = await Future.wait<Object>([
        _repo.sessionAttendance(selection.session.id),
        _repo.sessionRecords(selection.session.id),
      ]);
      final attendance = results[0] as List<AdminAttendanceRow>;
      final records = results[1] as List<AdminSessionRecord>;
      final ids = _roster.map((entry) => entry.student.id).toSet();
      final byStudent = <int, List<AdminSessionRecord>>{};
      for (final record in records) {
        if (!ids.contains(record.studentId)) continue;
        byStudent.putIfAbsent(record.studentId, () => []).add(record);
      }
      if (!mounted) return;
      setState(() {
        _attendance = {
          for (final row in attendance)
            if (ids.contains(row.studentId)) row.studentId: row,
        };
        _records = byStudent;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$error';
      });
    }
  }

  Future<void> _toggleAttendance(TeacherRosterEntry entry) async {
    final selection = _selection;
    if (selection == null || _attendanceBusy.contains(entry.student.id)) return;
    _attendanceBusy.add(entry.student.id);
    setState(() {});
    try {
      if (_attendance.containsKey(entry.student.id)) {
        await _repo.removeAttendance(selection.session.id, entry.student.id);
      } else {
        await _repo.addManualAttendance(selection.session.id, entry.student.id);
      }
      final rows = await _repo.sessionAttendance(selection.session.id);
      final ids = _roster.map((e) => e.student.id).toSet();
      if (!mounted) return;
      setState(() {
        _attendance = {
          for (final row in rows)
            if (ids.contains(row.studentId)) row.studentId: row,
        };
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذّر تسجيل الحضور: $error')));
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
      onSaved: () => _loadSessionData(silent: true),
    );
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
      onOpenProfile: () =>
          context.push('/teacher/students/${entry.student.id}'),
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
        onRefresh: _loadRoster,
        child: ListView(
          children: [
            _sessionCard(context, tokens),
            const SizedBox(height: 12),
            if (selection == null)
              _chooseSessionEmpty(context)
            else ...[
              _summary(context, tokens),
              const SizedBox(height: 12),
              _actionsRow(context),
              const SizedBox(height: 8),
              _filters(context, tokens),
              const SizedBox(height: 8),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                _errorCard(context, tokens)
              else if (_roster.isEmpty)
                const EmptyState(
                  title: 'لا حلقات مرتبطة بك',
                  message: 'تواصل مع إدارة المسجد لتعيين حلقاتك.',
                  icon: Icons.groups_outlined,
                )
              else if (_visibleRoster.isEmpty)
                const EmptyState(
                  title: 'لا طلاب مطابقين',
                  message: 'جرّب تغيير الفلتر أو إلغاء «المتبقّون».',
                  icon: Icons.filter_alt_off_outlined,
                )
              else
                for (final entry in _visibleRoster) ...[
                  TeacherRosterRow(
                    entry: entry,
                    attendance: _attendance[entry.student.id],
                    records: _records[entry.student.id] ?? const [],
                    attendanceBusy: _attendanceBusy.contains(entry.student.id),
                    onOpen: () => _openStudentActions(entry),
                    onToggleAttendance: () => _toggleAttendance(entry),
                    onRecord: (kind) => _openComposer(entry: entry, kind: kind),
                  ),
                  const SizedBox(height: 8),
                ],
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
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

  Widget _summary(BuildContext context, AppTokens tokens) {
    final total = _roster.length;
    final present = _attendance.length;
    final records = _records.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );
    final remaining = _roster
        .where((entry) => (_records[entry.student.id] ?? const []).isEmpty)
        .length;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        AppChip(
          label: 'حاضر $present/$total',
          icon: Icons.how_to_reg_outlined,
          color: tokens.brand,
        ),
        AppChip(
          label: 'سجلات $records',
          icon: Icons.fact_check_outlined,
          color: tokens.info,
        ),
        AppChip(
          label: 'متبقّون $remaining',
          icon: Icons.pending_actions_outlined,
          color: tokens.reward,
        ),
      ],
    );
  }

  Widget _actionsRow(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final visible = _visibleRoster;
    final canBulkAttendance =
        visible.isNotEmpty && visible.any((entry) => entry.attendanceAllowed);
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
      await _toggleAttendance(entry);
    }
  }

  Widget _filters(BuildContext context, AppTokens tokens) {
    final teams = _teams;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          AppChip(
            label: 'الكل',
            color: _teamFilter == null ? tokens.brand : tokens.textMuted,
            onTap: () => setState(() => _teamFilter = null),
          ),
          const SizedBox(width: 6),
          for (final team in teams) ...[
            AppChip(
              label: team.name,
              color: _teamFilter == team.id ? tokens.brand : tokens.textMuted,
              onTap: () => setState(() => _teamFilter = team.id),
            ),
            const SizedBox(width: 6),
          ],
          AppChip(
            label: 'المتبقّون',
            icon: Icons.pending_actions_outlined,
            color: _remainingOnly ? tokens.reward : tokens.textMuted,
            onTap: () => setState(() => _remainingOnly = !_remainingOnly),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(BuildContext context, AppTokens tokens) {
    return AppCard(
      child: Row(
        children: [
          Icon(Icons.error_outline, color: tokens.dangerText),
          const SizedBox(width: 8),
          Expanded(child: Text(_error ?? 'تعذّر التحميل')),
          TextButton(onPressed: _loadRoster, child: const Text('إعادة')),
        ],
      ),
    );
  }
}
