import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/ghost_text_field.dart';
import '../../../../core/widgets/icon_toggle_group.dart';
import '../../../../core/widgets/rating_bar.dart';
import '../../../../core/widgets/search_picker_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../student/domain/models/student_models.dart';
import '../../../student/domain/quran_units.dart';
import '../../../student/presentation/widgets/quran_unit_picker.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';
import '../widgets/student_picker_field.dart';

/// E5 — quick (multi) record-entry sheet: حفظ · متون · معاملة.
Future<void> showRecordEntrySheet(BuildContext context, int sessionId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _RecordEntrySheet(sessionId: sessionId),
  );
}

enum _RecordKind { memorization, matn, transaction }

class _RecordEntrySheet extends StatefulWidget {
  const _RecordEntrySheet({required this.sessionId});

  final int sessionId;

  @override
  State<_RecordEntrySheet> createState() => _RecordEntrySheetState();
}

class _RecordEntrySheetState extends State<_RecordEntrySheet> {
  _RecordKind _kind = _RecordKind.memorization;
  AdminStudentRow? _student;
  int _rating = 3;
  List<QuranUnit> _units = const [];
  String _reciter = '';
  final _lastVerse = TextEditingController();
  String _teacher = '';
  final _txValue = TextEditingController();
  final _txDesc = TextEditingController();
  String _txType = 'reward';
  int? _matnId;

  List<AdminContentItem> _matns = const [];
  List<AdminTeacherRow> _teachers = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = AdminRepositoryScope.of(context);
    final matns = await repo.matns();
    final teachers = await repo.teachers();
    if (!mounted) return;
    setState(() {
      _matns = matns;
      _matnId = matns.isEmpty ? null : matns.first.id;
      _teachers = teachers;
      _reciter = teachers.isEmpty ? '' : teachers.first.name;
      _teacher = teachers.isEmpty ? '' : teachers.first.name;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _lastVerse.dispose();
    _txValue.dispose();
    _txDesc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 28 + bottom),
      child: _loading
          ? const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text('تسجيل',
                          style: Theme.of(context).textTheme.titleLarge),
                      const Spacer(),
                      if (_units.isNotEmpty)
                        StatusBadge(
                          label: '${_units.length} وحدة',
                          color: tokens.brand,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Type: icons only — the label of the selected one appears
                  // on the side.
                  IconToggleGroup<_RecordKind>(
                    value: _kind,
                    onChanged: (v) => setState(() => _kind = v),
                    options: const [
                      IconToggleOption(
                        value: _RecordKind.memorization,
                        icon: Icons.menu_book_outlined,
                        label: 'حفظ',
                      ),
                      IconToggleOption(
                        value: _RecordKind.matn,
                        icon: Icons.format_quote_outlined,
                        label: 'متون',
                        color: Color(0xFF7C3AED),
                      ),
                      IconToggleOption(
                        value: _RecordKind.transaction,
                        icon: Icons.payments_outlined,
                        label: 'معاملة',
                        color: Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  StudentPickerField(
                    label: 'اختر الطالب',
                    selected: _student,
                    onChanged: (s) => setState(() => _student = s),
                  ),
                  const SizedBox(height: 16),
                  ..._fields(context, tokens),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'إضافة تسجيل',
                    icon: Icons.qr_code_scanner,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'يبقى الـSheet مفتوحًا لإدخال المزيد',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: tokens.textMuted),
                  ),
                ],
              ),
            ),
    );
  }

  List<Widget> _fields(BuildContext context, AppTokens tokens) {
    switch (_kind) {
      case _RecordKind.memorization:
        return [
          Text('الصفحة من خريطة الحفظ',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: tokens.textMuted)),
          const SizedBox(height: 6),
          QuranUnitPicker(
            selected: _units,
            onChanged: (units) => setState(() => _units = units),
          ),
          const SizedBox(height: 12),
          Text('التقييم',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: tokens.textMuted)),
          const SizedBox(height: 6),
          RatingBar(
            levels: kMemorizationRatingLevels,
            value: _rating,
            onChanged: (v) => setState(() => _rating = v),
          ),
          const SizedBox(height: 12),
          Text('المسمِّع (افتراضي: معلم الحلقة)',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: tokens.textMuted)),
          const SizedBox(height: 6),
          SearchPickerField<String>(
            label: 'اختر المسمِّع',
            items: _teachers.map((t) => t.name).toList(),
            titleBuilder: (name) => name,
            subtitleBuilder: null,
            value: _reciter.isEmpty ? null : _reciter,
            onChanged: (name) => setState(() => _reciter = name),
          ),
        ];
      case _RecordKind.matn:
        return [
          Text('المتن',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: tokens.textMuted)),
          const SizedBox(height: 6),
          SearchPickerField<AdminContentItem>(
            label: 'اختر المتن',
            items: _matns,
            titleBuilder: (m) => m.name,
            subtitleBuilder: (m) => m.subtitle,
            value: _matnId == null
                ? null
                : _matns.where((m) => m.id == _matnId).firstOrNull,
            onChanged: (m) => setState(() => _matnId = m.id),
          ),
          const SizedBox(height: 12),
          GhostTextField(
            controller: _lastVerse,
            ghost: '1',
            label: 'آخر بيت',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 12),
          Text('المعلم',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: tokens.textMuted)),
          const SizedBox(height: 6),
          SearchPickerField<String>(
            label: 'اختر المعلم',
            items: _teachers.map((t) => t.name).toList(),
            titleBuilder: (name) => name,
            subtitleBuilder: null,
            value: _teacher.isEmpty ? null : _teacher,
            onChanged: (name) => setState(() => _teacher = name),
          ),
        ];
      case _RecordKind.transaction:
        return [
          IconToggleGroup<String>(
            value: _txType,
            onChanged: (v) => setState(() => _txType = v),
            options: [
              for (final t in TransactionType.values)
                IconToggleOption(
                  value: t.value,
                  icon: _txIcon(t),
                  label: t.arabic,
                  color: _txColor(t, tokens),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _txValue,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'القيمة'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _txDesc,
            decoration: const InputDecoration(labelText: 'وصف (اختياري)'),
          ),
        ];
    }
  }

  Future<void> _submit() async {
    final repo = AdminRepositoryScope.of(context);
    final student = _student;
    if (student == null) {
      _snack('اختر طالبًا');
      return;
    }
    switch (_kind) {
      case _RecordKind.memorization:
        if (_units.isEmpty) {
          _snack('اختر صفحة من الخريطة');
          return;
        }
        await repo.addMemorization(
          studentId: student.id,
          sessionId: widget.sessionId,
          units: _units,
          rating: _rating,
          reciterName: _reciter,
        );
        setState(() {
          _units = const [];
          _rating = 3;
        });
      case _RecordKind.matn:
        if (_matnId == null) {
          _snack('لا متون متاحة');
          return;
        }
        await repo.addMatnRecitation(
          studentId: student.id,
          matnId: _matnId!,
          sessionId: widget.sessionId,
          lastVerse: int.tryParse(_lastVerse.text) ?? 1,
          teacherName: _teacher,
        );
      case _RecordKind.transaction:
        final value = int.tryParse(_txValue.text) ?? 0;
        if (value == 0) {
          _snack('أدخل قيمة غير صفرية');
          return;
        }
        await repo.addTransaction(
          studentId: student.id,
          sessionId: widget.sessionId,
          type: _txType,
          value: value,
          description: _txDesc.text.trim().isEmpty ? null : _txDesc.text.trim(),
        );
        _txValue.clear();
        _txDesc.clear();
    }
    if (!mounted) return;
    HapticFeedback.lightImpact();
    _snack('تم حفظ تسجيل ${student.name}');
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

IconData _txIcon(TransactionType t) => switch (t) {
      TransactionType.reward => Icons.add_circle_outline,
      TransactionType.penalty => Icons.remove_circle_outline,
      TransactionType.purchase => Icons.shopping_bag_outlined,
      TransactionType.collection => Icons.savings_outlined,
      TransactionType.incomeExpense => Icons.swap_horiz,
    };

Color _txColor(TransactionType t, AppTokens tokens) => switch (t) {
      TransactionType.penalty => tokens.danger,
      TransactionType.purchase => tokens.danger,
      TransactionType.incomeExpense => tokens.info,
      _ => tokens.reward,
    };
