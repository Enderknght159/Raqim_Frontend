import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, destructive, dangerOutline }

/// Flat app button (`ui-ux-foundations.md` §7):
/// primary = brand fill + darker 2–3px bottom bar (pressed depth),
/// radius 12, no shadow. Press moves down slightly.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = true,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool loading;
  final bool expand;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final (bg, fg, bottom) = _colors(tokens);

    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.loading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        else ...[
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 18, color: fg),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          if (widget.trailingIcon != null) ...[
            const SizedBox(width: 6),
            Icon(widget.trailingIcon, size: 18, color: fg),
          ],
        ],
      ],
    );

    return Opacity(
      opacity: _enabled ? 1 : 0.38,
      child: GestureDetector(
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
        onTap: _enabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(tokens.radiusSmall),
            border: _border(bottom),
          ),
          child: content,
        ),
      ),
    );
  }

  Border _border(Color bottom) {
    return switch (widget.variant) {
      AppButtonVariant.secondary ||
      AppButtonVariant.dangerOutline =>
        Border.all(color: bottom, width: 2),
      AppButtonVariant.primary ||
      AppButtonVariant.destructive =>
        Border.all(color: bottom, width: 3),
    };
  }

  (Color bg, Color fg, Color bottom) _colors(AppTokens tokens) {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return (tokens.brand, Colors.white, tokens.brandPressed);
      case AppButtonVariant.secondary:
        return (tokens.surfacePage, tokens.brandText, tokens.brandBorder);
      case AppButtonVariant.destructive:
        return (tokens.danger, Colors.white, tokens.dangerText);
      case AppButtonVariant.dangerOutline:
        return (tokens.surfacePage, tokens.dangerText, tokens.danger);
    }
  }
}