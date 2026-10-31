import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/responsive_grid.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../shared/permissions.dart';

/// E10 — System tab: tools + admin groups.
class AdminSystemScreen extends StatelessWidget {
  const AdminSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = currentProfile(context);
    final canImport =
        profile == null || profile.isAdmin || profile.canView('imports');
    final canExport =
        profile == null ||
        profile.isAdmin ||
        profile.canExport('students') ||
        profile.canExport('attendance') ||
        hasAnyAbility(context, const ['messagesExport', 'barcodeExport']);
    final canKiosk =
        profile == null ||
        profile.isAdmin ||
        profile.canView('attendance') ||
        profile.canView('points');
    final canUsers =
        profile == null || hasAnyAbility(context, const ['userManagement']);
    final canAudit =
        profile == null || hasAnyAbility(context, const ['auditView']);
    final canRequests =
        profile == null || hasAnyAbility(context, const ['dataChangeApproval']);
    final isAdmin = profile == null || profile.isAdmin;

    final tools = [
      if (canImport)
        (
          icon: Icons.file_download_outlined,
          label: 'الاستيراد',
          path: '/admin/import',
        ),
      if (canExport)
        (
          icon: Icons.file_upload_outlined,
          label: 'التصدير',
          path: '/admin/tools',
        ),
      if (canExport)
        (icon: Icons.qr_code_2, label: 'باركود PDF', path: '/admin/tools'),
      if (canExport)
        (
          icon: Icons.description_outlined,
          label: 'أوراق التسميع',
          path: '/admin/tools',
        ),
      if (canKiosk)
        (
          icon: Icons.sync_outlined,
          label: 'المزامنة والكشك',
          path: '/admin/sync-kiosk',
        ),
    ];
    final management = [
      if (canUsers)
        (
          icon: Icons.manage_accounts_outlined,
          label: 'المستخدمون والصلاحيات',
          path: '/admin/users',
        ),
      if (canAudit)
        (
          icon: Icons.notifications_outlined,
          label: 'الإشعارات',
          path: '/admin/notifications',
        ),
      if (canAudit)
        (icon: Icons.history_outlined, label: 'التدقيق', path: '/admin/audit'),
      if (canRequests)
        (
          icon: Icons.rule_folder_outlined,
          label: 'طلبات التغيير',
          path: '/admin/change-requests',
        ),
      if (isAdmin)
        (
          icon: Icons.settings_outlined,
          label: 'الإعدادات',
          path: '/admin/settings',
        ),
    ];

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (tools.isNotEmpty) ...[
            const SectionHeader(icon: Icons.build_outlined, title: 'الأدوات'),
            const SizedBox(height: 8),
            ResponsiveGrid(
              minItemWidth: 320,
              maxColumns: 3,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tile in tools)
                  _tile(context, tile.icon, tile.label, tile.path),
              ],
            ),
            const SizedBox(height: 16),
          ],
          if (management.isNotEmpty) ...[
            const SectionHeader(
              icon: Icons.admin_panel_settings_outlined,
              title: 'الإدارة',
            ),
            const SizedBox(height: 8),
            ResponsiveGrid(
              minItemWidth: 320,
              maxColumns: 3,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tile in management)
                  _tile(context, tile.icon, tile.label, tile.path),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label, String path) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () => context.push(path),
      child: Row(
        children: [
          Icon(icon, color: tokens.brandText),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Icon(Icons.chevron_left, color: tokens.borderStructural),
        ],
      ),
    );
  }
}
