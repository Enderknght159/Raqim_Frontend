import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/utils/date_time_utils.dart';

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

  /// 'HH:MM' latest arrival threshold.
  final String lateFrom;

  final DateTime date;
}

/// Bottom sheet to edit a session's thresholds (sliders + editable text) and
/// date. Prefill from [initial] (typically the last session's values).
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
  late int _earlyUntil = _toMinutes(widget.initial.earlyUntil);
  late int _lateFrom = _toMinutes(widget.initial.lateFrom);
  late DateTime _date = widget.initial.date;

  final _earlyUntilCtrl = TextEditingController();
  final _lateFromCtrl = TextEditingController();
  final _earlyPtsCtrl = TextEditingController();
  final _midPtsCtrl = TextEditingController();
  final _latePtsCtrl = TextEditingController();

  static int _toMinutes(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]) ?? 16;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return h * 60 + m;
  }

  static String _fmt(int minutes) {
    final h = (minutes ~/ 60).clamp(0, 23).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  void _syncControllers() {
    _earlyUntilCtrl.text = _fmt(_earlyUntil);
    _lateFromCtrl.text = _fmt(_lateFrom);
    _earlyPtsCtrl.text = '$_earlyPoints';
    _midPtsCtrl.text = '$_midPoints';
    _latePtsCtrl.text = '$_latePoints';
  }

  @override
  void dispose() {
    _earlyUntilCtrl.dispose();
    _lateFromCtrl.dispose();
    _earlyPtsCtrl.dispose();
    _midPtsCtrl.dispose();
    _latePtsCtrl.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Padding(
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
            Text(widget.title,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('العتبات تختلف من جلسة لأخرى تبعًا لمواقيت الأذان (BR-402)',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: tokens.textMuted)),
            const SizedBox(height: 12),
            // Date.
            InkWell(
              borderRadius: BorderRadius.circular(tokens.radiusSmall),
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: tokens.surfaceSubtle,
                  borderRadius: BorderRadius.circular(tokens.radiusSmall),
                  border: Border.all(color: tokens.borderStructural),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event, size: 20, color: tokens.brandText),
                    const SizedBox(width: 10),
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
            ),
            const SizedBox(height: 12),
            // Points sliders.
            _pointsRow('نقاط المبكر', _earlyPoints, (v) => setState(() {
                  _earlyPoints = v;
                  _earlyPtsCtrl.text = '$v';
                }), _earlyPtsCtrl, (s) {
              final v = int.tryParse(s);
              if (v != null && v >= 0 && v <= 10) {
                setState(() => _earlyPoints = v);
              }
            }),
            const SizedBox(height: 8),
            _pointsRow('نقاط الوقت', _midPoints, (v) => setState(() {
                  _midPoints = v;
                  _midPtsCtrl.text = '$v';
                }), _midPtsCtrl, (s) {
              final v = int.tryParse(s);
              if (v != null && v >= 0 && v <= 10) {
                setState(() => _midPoints = v);
              }
            }),
            const SizedBox(height: 8),
            _pointsRow('نقاط المتأخر', _latePoints, (v) => setState(() {
                  _latePoints = v;
                  _latePtsCtrl.text = '$v';
                }), _latePtsCtrl, (s) {
              final v = int.tryParse(s);
              if (v != null && v >= 0 && v <= 10) {
                setState(() => _latePoints = v);
              }
            }),
            const SizedBox(height: 16),
            // Time thresholds.
            _timeRow(
              'حتى الساعة (مبكر)',
              _earlyUntil,
              (v) => setState(() {
                _earlyUntil = v;
                _earlyUntilCtrl.text = _fmt(v);
              }),
              _earlyUntilCtrl,
              (s) {
                final minutes = _toMinutes(s);
                if (minutes <= 23 * 60 + 59) {
                  setState(() => _earlyUntil = minutes);
                }
              },
            ),
            const SizedBox(height: 8),
            _timeRow(
              'من الساعة (متأخر)',
              _lateFrom,
              (v) => setState(() {
                _lateFrom = v;
                _lateFromCtrl.text = _fmt(v);
              }),
              _lateFromCtrl,
              (s) {
                final minutes = _toMinutes(s);
                if (minutes <= 23 * 60 + 59) {
                  setState(() => _lateFrom = minutes);
                }
              },
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'حفظ',
              onPressed: () => Navigator.of(context).pop(SessionSetupValues(
                earlyPoints: _earlyPoints,
                midPoints: _midPoints,
                latePoints: _latePoints,
                earlyUntil: _fmt(_earlyUntil),
                lateFrom: _fmt(_lateFrom),
                date: _date,
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pointsRow(
    String label,
    int value,
    ValueChanged<int> onChanged,
    TextEditingController controller,
    ValueChanged<String> onSubmitted,
  ) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: tokens.textMuted)),
            ),
            SizedBox(
              width: 64,
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                onChanged: onSubmitted,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          label: '$value',
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }

  Widget _timeRow(
    String label,
    int minutes,
    ValueChanged<int> onChanged,
    TextEditingController controller,
    ValueChanged<String> onSubmitted,
  ) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: tokens.textMuted)),
            ),
            SizedBox(
              width: 84,
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                onChanged: onSubmitted,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: minutes.toDouble().clamp(0, 1439),
          min: 0,
          max: 1439,
          label: _fmt(minutes),
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}
