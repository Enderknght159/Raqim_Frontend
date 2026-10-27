import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../widgets/permission_editor.dart';

/// Kind of a local account in the users list (E11).
enum AdminUserKind { admin, teacher, student }

/// Account detail page: role info, linked student/teacher, permissions
/// entry point, password reset, deactivate/delete options.
class AdminUserDetailScreen extends StatefulWidget {
  const AdminUserDetailScreen({
    super.key,
    required this.name,
    required this.kind,
    required this.permissions,
    required this.onPermissionsChanged,
    this.studentId,
    this.username,
    this.teams = const [],
  });

  final String name;
  final AdminUserKind kind;
  final AdminPermissionResult permissions;
  final ValueChanged<AdminPermissionResult> onPermissionsChanged;
  final int? studentId;
  final String? username;
  final List<String> teams;

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  late AdminPermissionResult _permissions = widget.permissions;

  Future<void> _openPermissions() async {
    final result = await showPermissionEditor(
      context,
      initial: _permissions,
      title: 'صلاحيات ${widget.name}',
      teacherTeams: widget.teams,
      onViewTeams: widget.teams.isEmpty
          ? null
          : () {
              Navigator.of(context).pop();
              context.push(
                '/admin/teachers/${Uri.encodeComponent(widget.name)}',
              );
            },
    );
    if (result == null) return;
    setState(() => _permissions = result);
    widget.onPermissionsChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: ResponsivePage(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: _permissions.isSupervisor
                            ? tokens.infoTint
                            : tokens.brandTint,
                        child: Icon(
                          switch (widget.kind) {
                            AdminUserKind.admin => Icons.admin_panel_settings,
                            AdminUserKind.teacher => Icons.school,
                            AdminUserKind.student => Icons.person,
                          },
                          color: _permissions.isSupervisor
                              ? tokens.info
                              : tokens.brandText,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                StatusBadge(
                                  label: _roleLabel,
                                  color: switch (widget.kind) {
                                    AdminUserKind.admin => tokens.info,
                                    AdminUserKind.teacher => tokens.accentMatn,
                                    AdminUserKind.student => tokens.brand,
                                  },
                                ),
                                if (_permissions.isSupervisor) ...[
                                  const SizedBox(width: 6),
                                  StatusBadge(
                                    label: 'مشرف',
                                    color: tokens.info,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (widget.username != null) ...[
                    const SizedBox(height: 10),
                    _infoRow(context, 'اسم المستخدم', widget.username!),
                  ],
                  if (widget.teams.isNotEmpty)
                    _infoRow(context, 'حلقاته', widget.teams.join(' · ')),
                  if (widget.studentId != null)
                    _infoRow(
                      context,
                      'الملف المرتبط',
                      'طالب #${widget.studentId}',
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SectionHeader(
              icon: Icons.security_outlined,
              title: 'الصلاحيات والوصول',
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              onTap: _openPermissions,
              child: Row(
                children: [
                  Icon(Icons.rule, color: tokens.textPrimary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'تحديد الصلاحيات',
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  StatusBadge(
                    label: _permissions.isSupervisor ? 'مشرف' : 'بلا صلاحيات',
                    color: _permissions.isSupervisor
                        ? tokens.info
                        : tokens.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.chevron_left, color: tokens.borderStructural),
                ],
              ),
            ),
            if (widget.kind == AdminUserKind.teacher &&
                widget.teams.isNotEmpty) ...[
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                onTap: () => context.push(
                  '/admin/teachers/${Uri.encodeComponent(widget.name)}',
                ),
                child: Row(
                  children: [
                    Icon(Icons.hub_outlined, color: tokens.accentMatn),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'صفحته وحلقاته',
                          style: TextStyle(
                            color: tokens.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_left, color: tokens.borderStructural),
                  ],
                ),
              ),
            ],
            if (widget.studentId != null) ...[
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                onTap: () =>
                    context.push('/admin/students/${widget.studentId}'),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: tokens.brandText),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'ملف الطالب',
                          style: TextStyle(
                            color: tokens.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_left, color: tokens.borderStructural),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const SectionHeader(
              icon: Icons.manage_accounts_outlined,
              title: 'إدارة الحساب',
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              onTap: () => _notice('أُرسل رابط إعادة ضبط كلمة المرور (تجريبي)'),
              child: Row(
                children: [
                  Icon(Icons.lock_reset, color: tokens.textPrimary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'إعادة ضبط كلمة المرور',
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_left, color: tokens.borderStructural),
                ],
              ),
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'إلغاء تفعيل الحساب',
              variant: AppButtonVariant.secondary,
              icon: Icons.block,
              onPressed: () => _confirmAction(
                title: 'إلغاء تفعيل الحساب',
                message:
                    'سيتوقف الدخول للحساب مع بقاء بياناته. يمكن إعادة التفعيل لاحقًا.',
                confirmLabel: 'إلغاء التفعيل',
              ),
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'حذف الحساب',
              variant: AppButtonVariant.destructive,
              icon: Icons.delete_outline,
              onPressed: () => _confirmAction(
                title: 'حذف الحساب',
                message:
                    'سيُحذف الحساب نهائيًا وتبقى السجلات في التدقيق. متابعة؟',
                confirmLabel: 'حذف',
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String get _roleLabel => switch (widget.kind) {
    AdminUserKind.admin => 'أدمن',
    AdminUserKind.teacher => 'مدرس الحلقة',
    AdminUserKind.student => 'طالب',
  };

  Widget _infoRow(BuildContext context, String label, String value) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: tokens.textMuted, fontSize: 13)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _notice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmAction({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    _notice('$title — تم (محلي تجريبي)');
  }
}
