import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Compact, tactile number stepper (− value +): the recommended replacement
/// for sliders when picking small integers (session points, course
/// criteria…). Each button keeps a ≥44px touch target.
///
/// * Pass [max] = `null` for an unbounded value (no upper limit at all).
/// * Set [editable] = `true` to let the user type the number directly; the
///   field accepts any non-negative integer and falls back to the previous
///   value when left empty.
class NumberStepper extends StatelessWidget {
  const NumberStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 10,
    this.label,
    this.suffix,
    this.color,
    this.editable = false,
    this.semanticLabel,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;

  /// Highest allowed value, or `null` when the value has no upper bound.
  final int? max;

  /// Optional caption above the control.
  final String? label;
  final String? suffix;

  /// Accent color for the value text (defaults to the brand text token).
  final Color? color;

  /// When `true` the value in the middle is a numeric [TextField] the user
  /// can type into; the −/+ buttons keep working and stay in sync.
  final bool editable;

  /// Screen-reader name of the value (defaults to [label]).
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final valueColor = color ?? tokens.textPrimary;
    final canDec = value > min;
    final maxValue = max;
    final canInc = maxValue == null || value < maxValue;
    final fieldLabel = semanticLabel ?? label;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
          ),
          const SizedBox(height: 4),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StepButton(
              icon: Icons.remove_rounded,
              tooltip: fieldLabel == null ? 'إنقاص' : 'إنقاص $fieldLabel',
              onPressed: canDec ? () => onChanged(value - 1) : null,
            ),
            if (editable)
              _EditableValue(
                value: value,
                min: min,
                max: maxValue,
                color: valueColor,
                semanticLabel: fieldLabel,
                suffix: suffix,
                onChanged: onChanged,
              )
            else
              SizedBox(
                width: 46,
                child: Text(
                  suffix == null ? '$value' : '$value $suffix',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: valueColor,
                  ),
                ),
              ),
            _StepButton(
              icon: Icons.add_rounded,
              tooltip: fieldLabel == null ? 'زيادة' : 'زيادة $fieldLabel',
              onPressed: canInc ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }
}

/// Editable middle slot: a compact numeric field kept in sync with [value].
class _EditableValue extends StatelessWidget {
  const _EditableValue({
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.onChanged,
    this.semanticLabel,
    this.suffix,
  });

  final int value;
  final int min;
  final int? max;
  final Color color;
  final String? semanticLabel;
  final String? suffix;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final field = SizedBox(
      width: 64,
      child: _NumericField(
        value: value,
        min: min,
        max: max,
        color: color,
        semanticLabel: semanticLabel,
        onChanged: onChanged,
      ),
    );
    if (suffix == null) return field;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        field,
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 64),
          child: Text(
            suffix!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
          ),
        ),
      ],
    );
  }
}

class _NumericField extends StatefulWidget {
  const _NumericField({
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.onChanged,
    this.semanticLabel,
  });

  final int value;
  final int min;
  final int? max;
  final Color color;
  final String? semanticLabel;
  final ValueChanged<int> onChanged;

  @override
  State<_NumericField> createState() => _NumericFieldState();
}

class _NumericFieldState extends State<_NumericField> {
  late final TextEditingController _controller = TextEditingController(
    text: '${widget.value}',
  );
  late final FocusNode _focusNode = FocusNode()..addListener(_onFocusChanged);

  @override
  void didUpdateWidget(covariant _NumericField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _syncText();
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  int? _parse(String text) => int.tryParse(text.trim());

  int _clamp(int raw) {
    var result = raw < widget.min ? widget.min : raw;
    final max = widget.max;
    if (max != null && result > max) result = max;
    return result;
  }

  /// Mirrors an external value change (e.g. a −/+ tap) into the field.
  void _syncText() {
    final next = '${widget.value}';
    if (_parse(_controller.text) == widget.value && _controller.text == next) {
      return;
    }
    _controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) _commit();
  }

  /// Typing propagates valid digits immediately; transient states (empty,
  /// leading zeros) are accepted and normalised when the field loses focus.
  void _handleChanged(String text) {
    final parsed = _parse(text);
    if (parsed == null) return;
    if (parsed < widget.min) return;
    if (parsed != widget.value) widget.onChanged(parsed);
  }

  void _commit() {
    final parsed = _parse(_controller.text);
    final next = _clamp(parsed ?? widget.value);
    if (next != widget.value) widget.onChanged(next);
    _controller.value = TextEditingValue(
      text: '$next',
      selection: TextSelection.collapsed(offset: '$next'.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final radius = BorderRadius.circular(10);
    return Semantics(
      label: widget.semanticLabel,
      textField: true,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        enableSuggestions: false,
        autocorrect: false,
        onChanged: _handleChanged,
        onSubmitted: (_) => _commit(),
        onTap: () => _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        ),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: widget.color,
        ),
        cursorColor: widget.color,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: tokens.surfaceSubtle,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: tokens.borderStructural),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: tokens.borderStructural),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: widget.color, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final String? tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final enabled = onPressed != null;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 18),
      color: enabled ? tokens.brandText : tokens.textMuted,
      style: IconButton.styleFrom(
        backgroundColor: enabled ? tokens.brandTint : tokens.surfaceSubtle,
        minimumSize: const Size(44, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: enabled ? tokens.brandBorder : tokens.borderStructural,
          ),
        ),
      ),
    );
  }
}
