import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../shared/permissions.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';
import '../widgets/permission_editor.dart';

/// Kind of a local account in the users list (E11).
enum AdminUserKind { admin, teacher, student }

/// Account detail page: role info, linked student/teacher, permissions
/// entry point, password reset, deactivate/delete options.
class AdminUserDetailScreen extends StatefulWidget {
  const AdminUserDetailScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.kind,
    this.isTeacher = false,
    this.teacherId,
    this.studentId,
    this.username,
    this.teams = const [],
  });

  /// Account id (not the linked student/teacher row id).
  final int userId;
  final String name;
  final AdminUserKind kind;
  final bool isTeacher;

  /// Linked teacher row id when known; otherwise resolved from the account.
  final int? teacherId;
  final int? studentId;
  final String? username;
  final List<String> teams;

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  AdminUserPermissions? _permissions;
  int? _teacherId;
  bool _loadingPermissions = true;
  bool _saving = false;
  String? _permissionsError;

  bool get _isSupervisor =>
      _permissions?.isSupervisor ?? widget.kind == AdminUserKind.admin;

  bool get _canManagePermissions {
    final profile = currentProfile(context);
    return profile == null || profile.isAdmin;
  }

  @override
  void initState() {
    super.initState();
    _teacherId = widget.teacherId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAccount());
  }

  Future<void> _loadAccount() async {
    if (!mounted) return;
    final repo = AdminRepositoryScope.of(context);
    if (!_canManagePermissions) {
      final row = await repo.user(widget.userId);
      if (!mounted) return;
      setState(() {
        _teacherId = row?.teacherId ?? _teacherId;
        _loadingPermissions = false;
        _permissionsError = null;
      });
      return;
    }
    try {
      final stored = await repo.userPermissions(widget.userId);
      var teacherId = _teacherId;
      if (teacherId == null) {
        final row = await repo.user(widget.userId);
        teacherId = row?.teacherId;
      }
      if (!mounted) return;
      setState(() {
        _permissions = stored.copyWith(
          isAdmin: stored.isAdmin || widget.kind == AdminUserKind.admin,
        );
        _teacherId = teacherId;
        _loadingPermissions = false;
        _permissionsError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingPermissions = false;
        _permissionsError = '$error';
      });
    }
  }

  Future<void> _openPermissions() async {
    final current = _permissions;
    if (!_canManagePermissions ||
        _saving ||
        _loadingPermissions ||
        current == null) {
      return;
    }
    final result = await showPermissionEditor(
      context,
      initial: current,
      title: 'صلاحيات ${widget.name}',
      targetUserId: widget.userId,
    );
    if (result == null || !mounted) return;
    setState(() => _saving = true);
    final repo = AdminRepositoryScope.of(context);
    try {
      // The permissions endpoint silently ignores `isAdmin: false`, so the
      // account endpoint performs the actual demotion.
      if (current.isAdmin && !result.isAdmin) {
        await repo.setUserAdmin(widget.userId, false);
      }
      await repo.updateUserPermissions(widget.userId, result);
      final stored = await repo.userPermissions(widget.userId);
      if (!mounted) return;
      setState(() {
        _permissions = stored;
        _saving = false;
        _permissionsError = null;
      });
      _notice(
        current.isAdmin && !result.isAdmin
            ? 'أُزيلت صفة المدير وحُفظت الصلاحيات.'
            : 'تم حفظ الصلاحيات.',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _notice('تعذر حفظ الصلاحيات: $error');
    }
  }

  void _openTeaching() {
    final query = <String, String>{
      if (widget.name.isNotEmpty) 'name': widget.name,
      if (widget.username != null && widget.username!.isNotEmpty)
        'username': widget.username!,
      if (_teacherId != null) 'teacherId': '$_teacherId',
    };
    context.push(
      Uri(
        path: '/admin/users/${widget.userId}/teaching',
        queryParameters: query,
      ).toString(),
    );
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
                        backgroundColor: _isSupervisor
                            ? tokens.infoTint
                            : tokens.brandTint,
                        child: Icon(
                          switch (widget.kind) {
                            AdminUserKind.admin => Icons.admin_panel_settings,
                            AdminUserKind.teacher => Icons.school,
                            AdminUserKind.student => Icons.person,
                          },
                          color: _isSupervisor ? tokens.info : tokens.brandText,
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
                                if (_isSupervisor) ...[
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
            if (_canManagePermissions)
              AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                onTap: _loadingPermissions || _saving ? null : _openPermissions,
                child: Row(
                  children: [
                    Icon(Icons.rule, color: tokens.textPrimary),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'صلاحيات الإشراف',
                          style: TextStyle(
                            color: tokens.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (_loadingPermissions || _saving)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      StatusBadge(
                        label: _isSupervisor ? 'مشرف' : 'بلا صلاحيات',
                        color: _isSupervisor ? tokens.info : tokens.textMuted,
                      ),
                    const SizedBox(width: 6),
                    Icon(Icons.chevron_left, color: tokens.borderStructural),
                  ],
                ),
              )
            else
              AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, color: tokens.textMuted),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'صلاحيات الإشراف — للمدير العام فقط',
                          style: TextStyle(
                            color: tokens.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_permissionsError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'تعذر تحميل الصلاحيات الحالية: $_permissionsError',
                  style: TextStyle(color: tokens.dangerText, fontSize: 12),
                ),
              ),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              onTap: _loadingPermissions || _saving ? null : _openTeaching,
              child: Row(
                children: [
                  Icon(Icons.school_outlined, color: tokens.accentMatn),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'صلاحيات التدريس',
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  StatusBadge(
                    label: _teacherId == null ? 'غير معيّن' : 'مدرّس',
                    color: _teacherId == null
                        ? tokens.textMuted
                        : tokens.accentMatn,
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.chevron_left, color: tokens.borderStructural),
                ],
              ),
            ),
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

  String get _roleLabel {
    if (_permissions?.isAdmin ?? widget.kind == AdminUserKind.admin) {
      return 'أدمن';
    }
    return switch (widget.kind) {
      AdminUserKind.admin => 'حساب',
      AdminUserKind.teacher => 'مدرس الحلقة',
      AdminUserKind.student => 'طالب',
    };
  }

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
