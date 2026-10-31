import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/admin_models.dart';

/// Compact icon badges for every role an account holds (E11).
///
/// A dual-role account (supervisor + teacher + student) shows one badge per
/// role; text is never stacked, the label lives in the tooltip/semantics.
class AdminRoleBadges extends StatelessWidget {
  const AdminRoleBadges({
    super.key,
    this.isAdmin = false,
    this.isSupervisor = false,
    this.isTeacher = false,
    this.isStudent = false,
    this.size = 18,
  });

  factory AdminRoleBadges.fromRow(AdminUserRow row, {double size = 18}) {
    return AdminRoleBadges(
      isAdmin: row.isAdmin,
      isSupervisor: row.isSupervisor,
      isTeacher: row.isTeacher,
      isStudent: row.isStudent,
      size: size,
    );
  }

  final bool isAdmin;
  final bool isSupervisor;
  final bool isTeacher;
  final bool isStudent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final badges = <Widget>[
      if (isAdmin)
        _AdminRoleBadge(
          label: 'مدير',
          icon: Icons.admin_panel_settings,
          color: tokens.info,
          size: size,
        ),
      if (isSupervisor)
        _AdminRoleBadge(
          label: 'مشرف',
          icon: Icons.verified_user,
          color: tokens.info,
          size: size,
        ),
      if (isTeacher)
        _AdminRoleBadge(
          label: 'معلم',
          icon: Icons.school,
          color: tokens.accentMatn,
          size: size,
        ),
      if (isStudent)
        _AdminRoleBadge(
          label: 'طالب',
          icon: Icons.person,
          color: tokens.brandText,
          size: size,
        ),
    ];
    if (badges.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < badges.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          badges[i],
        ],
      ],
    );
  }
}

class _AdminRoleBadge extends StatelessWidget {
  const _AdminRoleBadge({
    required this.label,
    required this.icon,
    required this.color,
    required this.size,
  });

  final String label;
  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: false,
      child: ExcludeSemantics(
        child: Tooltip(
          message: label,
          child: Icon(icon, size: size, color: color),
        ),
      ),
    );
  }
}
