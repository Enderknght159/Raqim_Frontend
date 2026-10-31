import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/permission_packs.dart';

/// A compact three-icon control: read · write · full control.
///
/// Reading is always implied by writing, and writing is always implied by full
/// control, so an invalid "write without read" state cannot be produced from
/// this widget. The selected level is shown once in a single label beside the
/// frame (RTL-safe).
class PermissionLevelSelector extends StatelessWidget {
  const PermissionLevelSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.compact = false,
    this.showLabel = true,
    this.keyPrefix,
  });

  final PermissionLevel value;
  final ValueChanged<PermissionLevel>? onChanged;
  final bool compact;
  final bool showLabel;

  /// Used for tests: `pack-level-attendance-write` or `advanced-level-reports`.
  final String? keyPrefix;

  static const _levels = [
    PermissionLevel.read,
    PermissionLevel.write,
    PermissionLevel.full,
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final enabled = onChanged != null;
    final selector = Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: tokens.surfaceSubtle,
        borderRadius: BorderRadius.circular(tokens.radiusSmall),
        border: Border.all(color: tokens.borderStructural),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final level in _levels)
            _LevelSegment(
              level: level,
              selected: value == level,
              enabled: enabled,
              compact: compact,
              key: keyPrefix == null
                  ? null
                  : ValueKey('$keyPrefix-${level.name}'),
              onTap: enabled ? () => onChanged!(level) : null,
            ),
        ],
      ),
    );

    if (!showLabel) return selector;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        selector,
        const SizedBox(width: 8),
        Flexible(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: Text(
              value.label,
              key: ValueKey('level-label-${value.name}'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: enabled ? tokens.textPrimary : tokens.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: compact ? 12 : 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LevelSegment extends StatelessWidget {
  const _LevelSegment({
    super.key,
    required this.level,
    required this.selected,
    required this.enabled,
    required this.compact,
    required this.onTap,
  });

  final PermissionLevel level;
  final bool selected;
  final bool enabled;
  final bool compact;
  final VoidCallback? onTap;

  IconData get _icon => switch (level) {
    PermissionLevel.read => Icons.visibility_outlined,
    PermissionLevel.write => Icons.edit_outlined,
    PermissionLevel.full => Icons.shield_outlined,
    PermissionLevel.none => Icons.block,
  };

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final onSelected = Theme.of(context).colorScheme.onPrimary;
    final size = compact ? 30.0 : 34.0;
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: level.label,
      child: Tooltip(
        message: level.label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(tokens.radiusSmall - 2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: selected ? tokens.brand : Colors.transparent,
              borderRadius: BorderRadius.circular(tokens.radiusSmall - 2),
            ),
            child: Icon(
              _icon,
              size: compact ? 16 : 18,
              color: selected
                  ? onSelected
                  : enabled
                  ? tokens.textMuted
                  : tokens.textMuted.withValues(alpha: 0.45),
            ),
          ),
        ),
      ),
    );
  }
}
