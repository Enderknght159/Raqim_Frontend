import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/section_loader.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/adaptive_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../shared/permissions.dart';
import '../../data/admin_refresh.dart';
import '../../data/admin_repository.dart';
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
  /// Bumped after writes (permissions/teaching) so the access section reloads.
  int _revision = 0;
  AdminUserPermissions? _permissions;
  int? _teacherId;
  bool _saving = false;

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
    AdminRefresh.instance.addListener(_onOrgChanged);
  }

  @override
  void dispose() {
    AdminRefresh.instance.removeListener(_onOrgChanged);
    super.dispose();
  }

  void _onOrgChanged() {
    if (!mounted) return;
    _reload();
  }

  /// Bumped after every write; the access section refetches on its own.
  void _reload() {
    if (!mounted) return;
    setState(() => _revision++);
  }

  /// One request for supervision permissions and the linked teacher row.
  /// The values are also kept on the state so the header and the permission
  /// editor can read them without racing the section rebuild.
  Future<int?> _loadAccess() async {
    if (!mounted) return _teacherId;
    final repo = AdminRepositoryScope.of(context);
    if (!_canManagePermissions) {
      final row = await repo.user(widget.userId);
      final teacherId = row?.teacherId ?? _teacherId;
      _teacherId = teacherId;
      return teacherId;
    }
    final stored = await repo.userPermissions(widget.userId);
    var teacherId = _teacherId;
    if (teacherId == null) {
      final row = await repo.user(widget.userId);
      teacherId = row?.teacherId;
    }
    _permissions = stored.copyWith(
      isAdmin: stored.isAdmin || widget.kind == AdminUserKind.admin,
    );
    _teacherId = teacherId;
    return teacherId;
  }

  Future<void> _openPermissions() async {
    final current = _permissions;
    if (!_canManagePermissions || _saving || current == null) return;
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
      setState(() => _saving = false);
      _permissions = stored;
      _reload();
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

  Future<void> _openTeaching() async {
    final query = <String, String>{
      if (widget.name.isNotEmpty) 'name': widget.name,
      if (widget.username != null && widget.username!.isNotEmpty)
        'username': widget.username!,
      if (_teacherId != null) 'teacherId': '$_teacherId',
    };
    await context.push(
      Uri(
        path: '/admin/users/${widget.userId}/teaching',
        queryParameters: query,
      ).toString(),
    );
    if (!mounted) return;
    _reload();
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
                                if (_isSupervisor && _roleLabel != 'أدمن') ...[
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
            AsyncSection<int?>(
              cacheKey: 'admin-user-detail-access-${widget.userId}',
              revision: _revision,
              skeleton: const _AccessSkeleton(),
              errorBuilder: (context, retry) => SectionError(
                onRetry: retry,
                message: 'تعذر تحميل الصلاحيات والتدريس',
              ),
              load: _loadAccess,
              builder: (context, teacherId) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_canManagePermissions)
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      onTap: _saving ? null : _openPermissions,
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
                          if (_saving)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            StatusBadge(
                              label: _isSupervisor ? 'مشرف' : 'بلا صلاحيات',
                              color: _isSupervisor
                                  ? tokens.info
                                  : tokens.textMuted,
                            ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.chevron_left,
                            color: tokens.borderStructural,
                          ),
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
                  const SizedBox(height: 8),
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    onTap: _saving ? null : _openTeaching,
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
                          label: teacherId == null ? 'غير معيّن' : 'مدرّس',
                          color: teacherId == null
                              ? tokens.textMuted
                              : tokens.accentMatn,
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.chevron_left,
                          color: tokens.borderStructural,
                        ),
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
                          Icon(
                            Icons.chevron_left,
                            color: tokens.borderStructural,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SectionHeader(
              icon: Icons.manage_accounts_outlined,
              title: 'إدارة الحساب',
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              onTap: _saving ? null : _resetPassword,
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

  Future<void> _resetPassword() async {
    if (_saving) return;
    final repo = AdminRepositoryScope.of(context);
    final password = await showAppSheet<String>(
      context: context,
      maxWidth: 520,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ResetPasswordSheet(
        repository: repo,
        userId: widget.userId,
        accountName: widget.name,
      ),
    );
    if (password == null || !mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تمت إعادة الضبط'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('كلمة المرور الجديدة:'),
            const SizedBox(height: 8),
            SelectableText(
              password,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'اعرضها على صاحب الحساب مرة واحدة، ثم اطلب منه تغييرها.',
              style: Theme.of(dialogContext).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: password));
              if (!dialogContext.mounted) return;
              ScaffoldMessenger.of(dialogContext)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('نُسخت كلمة المرور')),
                );
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('نسخ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('تم'),
          ),
        ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: tokens.textMuted, fontSize: 13)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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

/// Matches the two access tiles (supervision + teaching) so the section does
/// not jump when the real cards arrive.
class _AccessSkeleton extends StatelessWidget {
  const _AccessSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionSkeleton(height: 44, lines: 1),
        SizedBox(height: 8),
        SectionSkeleton(height: 44, lines: 1),
      ],
    );
  }
}

/// Admin-side password reset. Returns the new password so the caller can show
/// it once and copy it for the account owner.
class _ResetPasswordSheet extends StatefulWidget {
  const _ResetPasswordSheet({
    required this.repository,
    required this.userId,
    required this.accountName,
  });

  final AdminRepository repository;
  final int userId;
  final String accountName;

  @override
  State<_ResetPasswordSheet> createState() => _ResetPasswordSheetState();
}

class _ResetPasswordSheetState extends State<_ResetPasswordSheet> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final generated = _generatePassword();
    _password.text = generated;
    _confirm.text = generated;
  }

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String _generatePassword() {
    const chars = 'abcdefghjkmnpqrstuvwxyz23456789';
    final random = Random.secure();
    final code = List.generate(8, (_) => chars[random.nextInt(chars.length)]);
    return 'rq${code.join()}';
  }

  Future<void> _submit() async {
    if (_busy) return;
    final value = _password.text;
    if (value.length < 6) {
      setState(() => _error = 'كلمة المرور 6 أحرف على الأقل.');
      return;
    }
    if (value != _confirm.text) {
      setState(() => _error = 'كلمتا المرور غير متطابقتين.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.repository.resetUserPassword(
        widget.userId,
        newPassword: value,
      );
      if (!mounted) return;
      Navigator.of(context).pop(value);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'تعذّرت إعادة الضبط: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'إعادة ضبط كلمة المرور',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            widget.accountName,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _password,
            obscureText: _obscure,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: 'كلمة المرور الجديدة',
              helperText: 'وُلّدت تلقائيًا — يمكنك تعديلها.',
              suffixIcon: IconButton(
                tooltip: _obscure ? 'إظهار' : 'إخفاء',
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirm,
            obscureText: _obscure,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: TextStyle(color: tokens.dangerText, fontSize: 12),
            ),
          ],
          const SizedBox(height: 16),
          AppButton(
            label: _busy ? 'جارٍ إعادة الضبط…' : 'إعادة ضبط كلمة المرور',
            icon: Icons.lock_reset,
            loading: _busy,
            onPressed: _busy ? null : _submit,
          ),
        ],
      ),
    );
  }
}
