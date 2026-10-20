import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/icon_toggle_group.dart';
import '../../../../core/widgets/search_picker_field.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../student/domain/models/student_models.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';
import '../widgets/session_setup_sheet.dart';
import '../widgets/student_picker_field.dart';

/// E2 — Admin course page: overview card + 4 sections (sessions · messages &
/// export · exams · top students).
class AdminCourseDetailScreen extends StatefulWidget {
  const AdminCourseDetailScreen({super.key, required this.courseId});

  final int courseId;

  @override
  State<AdminCourseDetailScreen> createState() =>
      _AdminCourseDetailScreenState();
}

class _AdminCourseDetailScreenState extends State<AdminCourseDetailScreen> {
  late Future<_Data> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_Data> _load() async {
    final repo = AdminRepositoryScope.of(context);
    final summaries = await repo.courses();
    final summary = summaries.where((c) => c.id == widget.courseId).firstOrNull;
    return _Data(
      summary: summary,
      sessions: await repo.courseSessions(widget.courseId),
      exams: await repo.courseExams(widget.courseId),
      leaderboard: (await repo.leaderboard(widget.courseId)).entries,
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
      builder: (context, data) => DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text(data.summary?.name ?? 'الدورة'),
            bottom: const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: 'الجلسات'),
                Tab(text: 'الرسائل والتصدير'),
                Tab(text: 'الامتحانات'),
                Tab(text: 'الطلاب الأوائل'),
              ],
            ),
          ),
          body: Column(
            children: [
              if (data.summary != null) _overviewCard(context, data.summary!),
              Expanded(
                child: TabBarView(
                  children: [
                    _sessionsTab(context, data),
                    _messagesTab(context),
                    _examsTab(context, data),
                    _leaderboardTab(context, data),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overviewCard(BuildContext context, AdminCourseSummary c) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                _ov(context, 'اليوم', '${c.todayPresent}/${c.todayTotal}'),
                _ov(context, 'طلاب', '${c.studentsCount}'),
                _ov(context, 'جلسات', '${c.sessionsCount}'),
                _ov(context, 'حضور', '${c.attendancePercent}%'),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                StatusBadge(
                    label: c.isActive ? 'نشطة' : 'منتهية',
                    color: c.isActive ? tokens.brand : tokens.textMuted),
                const Spacer(),
                Text('${formatDate(c.startDate)} – ${formatDate(c.endDate)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: tokens.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _ov(BuildContext context, String label, String value) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900, color: tokens.info)),
          const SizedBox(height: 2),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: tokens.textMuted)),
        ],
      ),
    );
  }

  Widget _sessionsTab(BuildContext context, _Data data) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppButton(
          label: 'إنشاء جلسة اليوم',
          icon: Icons.today_outlined,
          onPressed: () async {
            final repo = AdminRepositoryScope.of(context);
            final last = data.sessions.isEmpty ? null : data.sessions.last;
            final id = await repo.addSession(widget.courseId, DateTime.now());
            if (!context.mounted) return;
            _reload();
            // Show the thresholds right away, prefilled with the last
            // session's values (BR-402).
            final setup = await showSessionSetupSheet(
              context,
              title: 'إعداد الجلسة الجديدة',
              initial: SessionSetupValues(
                earlyPoints: last?.earlyPoints ?? 3,
                midPoints: last?.midPoints ?? 2,
                latePoints: last?.latePoints ?? 1,
                earlyUntil: last?.earlyUntil ?? '16:00',
                lateFrom: last?.lateFrom ?? '16:30',
                date: DateTime.now(),
              ),
            );
            if (setup != null) {
              await repo.updateSession(
                id,
                earlyPoints: setup.earlyPoints,
                midPoints: setup.midPoints,
                latePoints: setup.latePoints,
                earlyUntil: setup.earlyUntil,
                lateFrom: setup.lateFrom,
                date: setup.date,
              );
            }
            if (!context.mounted) return;
            context.push('/admin/sessions/$id');
          },
        ),
        const SizedBox(height: 16),
        const SectionHeader(icon: Icons.event_note_outlined, title: 'الجلسات'),
        const SizedBox(height: 8),
        if (data.sessions.isEmpty)
          const Padding(
              padding: EdgeInsets.all(16), child: Center(child: Text('لا جلسات بعد')))
        else
          for (final s in data.sessions.reversed) ...[
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onTap: () => context.push('/admin/sessions/${s.id}'),
              child: Row(
                children: [
                  Icon(Icons.event, color: tokens.brand),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('جلسة #${s.index} · ${formatDate(s.date)}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  Text('حاضر ${s.present}/${s.total}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: tokens.textMuted)),
                  const SizedBox(width: 6),
                  Icon(Icons.chevron_left, color: tokens.borderStructural),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }

  Widget _messagesTab(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(icon: Icons.chat_outlined, title: 'الرسائل والتصدير'),
        const SizedBox(height: 8),
        for (final item in const [
          (icon: Icons.today_outlined, label: 'رسائل اليوم'),
          (icon: Icons.date_range_outlined, label: 'رسائل الدورة'),
          (icon: Icons.file_download_outlined, label: 'تصدير رسائل (xlsx)'),
          (icon: Icons.table_chart_outlined, label: 'تصدير كشوف التقارير'),
        ]) ...[
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            onTap: () => _serverNotice(context, item.label),
            child: Row(
              children: [
                Icon(item.icon, color: tokens.brandText),
                const SizedBox(width: 12),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(item.label),
                )),
                Icon(Icons.chevron_left, color: tokens.borderStructural),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  void _serverNotice(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — يتطلب ربط الخادم (مؤجّل في النسخة التجريبية)')),
    );
  }

  Widget _examsTab(BuildContext context, _Data data) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppButton(
          label: 'إضافة امتحان',
          icon: Icons.add,
          onPressed: () => _addExam(context),
        ),
        const SizedBox(height: 16),
        const SectionHeader(icon: Icons.assignment_outlined, title: 'الامتحانات'),
        const SizedBox(height: 8),
        if (data.exams.isEmpty)
          const Padding(
              padding: EdgeInsets.all(16), child: Center(child: Text('لا امتحانات')))
        else
          for (final e in data.exams) ...[
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onTap: () => _examDetail(context, e),
              child: Row(
                children: [
                  Icon(Icons.edit_note, color: tokens.accentMatn),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        Text(e.subtitle ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: tokens.textMuted)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_left, color: tokens.borderStructural),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }

  /// Exam detail + edit (tap to open, BR-802 fields editable) + submissions.
  Future<void> _examDetail(BuildContext context, AdminContentItem item) async {
    final repo = AdminRepositoryScope.of(context);
    final detail = await repo.examDetail(item.id);
    if (!context.mounted || detail == null) return;
    final subject = TextEditingController(text: detail.subjectName);
    final maxMark = TextEditingController(text: '${detail.maxMark}');
    final minSuccess = TextEditingController(text: '${detail.minSuccessMark}');
    final points = TextEditingController(text: '${detail.points}');
    var type = detail.type;
    var submissions = await repo.examSubmissions(detail.id);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 0,
            bottom: 28 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text('تفاصيل الامتحان',
                        style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    IconButton(
                      tooltip: 'حذف الامتحان',
                      icon: const Icon(Icons.delete_outline),
                      color: Theme.of(context).extension<AppTokens>()!.danger,
                      onPressed: () async {
                        await repo.deleteExam(detail.id);
                        if (context.mounted) Navigator.of(context).pop();
                        _reload();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                    controller: subject,
                    decoration: const InputDecoration(labelText: 'المادة')),
                const SizedBox(height: 12),
                IconToggleGroup<String>(
                  value: type,
                  onChanged: (v) => setSheetState(() => type = v),
                  options: const [
                    IconToggleOption(
                      value: 'oral',
                      icon: Icons.record_voice_over_outlined,
                      label: 'شفهي',
                    ),
                    IconToggleOption(
                      value: 'writtenProbe',
                      icon: Icons.description_outlined,
                      label: 'سبر كتابي',
                    ),
                    IconToggleOption(
                      value: 'final',
                      icon: Icons.emoji_events_outlined,
                      label: 'اختبار نهائي',
                      color: Color(0xFFF59E0B),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                          controller: maxMark,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'الدرجة القصوى')),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                          controller: minSuccess,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'درجة النجاح')),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                    controller: points,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'النقاط')),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('التقديمات (${submissions.length})',
                        style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _addSubmission(
                          context, detail, () async {
                        submissions = await repo.examSubmissions(detail.id);
                        if (mounted) setSheetState(() {});
                      }),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('إضافة تقديم'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (submissions.isEmpty)
                  Text('لا تقديمات بعد',
                      style: Theme.of(context).textTheme.bodyMedium)
                else
                  for (final s in submissions)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text(s.studentName)),
                          Text(
                            '${_fmtMark(s.mark)} / ${detail.maxMark}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'حفظ التعديلات',
                  onPressed: () async {
                    if (subject.text.trim().isEmpty) return;
                    await repo.updateExam(
                      detail.id,
                      subjectName: subject.text.trim(),
                      type: type,
                      maxMark: int.tryParse(maxMark.text) ?? detail.maxMark,
                      minSuccessMark: int.tryParse(minSuccess.text) ??
                          detail.minSuccessMark,
                      points: int.tryParse(points.text) ?? detail.points,
                    );
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted) return;
    _reload();
  }

  String _fmtMark(double mark) =>
      mark == mark.roundToDouble() ? '${mark.toInt()}' : '$mark';

  /// Adds a student's mark for an exam (BR-803/804).
  Future<void> _addSubmission(
    BuildContext context,
    AdminExamDetail detail,
    Future<void> Function() onSaved,
  ) async {
    final repo = AdminRepositoryScope.of(context);
    AdminStudentRow? student;
    final mark = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 0,
            bottom: 28 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('إضافة تقديم',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              StudentPickerField(
                label: 'اختر الطالب',
                selected: student,
                onChanged: (s) => setSheetState(() => student = s),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: mark,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'العلامة',
                  hintText: 'من 0 إلى ${detail.maxMark}',
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'حفظ التقديم',
                onPressed: () async {
                  final s = student;
                  final m = double.tryParse(mark.text);
                  if (s == null || m == null) return;
                  await repo.addExamSubmission(detail.id, s.id, m);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    await onSaved();
  }

  Future<void> _addExam(BuildContext context) async {
    final repo = AdminRepositoryScope.of(context);
    final subjects = await repo.subjects();
    if (!context.mounted) return;
    final maxMark = TextEditingController(text: '100');
    final minSuccess = TextEditingController(text: '50');
    final points = TextEditingController(text: '0');
    String subjectName =
        subjects.isEmpty ? '' : subjects.first.name;
    var type = 'final';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 0,
            bottom: 28 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('امتحان جديد',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                // Subject: pick from the mosque subjects (BR-802).
                SearchPickerField<String>(
                  label: 'اختر المادة',
                  items: subjects.map((s) => s.name).toList(),
                  titleBuilder: (name) => name,
                  subtitleBuilder: null,
                  value: subjectName.isEmpty ? null : subjectName,
                  onChanged: (name) =>
                      setSheetState(() => subjectName = name),
                ),
                const SizedBox(height: 12),
                Text('النوع',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Theme.of(context)
                            .extension<AppTokens>()!
                            .textMuted)),
                const SizedBox(height: 6),
                IconToggleGroup<String>(
                  value: type,
                  onChanged: (v) => setSheetState(() => type = v),
                  options: const [
                    IconToggleOption(
                      value: 'oral',
                      icon: Icons.record_voice_over_outlined,
                      label: 'شفهي',
                    ),
                    IconToggleOption(
                      value: 'writtenProbe',
                      icon: Icons.description_outlined,
                      label: 'سبر كتابي',
                    ),
                    IconToggleOption(
                      value: 'final',
                      icon: Icons.emoji_events_outlined,
                      label: 'اختبار نهائي',
                      color: Color(0xFFF59E0B),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                          controller: maxMark,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'الدرجة القصوى')),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                          controller: minSuccess,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'درجة النجاح')),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                    controller: points,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'النقاط')),
                const SizedBox(height: 16),
                AppButton(
                  label: 'إنشاء',
                  onPressed: () async {
                    if (subjectName.trim().isEmpty) return;
                    await repo.addExam(
                      courseId: widget.courseId,
                      subjectName: subjectName.trim(),
                      type: type,
                      maxMark: int.tryParse(maxMark.text) ?? 100,
                      minSuccessMark:
                          int.tryParse(minSuccess.text) ?? 50,
                      points: int.tryParse(points.text) ?? 0,
                    );
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted) return;
    _reload();
  }

  Widget _leaderboardTab(BuildContext context, _Data data) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    if (data.leaderboard.isEmpty) {
      return const Center(child: Text('لا طلاب بعد'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.leaderboard.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'ترتيب طلاب الدورة حسب المحصلة — اضغط أي طالب لفتح ملفه',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: tokens.textMuted),
            ),
          );
        }
        final e = data.leaderboard[i - 1];
        return _LeaderboardRow(entry: e);
      },
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry});

  final StudentLeaderboardEntry entry;

  (IconData icon, Color color, bool top) _medal(AppTokens tokens) {
    switch (entry.rank) {
      case 1:
        return (Icons.emoji_events, tokens.reward, true);
      case 2:
        return (Icons.emoji_events, Color(0xFF9AA5B1), true);
      case 3:
        return (Icons.emoji_events, Color(0xFFB08968), true);
      default:
        return (Icons.person_outline, tokens.textMuted, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final (icon, color, top) = _medal(tokens);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        color: top ? tokens.reward.withValues(alpha: 0.10) : null,
        borderColor: top ? tokens.reward.withValues(alpha: 0.4) : null,
        onTap: () => context.push('/admin/students/${entry.student.id}'),
        child: Row(
          children: [
            SizedBox(
              width: 26,
              child: Text('${entry.rank}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: top ? tokens.rewardText : tokens.textMuted)),
            ),
            CircleAvatar(
              radius: 16,
              backgroundColor: top ? tokens.reward.withValues(alpha: 0.2) : tokens.brandTint,
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(entry.student.name)),
            Text('${entry.points}',
                style: TextStyle(
                    fontWeight: FontWeight.w900, color: tokens.rewardText)),
            const SizedBox(width: 4),
            Text('نقطة',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: tokens.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _Data {
  const _Data({
    required this.summary,
    required this.sessions,
    required this.exams,
    required this.leaderboard,
  });

  final AdminCourseSummary? summary;
  final List<AdminSessionRow> sessions;
  final List<AdminContentItem> exams;
  final List<StudentLeaderboardEntry> leaderboard;
}
