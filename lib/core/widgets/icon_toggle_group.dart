import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// One option of an [IconToggleGroup].
class IconToggleOption<T> {
  const IconToggleOption({
    required this.value,
    required this.icon,
    required this.label,
    this.color,
  });

  final T value;
  final IconData icon;
  final String label;
  final Color? color;
}

/// Icon-only segmented choice: only the *selected* option shows its label
/// (flat, radius 12). Used for record kinds (حفظ/متون/معاملة), filters, etc.
class IconToggleGroup<T> extends StatelessWidget {
  const IconToggleGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.dense = false,
  });

  final List<IconToggleOption<T>> options;
  final T? value;
  final ValueChanged<T> onChanged;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: _OptionChip<T>(
              option: options[i],
              selected: options[i].value == value,
              dense: dense,
              onTap: () => onChanged(options[i].value),
            ),
          ),
        ],
        if (options.isEmpty) const Spacer(),
        const SizedBox(width: 10),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              _selectedLabel,
              key: ValueKey(_selectedLabel),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: tokens.info,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String get _selectedLabel {
    for (final o in options) {
      if (o.value == value) return o.label;
    }
    return 'لم يُحدد';
  }
}

class _OptionChip<T> extends StatelessWidget {
  const _OptionChip({
    required this.option,
    required this.selected,
    required this.dense,
    required this.onTap,
  });

  final IconToggleOption<T> option;
  final bool selected;
  final bool dense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final accent = option.color ?? tokens.brand;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.radiusSmall),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(vertical: dense ? 8 : 12),
        decoration: BoxDecoration(
          color: selected ? accent : tokens.surfaceSubtle,
          borderRadius: BorderRadius.circular(tokens.radiusSmall),
          border: Border.all(
            color: selected ? accent : tokens.borderStructural,
            width: selected ? 2 : 1,
          ),
        ),
        child: Icon(
          option.icon,
          size: dense ? 20 : 22,
          color: selected ? Colors.white : accent,
        ),
      ),
    );
  }
}
