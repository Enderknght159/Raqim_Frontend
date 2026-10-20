import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../student/domain/models/student_models.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';
import '../widgets/session_setup_sheet.dart';
import 'record_entry_sheet.dart';

/// E3 — Session page: single serial flow (attendance → records → summary →
/// messages/export).
class AdminSessionScreen extends StatefulWidget {
  const AdminSessionScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  State<AdminSessionScreen> createState() => _AdminSessionScreenState();
}

class _AdminSessionScreenState extends State<AdminSessionScreen> {
  late Future<_Data> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_Data> _load() async {
    final repo = AdminRepositoryScope.of(context);
    return _Data(
      session: await repo.sessionRow(widget.sessionId),
      attendance: await repo.sessionAttendance(widget.sessionId),
      members: await repo.sessionMembers(widget.sessionId),
    );
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AsyncView<_Data>(
      future: _future,
      builder: (context, data) => Scaffold(
        appBar: AppBar(
          title: Text('جلسة #${data.session.index}'),
          actions: [
            IconButton(
              tooltip: 'تعديل الجلسة',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editSession(context, data),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _attendanceBar(context, data),
              const SizedBox(height: 16),
              _attendanceList(context, data),
              const SizedBox(height: 16),
              _recordSection(context),
              const SizedBox(height: 16),
              _summarySection(context, data),
              const SizedBox(height: 16),
              _messagesSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attendanceBar(BuildContext context, _Data data) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final early = data.attendance
        .where((a) => a.category == AttendanceCategory.early)
        .length;
    final onTime = data.attendance
        .where((a) => a.category == AttendanceCategory.onTime)
        .length;
    final late = data.attendance
        .where((a) => a.category == AttendanceCategory.late)
        .length;
    final present = data.attendance.length;
    final absent = data.session.total - present;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('الحضور اللحظي',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ),
              Text(formatDate(data.session.date),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: tokens.textMuted)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              StatusBadge(label: 'مبكر $early', color: tokens.brand),
              StatusBadge(label: 'في الوقت $onTime', color: tokens.infoLight),
              StatusBadge(label: 'متأخر $late', color: tokens.danger),
              StatusBadge(
                  label: 'غائب ${absent < 0 ? 0 : absent}',
                  color: tokens.textMuted),
            ],
          ),
          const SizedBox(height: 14),
          AppButton(
            label: 'تسجيل الحضور (مسح + يدوي)',
            icon: Icons.qr_code_scanner,
            onPressed: () async {
              await context.push('/admin/sessions/${widget.sessionId}/attendance');
              if (!mounted) return;
              _reload();
            },
          ),
        ],
      ),
    );
  }

  static const _filterLabels = ['الكل', 'مبكر', 'في الوقت', 'متأخر', 'غائب'];

  String? _filter;
  static const int _previewCount = 6;

  Widget _attendanceList(BuildContext context, _Data data) {
    final members = data.members.isEmpty ? _fallbackMembers(data) : data.members;
    final visible = members
        .where((m) => _matchesFilter(m, data))
        .toList();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: SectionHeader(
                    icon: Icons.people_outline, title: 'قائمة اليوم'),
              ),
              TextButton(
                onPressed: () => _showAll(context, data),
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              children: [
                for (final label in _filterLabels)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _filter == label || (_filter == null && label == 'الكل'),
                      onSelected: (_) => setState(() =>
                          _filter = label == 'الكل' ? null : label),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('لا نتائج لهذا الفلتر',
                  style: Theme.of(context).textTheme.bodyMedium),
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

  /// Fallback when the roster is empty (e.g. brand-new session): show the
  /// scanned attendees only.
  List<AdminSessionMember> _fallbackMembers(_Data data) => [
        for (final a in data.attendance)
          AdminSessionMember(
            studentId: a.studentId,
            name: a.name,
            arrivalTime: a.arrivalTime,
          ),
      ];

  bool _matchesFilter(AdminSessionMember m, _Data data) {
    switch (_filter) {
      case 'مبكر':
        return _categoryOf(m, data) == AttendanceCategory.early;
      case 'في الوقت':
        return _categoryOf(m, data) == AttendanceCategory.onTime;
      case 'متأخر':
        return _categoryOf(m, data) == AttendanceCategory.late;
      case 'غائب':
        return !m.present;
      default:
        return true;
    }
  }

  AttendanceCategory? _categoryOf(AdminSessionMember m, _Data data) {
    if (!m.present) return AttendanceCategory.absent;
    for (final a in data.attendance) {
      if (a.studentId == m.studentId) return a.category;
    }
    return null;
  }

  Widget _memberRow(BuildContext context, _Data data, AdminSessionMember m) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final category = _categoryOf(m, data);
    final absent = !m.present;
    return Padding(
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
              style: TextStyle(
                color: absent ? tokens.textMuted : tokens.textPrimary,
                decoration: absent ? TextDecoration.lineThrough : null,
                fontWeight: absent ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
          ),
          if (m.arrivalTime != null)
            Text(formatTime(m.arrivalTime!),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: tokens.textMuted)),
          const SizedBox(width: 8),
          StatusBadge(
            label: _categoryLabel(category ?? AttendanceCategory.absent),
            color: switch (category) {
              AttendanceCategory.early => tokens.brand,
              AttendanceCategory.onTime => tokens.infoLight,
              AttendanceCategory.late => tokens.danger,
              _ => tokens.textMuted,
            },
          ),
        ],
      ),
    );
  }

  void _showAll(BuildContext context, _Data data) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final members = data.members.isEmpty ? _fallbackMembers(data) : data.members;
    final visible =
        members.where((m) => _matchesFilter(m, data)).toList();
    showModalBottomSheet<void>(
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
                Text('قائمة اليوم (${visible.length})',
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                Text('حاضر ${visible.where((m) => m.present).length}',
                    style: TextStyle(
                        color: tokens.brandText,
                        fontWeight: FontWeight.w800)),
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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(icon: Icons.edit_note, title: 'التسجيل'),
          const SizedBox(height: 10),
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

  Widget _summarySection(BuildContext context, _Data data) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final present = data.attendance.length;
    final total = data.session.total > present ? data.session.total : present;
    final absent = total - present;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(icon: Icons.summarize_outlined, title: 'محصلة اليوم'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$present',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: tokens.brandText)),
                    Text('حاضر',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: tokens.textMuted)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$absent',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: tokens.textMuted)),
                    Text('غائب',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: tokens.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Drawn summary: stacked present/absent bar.
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  Expanded(
                    flex: present,
                    child: Container(color: tokens.brand),
                  ),
                  Expanded(
                    flex: absent,
                    child: Container(color: tokens.surfaceSubtle),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.circle, size: 10, color: tokens.brand),
              const SizedBox(width: 4),
              Text('حضور',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: tokens.textMuted)),
              const SizedBox(width: 14),
              Icon(Icons.circle, size: 10, color: tokens.textMuted),
              const SizedBox(width: 4),
              Text('غياب',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: tokens.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _messagesSection(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(icon: Icons.chat_outlined, title: 'الرسائل والتصدير'),
          const SizedBox(height: 6),
          for (final label in const ['رسائل اليوم', 'تصدير حضور اليوم'])
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.send_outlined, color: tokens.brandText),
              title: Text(label),
              trailing:
                  Icon(Icons.chevron_left, color: tokens.borderStructural),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label — يتطلب ربط الخادم')),
              ),
            ),
        ],
      ),
    );
  }

  String _categoryLabel(AttendanceCategory c) => switch (c) {
        AttendanceCategory.early => 'مبكر',
        AttendanceCategory.onTime => 'في الوقت',
        AttendanceCategory.late => 'متأخر',
        AttendanceCategory.absent => 'غائب',
      };

  Future<void> _editSession(BuildContext context, _Data data) async {
    final repo = AdminRepositoryScope.of(context);
    final s = data.session;
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
      data.session.id,
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

class _Data {
  const _Data({
    required this.session,
    required this.attendance,
    required this.members,
  });

  final AdminSessionRow session;
  final List<AdminAttendanceRow> attendance;
  final List<AdminSessionMember> members;
}
