import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_header.dart';

/// E10 — System tab: tools + admin groups.
class AdminSystemScreen extends StatelessWidget {
  const AdminSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(icon: Icons.build_outlined, title: 'الأدوات'),
          const SizedBox(height: 8),
          for (final tile in [
            (icon: Icons.file_download_outlined, label: 'الاستيراد', path: '/admin/import'),
            (icon: Icons.file_upload_outlined, label: 'التصدير', path: '/admin/tools'),
            (icon: Icons.qr_code_2, label: 'باركود PDF', path: '/admin/tools'),
            (icon: Icons.description_outlined, label: 'أوراق التسميع', path: '/admin/tools'),
            (icon: Icons.sync_outlined, label: 'المزامنة والكشك', path: '/admin/sync-kiosk'),
          ]) ...[
            _tile(context, tile.icon, tile.label, tile.path),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          const SectionHeader(
              icon: Icons.admin_panel_settings_outlined, title: 'الإدارة'),
          const SizedBox(height: 8),
          for (final tile in [
            (icon: Icons.manage_accounts_outlined, label: 'المستخدمون والصلاحيات', path: '/admin/users'),
            (icon: Icons.notifications_outlined, label: 'الإشعارات', path: '/admin/notifications'),
            (icon: Icons.history_outlined, label: 'التدقيق', path: '/admin/audit'),
            (icon: Icons.rule_folder_outlined, label: 'طلبات التغيير', path: '/admin/change-requests'),
            (icon: Icons.settings_outlined, label: 'الإعدادات', path: '/admin/settings'),
          ]) ...[
            _tile(context, tile.icon, tile.label, tile.path),
            const SizedBox(height: 8),
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
              child: Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ),
          ),
          Icon(Icons.chevron_left, color: tokens.borderStructural),
        ],
      ),
    );
  }
}
