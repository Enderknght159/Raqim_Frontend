import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/permission_packs.dart';
import 'permission_level_selector.dart';

/// A single permission pack row: one switch, one three-icon level control, one
/// account-scope chip, and a short list of automatic prerequisites.
class PermissionPackCard extends StatelessWidget {
  const PermissionPackCard({
    super.key,
    required this.pack,
    required this.snapshot,
    required this.scopeLabel,
    required this.locked,
    required this.onToggle,
    required this.onLevel,
    required this.onScope,
  });

  final PermissionPack pack;
  final PermissionPackSnapshot snapshot;
  final String scopeLabel;
  final bool locked;
  final ValueChanged<bool> onToggle;
  final ValueChanged<PermissionLevel> onLevel;
  final VoidCallback onScope;

  static const _icons = {
    PermissionPackIcon.attendance: Icons.how_to_reg_outlined,
    PermissionPackIcon.points: Icons.stars_outlined,
    PermissionPackIcon.quran: Icons.auto_stories_outlined,
    PermissionPackIcon.matn: Icons.menu_book_outlined,
    PermissionPackIcon.students: Icons.groups_outlined,
    PermissionPackIcon.teams: Icons.hub_outlined,
    PermissionPackIcon.exams: Icons.workspace_premium_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final enabled = snapshot.enabled;
    final prerequisites = _prerequisiteLabels();
    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? tokens.brandTint.withValues(alpha: 0.32)
            : tokens.surfaceSubtle.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(tokens.radiusSmall),
        border: Border.all(
          color: enabled ? tokens.brandBorder : tokens.borderStructural,
        ),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 8, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: enabled ? tokens.brandTint : tokens.surfaceSubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _icons[pack.icon] ?? Icons.tune,
                  size: 20,
                  color: enabled ? tokens.brandText : tokens.textMuted,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pack.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      pack.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: tokens.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Switch(
                key: ValueKey('pack-switch-${pack.id}'),
                value: enabled,
                onChanged: locked ? null : onToggle,
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 190),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: enabled
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            PermissionLevelSelector(
                              value: snapshot.level,
                              keyPrefix: 'pack-level-${pack.id}',
                              onChanged: locked ? null : onLevel,
                              compact: true,
                            ),
                            PermissionScopeChip(
                              key: ValueKey('pack-scope-${pack.id}'),
                              label: scopeLabel,
                              enabled: !locked,
                              onTap: onScope,
                            ),
                            if (snapshot.partial)
                              StatusBadge(
                                label: 'إعداد جزئي',
                                color: tokens.danger,
                              ),
                          ],
                        ),
                        if (prerequisites.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.link,
                                size: 13,
                                color: tokens.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'يتضمن تلقائيًا: ${prerequisites.join(' · ')}',
                                  style: TextStyle(
                                    color: tokens.textMuted,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  List<String> _prerequisiteLabels() {
    if (!snapshot.enabled) return const [];
    final sessionManage =
        pack.fullManagesSessions && snapshot.level == PermissionLevel.full;
    return [
      for (final module in pack.prerequisiteModules)
        permissionPrerequisiteLabel(module, sessionManage: sessionManage),
    ];
  }
}

class PermissionScopeChip extends StatelessWidget {
  const PermissionScopeChip({
    super.key,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(9, 5, 10, 5),
          decoration: BoxDecoration(
            color: tokens.surfaceSubtle,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: tokens.borderStructural),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.filter_alt_outlined,
                size: 14,
                color: enabled ? tokens.brandText : tokens.textMuted,
              ),
              const SizedBox(width: 5),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 190),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: enabled ? tokens.textPrimary : tokens.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
