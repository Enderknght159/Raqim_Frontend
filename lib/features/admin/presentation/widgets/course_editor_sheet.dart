import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/number_stepper.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

enum CourseEditorResult { saved, deleted }

/// Opens the course editor (E2): identity, dates and points criteria.
/// Returns [CourseEditorResult] when something changed.
Future<CourseEditorResult?> showCourseEditorSheet(
  BuildContext context, {
  required AdminCourseSummary course,
}) {
  return showAppSheet<CourseEditorResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => CourseEditorSheet(course: course),
  );
}

class CourseEditorSheet extends StatefulWidget {
  const CourseEditorSheet({super.key, required this.course});

  final AdminCourseSummary course;

  @override
  State<CourseEditorSheet> createState() => _CourseEditorSheetState();
}

class _CourseEditorSheetState extends State<CourseEditorSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.course.name,
  );
  late DateTime _startDate = widget.course.startDate;
  late DateTime _endDate = widget.course.endDate;
  late int _goodPoints = widget.course.goodPoints;
  late int _veryGoodPoints = widget.course.veryGoodPoints;
  late int _excellentPoints = widget.course.excellentPoints;
  late int _certificatePoints = widget.course.certificatePoints;
  String _error = '';

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool start}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: start ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _error = '';
      if (start) {
        _startDate = picked;
        if (_endDate.isBefore(picked)) {
          _endDate = picked.add(const Duration(days: 30));
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'أدخل اسم الدورة');
      return;
    }
    if (!_endDate.isAfter(_startDate)) {
      setState(() => _error = 'تاريخ النهاية يجب أن يكون بعد تاريخ البداية');
      return;
    }
    await AdminRepositoryScope.of(context).updateCourse(
      widget.course.id,
      name: name,
      startDate: _startDate,
      endDate: _endDate,
      goodPoints: _goodPoints,
      veryGoodPoints: _veryGoodPoints,
      excellentPoints: _excellentPoints,
      certificatePoints: _certificatePoints,
    );
    if (!mounted) return;
    Navigator.of(context).pop(CourseEditorResult.saved);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الدورة'),
        content: Text(
          'سيتم حذف «${widget.course.name}» مع كل جلساتها وسجلاتها '
          'وامتحاناتها وشهاداتها. لا يمكن التراجع عن هذا الإجراء.',
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
    await AdminRepositoryScope.of(context).deleteCourse(widget.course.id);
    if (!mounted) return;
    Navigator.of(context).pop(CourseEditorResult.deleted);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'تعديل الدورة',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'الاسم والتواريخ ومعايير النقاط.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'اسم الدورة'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _dateField(
                    context,
                    label: 'البداية',
                    date: _startDate,
                    onTap: () => _pickDate(start: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _dateField(
                    context,
                    label: 'النهاية',
                    date: _endDate,
                    onTap: () => _pickDate(start: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SectionHeader(
              icon: Icons.stars_outlined,
              title: 'معايير النقاط',
            ),
            const SizedBox(height: 4),
            Text(
              'نقاط الحفظ حسب تقييم التسميع (BR-304) ونقاط الشهادة لكل جزء.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
            ),
            const SizedBox(height: 8),
            _stepperRow(
              context,
              label: 'تقييم جيد',
              value: _goodPoints,
              onChanged: (v) => setState(() => _goodPoints = v),
            ),
            _stepperRow(
              context,
              label: 'تقييم جيد جدًا',
              value: _veryGoodPoints,
              onChanged: (v) => setState(() => _veryGoodPoints = v),
            ),
            _stepperRow(
              context,
              label: 'تقييم ممتاز',
              value: _excellentPoints,
              onChanged: (v) => setState(() => _excellentPoints = v),
            ),
            _stepperRow(
              context,
              label: 'نقاط الشهادة',
              value: _certificatePoints,
              min: 0,
              max: 50,
              onChanged: (v) => setState(() => _certificatePoints = v),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                _error,
                style: TextStyle(color: tokens.dangerText, fontSize: 13),
              ),
            ],
            const SizedBox(height: 16),
            AppButton(label: 'حفظ التعديلات', onPressed: _save),
            const SizedBox(height: 8),
            AppButton(
              label: 'حذف الدورة',
              variant: AppButtonVariant.dangerOutline,
              icon: Icons.delete_outline,
              onPressed: _delete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField(
    BuildContext context, {
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return InkWell(
      borderRadius: BorderRadius.circular(tokens.radiusSmall),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: tokens.surfaceSubtle,
          borderRadius: BorderRadius.circular(tokens.radiusSmall),
          border: Border.all(color: tokens.borderStructural),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_outlined, size: 15, color: tokens.info),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              formatDate(date),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepperRow(
    BuildContext context, {
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
    int min = 0,
    int max = 10,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          NumberStepper(
            value: value,
            min: min,
            max: max,
            color: tokens.brandText,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
