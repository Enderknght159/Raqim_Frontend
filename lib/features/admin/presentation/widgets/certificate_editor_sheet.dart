import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/icon_toggle_group.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';
import 'student_picker_field.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

/// Opens the certificate editor (E2 «الشهادات» tab). Returns `true` when a
/// certificate was added / updated / deleted so the caller reloads.
Future<bool?> showCertificateEditorSheet(
  BuildContext context, {
  required int courseId,
  required int certificatePoints,
  AdminCertificateRow? existing,
}) {
  return showAppSheet<bool>(
    context: context,
    maxWidth: 640,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => CertificateEditorSheet(
      courseId: courseId,
      certificatePoints: certificatePoints,
      existing: existing,
    ),
  );
}

/// Add / edit one Quran certificate: student + a juz **range** picked from a
/// grid (multi-select collapses to a contiguous range), mark, by-heart and
/// date. Shows the automatic points preview.
class CertificateEditorSheet extends StatefulWidget {
  const CertificateEditorSheet({
    super.key,
    required this.courseId,
    required this.certificatePoints,
    this.existing,
  });

  final int courseId;
  final int certificatePoints;
  final AdminCertificateRow? existing;

  @override
  State<CertificateEditorSheet> createState() => _CertificateEditorSheetState();
}

class _CertificateEditorSheetState extends State<CertificateEditorSheet> {
  AdminStudentRow? _student;
  int? _rangeStart;
  int? _rangeEnd;
  late final TextEditingController _mark;
  late bool _byHeart;
  late DateTime _date;
  String _error = '';

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _mark = TextEditingController(text: e == null ? '' : '${e.mark}');
    _byHeart = e?.byHeart ?? true;
    _date = e?.date ?? DateTime.now();
    if (e != null) {
      _student = AdminStudentRow(
        id: e.studentId,
        name: e.studentName,
        teamNames: '',
      );
      _rangeStart = e.startJuz;
      _rangeEnd = e.endJuz;
    }
  }

  @override
  void dispose() {
    _mark.dispose();
    super.dispose();
  }

  int? get _from => _rangeStart;

  int? get _to => _rangeEnd ?? _rangeStart;

  int get _juzCount => _from == null || _to == null ? 0 : (_to! - _from! + 1);

  int get _previewPoints {
    final mark = int.tryParse(_mark.text) ?? 0;
    return ((mark / 100) * widget.certificatePoints * _juzCount).round();
  }

  void _tapJuz(int juz) {
    setState(() {
      _error = '';
      if (_rangeStart == null) {
        _rangeStart = juz;
        _rangeEnd = null;
      } else if (_rangeEnd == null) {
        if (juz < _rangeStart!) {
          // Started at the wrong end: restart from the tapped juz.
          _rangeStart = juz;
          _rangeEnd = null;
        } else {
          _rangeEnd = juz;
        }
      } else {
        // A full range existed: start a new one at this juz.
        _rangeStart = juz;
        _rangeEnd = null;
      }
    });
  }

  bool _inRange(int juz) =>
      _from != null && _to != null && juz >= _from! && juz <= _to!;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final repo = AdminRepositoryScope.of(context);
    final student = _student;
    final mark = int.tryParse(_mark.text.trim());
    if (student == null) {
      setState(() => _error = 'اختر الطالب أولًا');
      return;
    }
    if (_from == null || _to == null) {
      setState(() => _error = 'اختر نطاق الأجزاء من الشبكة');
      return;
    }
    if (mark == null || mark < 0 || mark > 100) {
      setState(() => _error = 'أدخل درجة بين 0 و 100');
      return;
    }
    if (_isEdit) {
      await repo.updateCertificate(
        widget.existing!.id,
        studentId: student.id,
        courseId: widget.courseId,
        startJuz: _from!,
        endJuz: _to!,
        mark: mark,
        byHeart: _byHeart,
        date: _date,
      );
    } else {
      await repo.addCertificate(
        studentId: student.id,
        courseId: widget.courseId,
        startJuz: _from!,
        endJuz: _to!,
        mark: mark,
        byHeart: _byHeart,
        date: _date,
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الشهادة'),
        content: const Text('هل تريد حذف هذه الشهادة نهائيًا؟'),
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
    await AdminRepositoryScope.of(
      context,
    ).deleteCertificate(widget.existing!.id);
    if (!mounted) return;
    Navigator.of(context).pop(true);
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
              _isEdit ? 'تعديل شهادة' : 'شهادة قرآن جديدة',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 14),
            StudentPickerField(
              label: 'اختر الطالب',
              selected: _student,
              onChanged: (s) => setState(() => _student = s),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'الأجزاء',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
                const Spacer(),
                if (_from != null)
                  Text(
                    _juzCount <= 1
                        ? 'الجزء ${_from!}'
                        : 'الجزء ${_from!} – ${_to!} ($_juzCount أجزاء)',
                    style: TextStyle(
                      color: tokens.brandText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'اضغط بداية النطاق ثم نهايته (اختيار متعدد بنطاق متصل).',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 6,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.45,
              children: [
                for (var juz = 1; juz <= 30; juz++) _juzCell(context, juz),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mark,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'الدرجة',
                      suffixText: '/ 100',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event_outlined, size: 18),
                    label: Text('${_date.day}/${_date.month}/${_date.year}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            IconToggleGroup<bool>(
              value: _byHeart,
              onChanged: (v) => setState(() => _byHeart = v),
              options: const [
                IconToggleOption(
                  value: true,
                  icon: Icons.visibility_off_outlined,
                  label: 'بالغيب',
                  color: Color(0xFF00A572),
                ),
                IconToggleOption(
                  value: false,
                  icon: Icons.menu_book_outlined,
                  label: 'عن ظهر قلب',
                  color: Color(0xFF004C69),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'النقاط المحتسبة: $_previewPoints نقطة',
              style: TextStyle(
                color: tokens.rewardText,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                _error,
                style: TextStyle(color: tokens.dangerText, fontSize: 13),
              ),
            ],
            const SizedBox(height: 16),
            AppButton(
              label: _isEdit ? 'حفظ التعديلات' : 'إضافة الشهادة',
              onPressed: _save,
            ),
            if (_isEdit) ...[
              const SizedBox(height: 8),
              AppButton(
                label: 'حذف الشهادة',
                variant: AppButtonVariant.dangerOutline,
                onPressed: _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _juzCell(BuildContext context, int juz) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final selected = _inRange(juz);
    final isEdge = juz == _from || juz == _to;
    return InkWell(
      borderRadius: BorderRadius.circular(tokens.radiusSmall),
      onTap: () => _tapJuz(juz),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? tokens.brand : tokens.surfaceCard,
          borderRadius: BorderRadius.circular(tokens.radiusSmall),
          border: Border.all(
            color: selected ? tokens.brand : tokens.borderStructural,
            width: isEdge ? 2 : 1,
          ),
        ),
        child: Text(
          '$juz',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : tokens.textMuted,
          ),
        ),
      ),
    );
  }
}
