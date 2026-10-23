import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/number_stepper.dart';
import '../../../../core/widgets/section_header.dart';

/// Values of a session setup (thresholds + points + date, BR-402).
class SessionSetupValues {
  const SessionSetupValues({
    required this.earlyPoints,
    required this.midPoints,
    required this.latePoints,
    required this.earlyUntil,
    required this.lateFrom,
    required this.date,
  });

  final int earlyPoints;
  final int midPoints;
  final int latePoints;

  /// 'HH:MM' earliest arrival threshold.
  final String earlyUntil;

  /// 'HH:MM' latest arrival threshold (must be after [earlyUntil]).
  final String lateFrom;

  final DateTime date;
}

/// Bottom sheet to edit a session's thresholds and date. Prefill from
/// [initial] (typically the last session's values).
///
/// UX: time thresholds use native time pickers (no hyper-sensitive sliders),
/// points use compact steppers, and the sheet blocks saving when the late
/// threshold is not after the early one.
Future<SessionSetupValues?> showSessionSetupSheet(
  BuildContext context, {
  required SessionSetupValues initial,
  String title = 'تعديل الجلسة',
}) {
  return showModalBottomSheet<SessionSetupValues>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _SessionSetupSheet(initial: initial, title: title),
  );
}

class _SessionSetupSheet extends StatefulWidget {
  const _SessionSetupSheet({required this.initial, required this.title});

  final SessionSetupValues initial;
  final String title;

  @override
  State<_SessionSetupSheet> createState() => _SessionSetupSheetState();
}

class _SessionSetupSheetState extends State<_SessionSetupSheet> {
  late int _earlyPoints = widget.initial.earlyPoints;
  late int _midPoints = widget.initial.midPoints;
  late int _latePoints = widget.initial.latePoints;
  late TimeOfDay _earlyUntil = _parse(widget.initial.earlyUntil);
  late TimeOfDay _lateFrom = _parse(widget.initial.lateFrom);
  late DateTime _date = widget.initial.date;
  String _error = '';

  static TimeOfDay _parse(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]) ?? 16;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
  }

  static String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static int _minutes(TimeOfDay t) => t.hour * 60 + t.minute;

  bool get _validOrder => _minutes(_lateFrom) > _minutes(_earlyUntil);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _date = DateTime(
          picked.year, picked.month, picked.day,
          _date.hour, _date.minute));
    }
  }

  Future<void> _pickTime({required bool early}) async {
    final initial = early ? _earlyUntil : _lateFrom;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _error = '';
      if (early) {
        _earlyUntil = picked;
        // Keep the late threshold always after the early one.
        if (_minutes(_lateFrom) <= _minutes(picked)) {
          final next = (_minutes(picked) + 30).clamp(0, 23 * 60 + 59);
          _lateFrom = TimeOfDay(hour: next ~/ 60, minute: next % 60);
        }
      } else {
        _lateFrom = picked;
      }
    });
  }

  void _save() {
    if (!_validOrder) {
      setState(() =>
          _error = 'وقت التأخير يجب أن يكون بعد وقت الإبكار');
      return;
    }
    Navigator.of(context).pop(SessionSetupValues(
      earlyPoints: _earlyPoints,
      midPoints: _midPoints,
      latePoints: _latePoints,
      earlyUntil: _fmt(_earlyUntil),
      lateFrom: _fmt(_lateFrom),
      date: _date,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 0,
        bottom: 24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'العتبات تختلف من جلسة لأخرى تبعًا لمواقيت الأذان (BR-402)',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: tokens.textMuted),
            ),
            const SizedBox(height: 12),
            // Date.
            _fieldShell(
              context,
              onTap: _pickDate,
              leading: Icons.event,
              child: Row(
                children: [
                  Expanded(
                    child: Text('التاريخ: ${formatDate(_date)}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  Icon(Icons.edit_outlined,
                      size: 18, color: tokens.textMuted),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Times.
            const SectionHeader(
                icon: Icons.schedule_outlined, title: 'وقت الحضور'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _timeField(
                    context,
                    label: 'الحضور المبكر حتى',
                    value: _fmt(_earlyUntil),
                    icon: Icons.wb_sunny_outlined,
                    onTap: () => _pickTime(early: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _timeField(
                    context,
                    label: 'التأخير من الساعة',
                    value: _fmt(_lateFrom),
                    icon: Icons.alarm,
                    onTap: () => _pickTime(early: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _validOrder
                  ? 'يُعدّ المتأخر من ${_fmt(_lateFrom)} فصاعدًا؛ بينهما في الوقت.'
                  : 'وقت التأخير يجب أن يكون بعد وقت الإبكار.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _validOrder
                        ? tokens.textMuted
                        : tokens.dangerText,
                  ),
            ),
            const SizedBox(height: 16),

            // Points.
            const SectionHeader(
                icon: Icons.stars_outlined, title: 'نقاط الحضور'),
            const SizedBox(height: 8),
            AppCard(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  _stepperRow(
                    context,
                    label: 'نقاط المبكر',
                    value: _earlyPoints,
                    color: tokens.brandText,
                    onChanged: (v) => setState(() => _earlyPoints = v),
                  ),
                  const Divider(height: 10),
                  _stepperRow(
                    context,
                    label: 'نقاط الوقت',
                    value: _midPoints,
                    color: tokens.info,
                    onChanged: (v) => setState(() => _midPoints = v),
                  ),
                  const Divider(height: 10),
                  _stepperRow(
                    context,
                    label: 'نقاط المتأخر',
                    value: _latePoints,
                    color: tokens.dangerText,
                    onChanged: (v) => setState(() => _latePoints = v),
                  ),
                ],
              ),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_error,
                  style: TextStyle(color: tokens.dangerText, fontSize: 13)),
            ],
            const SizedBox(height: 18),
            AppButton(label: 'حفظ', onPressed: _save),
          ],
        ),
      ),
    );
  }

  Widget _stepperRow(
    BuildContext context, {
    required String label,
    required int value,
    required Color color,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
          NumberStepper(
            value: value,
            min: 0,
            max: 10,
            color: color,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _fieldShell(
    BuildContext context, {
    required VoidCallback onTap,
    required IconData leading,
    required Widget child,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return InkWell(
      borderRadius: BorderRadius.circular(tokens.radiusSmall),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: tokens.surfaceSubtle,
          borderRadius: BorderRadius.circular(tokens.radiusSmall),
          border: Border.all(color: tokens.borderStructural),
        ),
        child: Row(
          children: [
            Icon(leading, size: 20, color: tokens.brandText),
            const SizedBox(width: 10),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget _timeField(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
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
                Icon(icon, size: 16, color: tokens.info),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: tokens.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textDirection: TextDirection.ltr,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: tokens.textPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
