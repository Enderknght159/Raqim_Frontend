import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/icon_toggle_group.dart';
import '../../../../core/widgets/progress_bar.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/search_picker_field.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';
import '../widgets/student_picker_field.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

/// E2x — Full exam page replacing the old bottom sheet: general stats,
/// submissions (add · edit · delete · sorted highest first) and exam editing.
class AdminExamScreen extends StatefulWidget {
  const AdminExamScreen({
    super.key,
    required this.courseId,
    required this.examId,
  });

  final int courseId;
  final int examId;

  @override
  State<AdminExamScreen> createState() => _AdminExamScreenState();
}

class _AdminExamScreenState extends State<AdminExamScreen> {
  late Future<_ExamData> _future;
  bool _showAllSubmissions = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ExamData> _load() async {
    final repo = AdminRepositoryScope.of(context);
    final detailF = repo.examDetail(widget.examId);
    final submissionsF = repo.examSubmissions(widget.examId);
    final subjectsF = repo.subjects();
    final detail = await detailF;
    final submissions = await submissionsF;
    final subjects = await subjectsF;
    return _ExamData(
      detail: detail,
      submissions: submissions,
      subjects: subjects,
    );
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AsyncView<_ExamData>(
      future: _future,
      cacheKey: 'admin-exam-${widget.examId}',
      builder: (context, data) {
        final detail = data.detail;
        if (detail == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('الامتحان')),
            body: const Center(child: Text('الامتحان غير موجود')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(detail.subjectName),
                Text(
                  '${formatDate(detail.date)} · ${_typeLabel(detail.type)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).extension<AppTokens>()!.textMuted,
                  ),
                ),
              ],
            ),
          ),
          body: ResponsivePage(
            maxWidth: 1100,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _statsCard(context, detail, data.submissions),
                const SizedBox(height: 12),
                _submissionsCard(context, detail, data.submissions),
                const SizedBox(height: 12),
                _ExamEditorCard(
                  key: ValueKey(detail.id),
                  detail: detail,
                  subjects: data.subjects,
                  onSaved: () {
                    _reload();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حفظ تعديلات الامتحان')),
                    );
                  },
                  onDeleted: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Stats ───────────────────────────────────────────────────────────────

  Widget _statsCard(
    BuildContext context,
    AdminExamDetail detail,
    List<AdminSubmissionRow> submissions,
  ) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final count = submissions.length;
    final average = count == 0
        ? 0.0
        : submissions.map((s) => s.mark).reduce((a, b) => a + b) / count;
    final passed = submissions
        .where((s) => s.mark >= detail.minSuccessMark)
        .length;
    final passPercent = count == 0 ? 0 : ((passed / count) * 100).round();
    final highest = count == 0 ? 0.0 : submissions.first.mark; // sorted desc
    final lowest = count == 0
        ? 0.0
        : submissions.map((s) => s.mark).reduce((a, b) => a < b ? a : b);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            icon: Icons.insights_outlined,
            title: 'إحصاءات الامتحان',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _stat(context, 'عدد التقديمات', '$count', tokens.info),
              _stat(
                context,
                'المتوسط',
                _fmtMark(double.parse(average.toStringAsFixed(1))),
                tokens.accentMatn,
              ),
              _stat(
                context,
                'النجاح',
                '$passPercent%',
                passed == count && count > 0 ? tokens.brand : tokens.info,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _stat(
                context,
                'أعلى علامة',
                '${_fmtMark(highest)}/${detail.maxMark}',
                tokens.brand,
              ),
              _stat(
                context,
                'أدنى علامة',
                '${_fmtMark(lowest)}/${detail.maxMark}',
                tokens.danger,
              ),
              _stat(
                context,
                'درجة النجاح',
                '${detail.minSuccessMark}',
                tokens.textSecondary,
              ),
            ],
          ),
          if (count > 0) ...[
            const SizedBox(height: 12),
            ProgressBar(
              value: passPercent / 100,
              color: tokens.brand,
              height: 8,
            ),
          ],
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value, Color color) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
          ),
        ],
      ),
    );
  }

  // ── Submissions ─────────────────────────────────────────────────────────

  Widget _submissionsCard(
    BuildContext context,
    AdminExamDetail detail,
    List<AdminSubmissionRow> submissions,
  ) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final visible = _showAllSubmissions
        ? submissions
        : submissions.take(5).toList();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: SectionHeader(
                  icon: Icons.fact_check_outlined,
                  title: 'التقديمات',
                ),
              ),
              StatusBadge(
                label: '${submissions.length}',
                color: tokens.accentMatn,
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'إضافة تقديم',
            icon: Icons.add,
            onPressed: () => _addSubmission(detail),
          ),
          const SizedBox(height: 10),
          if (submissions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'لا تقديمات بعد',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else ...[
            Text(
              'مرتبة من الأعلى علامة إلى الأدنى',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
            ),
            const SizedBox(height: 4),
            for (var i = 0; i < visible.length; i++)
              _submissionRow(context, detail, visible[i], rank: i + 1),
            if (submissions.length > 5)
              Center(
                child: TextButton(
                  onPressed: () => setState(
                    () => _showAllSubmissions = !_showAllSubmissions,
                  ),
                  child: Text(
                    _showAllSubmissions
                        ? 'عرض أقل'
                        : 'عرض المزيد (${submissions.length})',
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _submissionRow(
    BuildContext context,
    AdminExamDetail detail,
    AdminSubmissionRow s, {
    required int rank,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final passed = s.mark >= detail.minSuccessMark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radiusSmall),
        onTap: () => _editSubmission(detail, s),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: tokens.textMuted,
                ),
              ),
            ),
            CircleAvatar(
              radius: 16,
              backgroundColor: tokens.brandTint,
              child: Text(
                s.studentName.characters.first,
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
                    s.studentName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (s.date != null)
                    Text(
                      formatDate(s.date!),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                    ),
                ],
              ),
            ),
            Text(
              '${_fmtMark(s.mark)}/${detail.maxMark}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: passed ? tokens.brandText : tokens.dangerText,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.edit_outlined, size: 18, color: tokens.textMuted),
          ],
        ),
      ),
    );
  }

  Future<void> _addSubmission(AdminExamDetail detail) async {
    final repo = AdminRepositoryScope.of(context);
    AdminStudentRow? student;
    final mark = TextEditingController();
    var error = '';
    final saved = await showAppSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final tokens = Theme.of(context).extension<AppTokens>()!;
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 24 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'إضافة تقديم',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 14),
                StudentPickerField(
                  label: 'اختر الطالب',
                  selected: student,
                  onChanged: (s) => setSheetState(() => student = s),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: mark,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) {
                    if (error.isNotEmpty) setSheetState(() => error = '');
                  },
                  decoration: InputDecoration(
                    labelText: 'العلامة',
                    hintText: 'من 0 إلى ${detail.maxMark}',
                    errorText: error.isEmpty ? null : error,
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'حفظ التقديم',
                  onPressed: () async {
                    final s = student;
                    final m = double.tryParse(mark.text.trim());
                    if (s == null) {
                      setSheetState(() => error = 'اختر الطالب أولًا');
                      return;
                    }
                    if (m == null || m < 0 || m > detail.maxMark) {
                      setSheetState(
                        () => error = 'أدخل علامة بين 0 و ${detail.maxMark}',
                      );
                      return;
                    }
                    await repo.addExamSubmission(detail.id, s.id, m);
                    if (context.mounted) Navigator.of(context).pop(true);
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  'إذا كان للطالب تقديم سابق فسيتم تحديثه.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          );
        },
      ),
    );
    if (saved == true && mounted) _reload();
  }

  Future<void> _editSubmission(
    AdminExamDetail detail,
    AdminSubmissionRow s,
  ) async {
    final repo = AdminRepositoryScope.of(context);
    final mark = TextEditingController(text: _fmtMark(s.mark));
    var error = '';
    final result = await showAppSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final tokens = Theme.of(context).extension<AppTokens>()!;
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 24 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  s.studentName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${detail.subjectName} · الدرجة القصوى ${detail.maxMark}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: mark,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) {
                    if (error.isNotEmpty) setSheetState(() => error = '');
                  },
                  decoration: InputDecoration(
                    labelText: 'العلامة',
                    errorText: error.isEmpty ? null : error,
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'حفظ',
                  onPressed: () async {
                    final m = double.tryParse(mark.text.trim());
                    if (m == null || m < 0 || m > detail.maxMark) {
                      setSheetState(
                        () => error = 'أدخل علامة بين 0 و ${detail.maxMark}',
                      );
                      return;
                    }
                    await repo.updateExamSubmission(s.id, m);
                    if (context.mounted) Navigator.of(context).pop('saved');
                  },
                ),
                const SizedBox(height: 8),
                AppButton(
                  label: 'حذف التقديم',
                  variant: AppButtonVariant.dangerOutline,
                  onPressed: () async {
                    await repo.deleteExamSubmission(s.id);
                    if (context.mounted) Navigator.of(context).pop('saved');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
    if (result == 'saved' && mounted) _reload();
  }

  String _fmtMark(double mark) =>
      mark == mark.roundToDouble() ? '${mark.toInt()}' : '$mark';

  static String _typeLabel(String type) => switch (type) {
    'oral' => 'شفهي',
    'writtenProbe' => 'سبر كتابي',
    'final' => 'اختبار نهائي',
    _ => type,
  };
}

class _ExamData {
  const _ExamData({
    required this.detail,
    required this.submissions,
    required this.subjects,
  });

  final AdminExamDetail? detail;
  final List<AdminSubmissionRow> submissions;
  final List<AdminContentItem> subjects;
}

/// Exam editor: identity + grading fields, save and (danger) delete.
class _ExamEditorCard extends StatefulWidget {
  const _ExamEditorCard({
    super.key,
    required this.detail,
    required this.subjects,
    required this.onSaved,
    required this.onDeleted,
  });

  final AdminExamDetail detail;
  final List<AdminContentItem> subjects;
  final VoidCallback onSaved;
  final VoidCallback onDeleted;

  @override
  State<_ExamEditorCard> createState() => _ExamEditorCardState();
}

class _ExamEditorCardState extends State<_ExamEditorCard> {
  late String _subject = widget.detail.subjectName;
  late final _maxMark = TextEditingController(text: '${widget.detail.maxMark}');
  late final _minSuccess = TextEditingController(
    text: '${widget.detail.minSuccessMark}',
  );
  late final _points = TextEditingController(text: '${widget.detail.points}');
  late String _type = widget.detail.type;
  String _error = '';

  @override
  void dispose() {
    _maxMark.dispose();
    _minSuccess.dispose();
    _points.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final subject = _subject.trim();
    final maxMark = int.tryParse(_maxMark.text.trim());
    final minSuccess = int.tryParse(_minSuccess.text.trim());
    final points = int.tryParse(_points.text.trim());
    if (subject.isEmpty) {
      setState(() => _error = 'اختر المادة أولًا');
      return;
    }
    if (maxMark == null || maxMark <= 0) {
      setState(() => _error = 'أدخل درجة قصوى صحيحة');
      return;
    }
    if (minSuccess == null || minSuccess < 0 || minSuccess > maxMark) {
      setState(() => _error = 'درجة النجاح يجب أن تكون بين 0 والدرجة القصوى');
      return;
    }
    setState(() => _error = '');
    await AdminRepositoryScope.of(context).updateExam(
      widget.detail.id,
      subjectName: subject,
      type: _type,
      maxMark: maxMark,
      minSuccessMark: minSuccess,
      points: points ?? widget.detail.points,
    );
    if (!mounted) return;
    widget.onSaved();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الامتحان'),
        content: const Text(
          'سيُحذف الامتحان مع كل تقديماته. هل تريد المتابعة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await AdminRepositoryScope.of(context).deleteExam(widget.detail.id);
    if (!mounted) return;
    widget.onDeleted();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            icon: Icons.tune_outlined,
            title: 'بيانات الامتحان',
          ),
          const SizedBox(height: 10),
          // Subject: picked from the mosque subjects (never free text).
          SearchPickerField<String>(
            label: 'اختر المادة',
            items: {
              ...widget.subjects.map((s) => s.name),
              widget.detail.subjectName,
            }.toList(),
            titleBuilder: (name) => name,
            subtitleBuilder: null,
            value: _subject.isEmpty ? null : _subject,
            onChanged: (name) => setState(() => _subject = name),
          ),
          const SizedBox(height: 10),
          Text(
            'النوع',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
          ),
          const SizedBox(height: 6),
          IconToggleGroup<String>(
            value: _type,
            onChanged: (v) => setState(() => _type = v),
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
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _maxMark,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الدرجة القصوى'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _minSuccess,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'درجة النجاح'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _points,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'النقاط'),
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              _error,
              style: TextStyle(color: tokens.dangerText, fontSize: 13),
            ),
          ],
          const SizedBox(height: 14),
          AppButton(label: 'حفظ التعديلات', onPressed: _save),
          const SizedBox(height: 8),
          AppButton(
            label: 'حذف الامتحان',
            variant: AppButtonVariant.dangerOutline,
            icon: Icons.delete_outline,
            onPressed: _delete,
          ),
        ],
      ),
    );
  }
}
