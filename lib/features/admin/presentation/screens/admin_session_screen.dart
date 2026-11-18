import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_guards.dart';
import '../../../../core/state/section_loader.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/utils/numeral_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/metric_charts.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/cubits/auth_state.dart';
import '../../../student/domain/models/student_models.dart';
import '../../domain/admin_models.dart';
import '../../../../shared/permissions.dart';
import '../admin_shell.dart';
import '../widgets/absence_notice_sheet.dart';
import '../widgets/attendance_status_chip.dart';
import '../widgets/course_metrics_panel.dart';
import '../widgets/session_records_section.dart';
import '../widgets/session_setup_sheet.dart';
import 'record_entry_sheet.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

/// Payload of the attendance block: the scanned rows (categories + times) and
/// the session roster, which is the source of truth for absences.
typedef _AttendanceData = ({
  List<AdminAttendanceRow> attendance,
  List<AdminSessionMember> members,
});

/// E3 — Session page: independent progressive sections (attendance → records →
/// summary), so a slow card never blocks the page shell.
class AdminSessionScreen extends StatefulWidget {
  const AdminSessionScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  State<AdminSessionScreen> createState() => _AdminSessionScreenState();
}

class _AdminSessionScreenState extends State<AdminSessionScreen> {
  final Set<int> _pendingMembers = {};

  /// Bumped by pull-to-refresh and after every write so each section reloads
  /// on its own.
  int _revision = 0;

  /// Last known session date (filled by the page shell). Used as the base day
  /// when adjusting an arrival time and for the attendance header.
  DateTime? _sessionDate;

  late Future<AdminSessionRow> _sessionFuture;

  AttendanceCategory? _filter;
  static const int _previewCount = 6;

  @override
  void initState() {
    super.initState();
    // `AdminRepositoryScope.of` uses `getInheritedWidgetOfExactType`, so the
    // repository can be resolved before the first build.
    _sessionFuture = _loadSessionRow();
  }

  Future<AdminSessionRow> _loadSessionRow() async {
    final row = await AdminRepositoryScope.of(
      context,
    ).sessionRow(widget.sessionId);
    _sessionDate = row.date;
    return row;
  }

  /// One request pair for the three cards that share the same dependency.
  Future<_AttendanceData> _loadAttendance() async {
    final repo = AdminRepositoryScope.of(context);
    // Sequential: the page must not fire both endpoints at the same time.
    final attendance = await repo.sessionAttendance(widget.sessionId);
    final members = await repo.sessionMembers(widget.sessionId);
    return (attendance: attendance, members: members);
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _revision++;
      _sessionFuture = _loadSessionRow();
    });
  }

  /// The absence-notice action is available to everyone who can manage
  /// attendance (trial: the admin demo profile always can).
  bool _canSendAbsenceNotice(BuildContext context) {
    AuthState? state;
    try {
      state = context.watch<AuthCubit>().state;
    } on Object {
      state = null;
    }
    if (state is! AuthAuthenticated) return false;
    final profile = state.profile;
    if (profile.isDemo) return true;
    return canEdit(profile, 'attendance');
  }

  @override
  Widget build(BuildContext context) {
    final canSendAbsence = _canSendAbsenceNotice(context);
    final canViewAttendance = canViewModule(context, 'attendance');
    return AsyncView<AdminSessionRow>(
      future: _sessionFuture,
      cacheKey: 'admin-session-row-${widget.sessionId}',
      frame: (context, child) => Scaffold(
        appBar: AppBar(title: const Text('الجلسة')),
        body: child,
      ),
      builder: (context, session) => Scaffold(
        appBar: AppBar(
          title: Text('جلسة #${session.index}'),
          actions: [
            if (canEditModule(context, 'courses'))
              IconButton(
                tooltip: 'تعديل الجلسة',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _editSession(context, session),
              ),
          ],
        ),
        body: ResponsivePage(
          maxWidth: 1100,
          child: RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (canViewAttendance) ...[
                  AsyncSection<_AttendanceData>(
                    cacheKey: 'admin-session-attendance-${widget.sessionId}',
                    revision: _revision,
                    skeleton: const SectionSkeleton(height: 96, lines: 3),
                    load: _loadAttendance,
                    builder: (context, data) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _attendanceBar(
                          context,
                          data,
                          canSendAbsence: canSendAbsence,
                          canRegister: canEditModule(context, 'attendance'),
                        ),
                        const SizedBox(height: 12),
                        _attendanceList(context, data),
                        const SizedBox(height: 12),
                        _summarySection(context, data),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _recordSection(context),
                if (canViewAttendance) ...[
                  const SizedBox(height: 12),
                  AsyncSection<List<AdminSessionRecord>>(
                    cacheKey: 'admin-session-records-${widget.sessionId}',
                    revision: _revision,
                    delay: const Duration(milliseconds: 80),
                    skeleton: const SectionSkeleton(height: 64, lines: 2),
                    load: () => AdminRepositoryScope.of(
                      context,
                    ).sessionRecords(widget.sessionId),
                    builder: (context, records) =>
                        SessionRecordsSection(records: records),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The roster of the session; falls back to the scanned attendees when the
  /// server roster is empty (e.g. a brand-new session).
  List<AdminSessionMember> _roster(_AttendanceData data) =>
      data.members.isEmpty ? _fallbackMembers(data) : data.members;

  /// Roster-based absence count: every roster member without an arrival time
  /// is absent. This stays consistent with the visible day list (the old
  /// `session.total` could be 0 and wrongly report «غياب 0»).
  int _absentCount(_AttendanceData data) =>
      _roster(data).where((m) => !m.present).length;

  static Color _categoryColor(AppTokens tokens, AttendanceCategory c) =>
      switch (c) {
        AttendanceCategory.early => tokens.brand,
        AttendanceCategory.onTime => tokens.infoLight,
        AttendanceCategory.late => tokens.danger,
        AttendanceCategory.absent => tokens.textMuted,
      };

  Widget _attendanceBar(
    BuildContext context,
    _AttendanceData data, {
    required bool canSendAbsence,
    required bool canRegister,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final roster = _roster(data);
    int countOf(AttendanceCategory c) =>
        roster.where((m) => _categoryOf(m, data) == c).length;
    final absent = _absentCount(data);
    final absentees = roster.where((m) => !m.present).toList();
    final date = _sessionDate;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'الحضور اللحظي',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (date != null) ...[
                const SizedBox(width: 8),
                Text(
                  formatDate(date),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Words stay hidden until hover / long press; only icons + counts.
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final c in const [
                AttendanceCategory.early,
                AttendanceCategory.onTime,
                AttendanceCategory.late,
                AttendanceCategory.absent,
              ])
                AttendanceStatusChip(
                  category: c,
                  count: c == AttendanceCategory.absent ? absent : countOf(c),
                ),
            ],
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'تسجيل الحضور (مسح + يدوي)',
            icon: Icons.qr_code_scanner,
            onPressed: !canRegister
                ? null
                : () async {
                    await context.push(
                      '/admin/sessions/${widget.sessionId}/attendance',
                    );
                    if (!mounted) return;
                    _reload();
                  },
          ),
          if (canSendAbsence) ...[
            const SizedBox(height: 8),
            AppButton(
              label: 'إشعارات الغياب (${absentees.length})',
              icon: Icons.campaign_outlined,
              variant: AppButtonVariant.secondary,
              onPressed: () => _sendAbsenceNotices(absentees),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _sendAbsenceNotices(List<AdminSessionMember> absentees) async {
    if (absentees.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('لا غياب في هذه الجلسة')));
      return;
    }
    final repo = AdminRepositoryScope.of(context);
    final count = await showAbsenceNoticeSheet(
      context,
      sessionId: widget.sessionId,
      absentees: absentees,
      repository: repo,
    );
    if (count == null || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('أُرسل $count إشعار غياب')));
  }

  Widget _attendanceList(BuildContext context, _AttendanceData data) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final members = _roster(data);
    final visible = members.where((m) => _matchesFilter(m, data)).toList();
    int countOf(AttendanceCategory c) =>
        members.where((m) => _categoryOf(m, data) == c).length;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: SectionHeader(
                  icon: Icons.people_outline,
                  title: 'قائمة اليوم',
                ),
              ),
              TextButton(
                onPressed: () => _showAll(context, data),
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _filterGroup(tokens, countOf),
          const SizedBox(height: 6),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'لا نتائج لهذا الفلتر',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            for (final m in visible.take(_previewCount))
              _memberRow(context, data, m),
          if (visible.length > _previewCount)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: TextButton(
                onPressed: () => _showAll(context, data),
                child: Text('عرض الكل (${visible.length})'),
              ),
            ),
        ],
      ),
    );
  }

  /// Horizontal, icon-first filters above the day list: the Arabic label only
  /// surfaces on hover / long press, so every row does not repeat «مبكر /
  /// في الوقت …». Wraps into a second line on narrow windows.
  Widget _filterGroup(
    AppTokens tokens,
    int Function(AttendanceCategory) countOf,
  ) {
    return Wrap(
      key: const ValueKey('session-attendance-filters'),
      alignment: WrapAlignment.start,
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _FilterIconChip(
          icon: Icons.apps,
          label: 'الكل',
          selected: _filter == null,
          color: tokens.textSecondary,
          onTap: () => setState(() => _filter = null),
        ),
        for (final c in const [
          AttendanceCategory.early,
          AttendanceCategory.onTime,
          AttendanceCategory.late,
          AttendanceCategory.absent,
        ])
          _FilterIconChip(
            icon: AttendanceStatusChip.iconOf(c),
            label: AttendanceStatusChip.labelOf(c),
            selected: _filter == c,
            color: _categoryColor(tokens, c),
            count: countOf(c),
            onTap: () => setState(() => _filter = _filter == c ? null : c),
          ),
      ],
    );
  }

  /// Fallback when the roster is empty (e.g. brand-new session): show the
  /// scanned attendees only.
  List<AdminSessionMember> _fallbackMembers(_AttendanceData data) => [
    for (final a in data.attendance)
      AdminSessionMember(
        studentId: a.studentId,
        name: a.name,
        arrivalTime: a.arrivalTime,
      ),
  ];

  bool _matchesFilter(AdminSessionMember m, _AttendanceData data) {
    final filter = _filter;
    if (filter == null) return true;
    return _categoryOf(m, data) == filter;
  }

  AttendanceCategory? _categoryOf(AdminSessionMember m, _AttendanceData data) {
    if (!m.present) return AttendanceCategory.absent;
    for (final a in data.attendance) {
      if (a.studentId == m.studentId) return a.category;
    }
    return null;
  }

  Widget _memberRow(
    BuildContext context,
    _AttendanceData data,
    AdminSessionMember m,
  ) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final category = _categoryOf(m, data);
    final absent = !m.present;
    final canEdit = canEditModule(context, 'attendance');
    final pending = _pendingMembers.contains(m.studentId);
    return InkWell(
      key: ValueKey('session-member-${m.studentId}'),
      borderRadius: BorderRadius.circular(tokens.radiusSmall),
      onTap: canEdit && !pending ? () => _editAttendance(data, m) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              absent ? Icons.person_off_outlined : Icons.person,
              size: 18,
              color: absent ? tokens.textMuted : tokens.brandText,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                m.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: absent ? tokens.textMuted : tokens.textPrimary,
                  decoration: absent ? TextDecoration.lineThrough : null,
                  fontWeight: absent ? FontWeight.w400 : FontWeight.w600,
                ),
              ),
            ),
            if (pending) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ] else ...[
              if (m.arrivalTime != null) ...[
                const SizedBox(width: 8),
                Text(
                  formatTime(m.arrivalTime!),
                  textDirection: TextDirection.ltr,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
              ],
              const SizedBox(width: 8),
              AttendanceStatusChip(
                category: category ?? AttendanceCategory.absent,
                dense: true,
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_left,
                size: 16,
                color: tokens.borderStructural,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Quick attendance actions from the day list: add / adjust time / remove
  /// (with an undo window) — saves the supervisor a trip to the scan page.
  Future<void> _editAttendance(
    _AttendanceData data,
    AdminSessionMember m,
  ) async {
    if (!canEditModule(context, 'attendance') ||
        _pendingMembers.contains(m.studentId)) {
      return;
    }
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final present = m.present;
    final action = await showAppSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: tokens.brandTint,
                    child: Text(
                      m.name.characters.first,
                      style: TextStyle(
                        color: tokens.brandText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          present
                              ? 'مسجّل حضور${m.arrivalTime == null ? '' : ' · ${formatTime(m.arrivalTime!)}'}'
                              : 'غائب عن هذه الجلسة',
                          style: TextStyle(
                            color: tokens.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (present) ...[
              ListTile(
                leading: Icon(Icons.schedule, color: tokens.info),
                title: const Text('ضبط وقت الحضور'),
                onTap: () => Navigator.pop(context, 'time'),
              ),
              ListTile(
                leading: Icon(
                  Icons.remove_circle_outline,
                  color: tokens.danger,
                ),
                title: const Text('إزالة الحضور'),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
            ] else
              ListTile(
                leading: Icon(Icons.check_circle_outline, color: tokens.brand),
                title: const Text('تسجيل الحضور الآن'),
                onTap: () => Navigator.pop(context, 'add'),
              ),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;
    final repo = AdminRepositoryScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _pendingMembers.add(m.studentId));
    try {
      switch (action) {
        case 'add':
          await repo.addManualAttendance(widget.sessionId, m.studentId);
          if (!mounted) return;
          _reload();
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text('سُجّل حضور ${m.name}')));
        case 'time':
          final base = m.arrivalTime ?? _sessionDate ?? DateTime.now();
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(base),
          );
          if (picked == null || !mounted) return;
          final at = DateTime(
            base.year,
            base.month,
            base.day,
            picked.hour,
            picked.minute,
          );
          await repo.updateAttendanceTime(widget.sessionId, m.studentId, at);
          if (!mounted) return;
          _reload();
        case 'remove':
          final oldTime = m.arrivalTime;
          await repo.removeAttendance(widget.sessionId, m.studentId);
          if (!mounted) return;
          _reload();
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('أُزيل حضور ${m.name}'),
                duration: const Duration(seconds: 6),
                action: SnackBarAction(
                  label: 'تراجع',
                  onPressed: () async {
                    await repo.addManualAttendance(
                      widget.sessionId,
                      m.studentId,
                      time: oldTime,
                    );
                    _reload();
                  },
                ),
              ),
            );
      }
    } catch (error) {
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('تعذر تحديث الحضور: $error')));
    } finally {
      if (mounted) {
        setState(() => _pendingMembers.remove(m.studentId));
      }
    }
  }

  void _showAll(BuildContext context, _AttendanceData data) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final members = _roster(data);
    final visible = members.where((m) => _matchesFilter(m, data)).toList();
    showAppSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'قائمة اليوم (${visible.length})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(width: 8),
                IconCount(
                  icon: Icons.how_to_reg_outlined,
                  value: visible.where((m) => m.present).length,
                  tooltip: 'الحاضرون في القائمة',
                  color: tokens.brandText,
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final m in visible) _memberRow(context, data, m),
          ],
        ),
      ),
    );
  }

  Widget _recordSection(BuildContext context) {
    if (!canEditModule(context, 'memorization') &&
        !canEditModule(context, 'points') &&
        !canEditModule(context, 'matn')) {
      return const SizedBox.shrink();
    }
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(icon: Icons.edit_note, title: 'التسجيل'),
          const SizedBox(height: 12),
          AppButton(
            label: 'تسجيل (حفظ · متون · معاملة)',
            icon: Icons.add,
            variant: AppButtonVariant.secondary,
            onPressed: () async {
              await showRecordEntrySheet(context, widget.sessionId);
              if (!mounted) return;
              _reload();
            },
          ),
        ],
      ),
    );
  }

  Widget _summarySection(BuildContext context, _AttendanceData data) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final roster = _roster(data);
    final present = roster.where((m) => m.present).length;
    // The roster is the source of truth when it is loaded; `session.total`
    // can be 0 and must never drive the absence count.
    final total = math.max(math.max(roster.length, present), 0);
    final absent = _absentCount(data);
    final percent = total == 0 ? 0.0 : (present / total) * 100;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            icon: Icons.summarize_outlined,
            title: 'محصلة اليوم',
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        IconCount(
                          icon: Icons.how_to_reg_outlined,
                          value: present,
                          fraction: total > 0 ? total : null,
                          tooltip: 'الحاضرون من إجمالي القائمة',
                          color: tokens.brandText,
                        ),
                        IconCount(
                          icon: Icons.person_off_outlined,
                          value: absent,
                          tooltip: 'الغائبون',
                          color: tokens.dangerText,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _attendanceRatioBar(
                      tokens: tokens,
                      present: present,
                      absent: absent,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Tooltip(
                message: 'نسبة الحضور',
                triggerMode: TooltipTriggerMode.longPress,
                child: PercentDonut(percent: percent, size: 88, strokeWidth: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Thin stacked bar: brand = present, muted = absent.
  Widget _attendanceRatioBar({
    required AppTokens tokens,
    required int present,
    required int absent,
  }) {
    final empty = present <= 0 && absent <= 0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Tooltip(
        message: 'حضور $present · غياب $absent',
        triggerMode: TooltipTriggerMode.longPress,
        child: SizedBox(
          height: 8,
          child: Row(
            children: [
              if (present > 0)
                Expanded(
                  flex: present,
                  child: ColoredBox(color: tokens.brand),
                ),
              if (absent > 0)
                Expanded(
                  flex: absent,
                  child: ColoredBox(
                    color: tokens.textMuted.withValues(alpha: 0.22),
                  ),
                ),
              if (empty)
                Expanded(child: ColoredBox(color: tokens.surfaceSubtle)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editSession(BuildContext context, AdminSessionRow s) async {
    final repo = AdminRepositoryScope.of(context);
    final setup = await showSessionSetupSheet(
      context,
      initial: SessionSetupValues(
        earlyPoints: s.earlyPoints,
        midPoints: s.midPoints,
        latePoints: s.latePoints,
        earlyUntil: s.earlyUntil,
        lateFrom: s.lateFrom,
        date: s.date,
      ),
    );
    if (setup == null || !mounted) return;
    await repo.updateSession(
      s.id,
      earlyPoints: setup.earlyPoints,
      midPoints: setup.midPoints,
      latePoints: setup.latePoints,
      earlyUntil: setup.earlyUntil,
      lateFrom: setup.lateFrom,
      date: setup.date,
    );
    if (!mounted) return;
    HapticFeedback.lightImpact();
    _reload();
  }
}

/// Icon-first filter chip for the day list: the Arabic label only appears on
/// hover / long press, while the count stays visible. Keeps rows free of the
/// repeated «مبكر / في الوقت / متأخر / غائب» words.
class _FilterIconChip extends StatelessWidget {
  const _FilterIconChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
    this.count,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final foreground = selected ? tokens.surfaceCard : color;
    final count = this.count;
    return Tooltip(
      message: label,
      triggerMode: TooltipTriggerMode.longPress,
      waitDuration: const Duration(milliseconds: 250),
      child: Semantics(
        selected: selected,
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 44,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: selected ? tokens.brand : tokens.surfaceCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? tokens.brand : tokens.borderStructural,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 15, color: foreground),
                    if (count != null && count > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        formatNumber(count),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
