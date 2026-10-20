import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';

/// Switcher between the student view ("حسابي") and supervision ("الإشراف").
/// Colored pill (icon + label) following the flat design system tokens.
class RoleSwitchButton extends StatelessWidget {
  const RoleSwitchButton({super.key, required this.toAdmin});

  /// True when the current view is the student view (switch → admin).
  final bool toAdmin;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final color = toAdmin ? tokens.info : tokens.brandText;
    final tint = toAdmin ? tokens.infoTint : tokens.brandTint;
    final border = toAdmin
        ? tokens.infoLight.withValues(alpha: 0.5)
        : tokens.brandBorder;
    final label = toAdmin ? 'الإشراف' : 'المتابعة';
    final icon = toAdmin
        ? Icons.admin_panel_settings_outlined
        : Icons.visibility_outlined;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Tooltip(
        message: toAdmin ? 'التبديل إلى وضع الإشراف' : 'العودة إلى وضع الطالب',
        child: Material(
          color: tint,
          borderRadius: BorderRadius.circular(tokens.radiusLarge),
          child: InkWell(
            borderRadius: BorderRadius.circular(tokens.radiusLarge),
            onTap: () => context.go(toAdmin ? '/admin/courses' : '/my-progress'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(tokens.radiusLarge),
                border: Border.all(color: border, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
