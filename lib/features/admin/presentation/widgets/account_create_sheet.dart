import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/identity_code.dart';
import '../../../../core/widgets/adaptive_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/permissions.dart';
import '../../data/admin_repository.dart';
import '../../domain/admin_models.dart';

/// The two account kinds an admin can create without a linked student.
enum AdminAccountRole {
  supervisor('مشرف', 'حساب إشرافي مستقل، تمنحه الصلاحيات بعد الإنشاء.'),
  teacher('مدرس', 'يُنشأ له ملف معلم مرتبط مباشرة بالحساب.');

  const AdminAccountRole(this.label, this.hint);

  final String label;
  final String hint;
}

/// Account created from the form, with the role the admin picked.
class CreatedAccount {
  const CreatedAccount({required this.user, required this.role});

  final AdminUserRow user;
  final AdminAccountRole role;
}

/// Creates a mosque account (supervisor or teacher) without creating/attaching
/// a student. Enforces the mosque-code username prefix (BR-624/707).
Future<CreatedAccount?> showCreateAccountSheet(
  BuildContext context, {
  required AdminRepository repository,
  AdminAccountRole initialRole = AdminAccountRole.supervisor,
}) {
  return showAppSheet<CreatedAccount>(
    context: context,
    maxWidth: 600,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) =>
        _CreateAccountSheet(repository: repository, initialRole: initialRole),
  );
}

class _CreateAccountSheet extends StatefulWidget {
  const _CreateAccountSheet({
    required this.repository,
    required this.initialRole,
  });

  final AdminRepository repository;
  final AdminAccountRole initialRole;

  @override
  State<_CreateAccountSheet> createState() => _CreateAccountSheetState();
}

class _CreateAccountSheetState extends State<_CreateAccountSheet> {
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _email = TextEditingController();

  late AdminAccountRole _role = widget.initialRole;
  String _mosqueCode = '';
  bool _loadingCode = true;
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  /// The account row is cached so a retry after a teacher-link failure never
  /// creates a second account.
  AdminUserRow? _created;

  @override
  void initState() {
    super.initState();
    _resolveMosqueCode();
  }

  Future<void> _resolveMosqueCode() async {
    final profileCode = currentProfile(context)?.mosqueCode?.trim() ?? '';
    if (profileCode.isNotEmpty) {
      _applyMosqueCode(profileCode);
      return;
    }
    try {
      final mosque = await widget.repository.mosque();
      _applyMosqueCode(mosque.code.trim());
    } catch (_) {
      if (mounted) setState(() => _loadingCode = false);
    }
  }

  void _applyMosqueCode(String code) {
    if (!mounted) return;
    setState(() {
      _mosqueCode = code;
      _loadingCode = false;
      if (code.isNotEmpty && _username.text.trim().isEmpty) {
        _username.text = '$code-';
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    _email.dispose();
    super.dispose();
  }

  String get _usernameValue {
    final raw = _username.text.trim();
    if (_mosqueCode.isEmpty) return raw;
    return ensureMosqueUsername(_mosqueCode, raw);
  }

  Future<void> _submit() async {
    if (_busy) return;
    final name = _name.text.trim();
    final username = _usernameValue;
    final password = _password.text;
    final confirm = _confirm.text;
    final email = _email.text.trim();

    if (name.length < 2) {
      setState(() => _error = 'أدخل اسم الحساب (حرفان على الأقل).');
      return;
    }
    if (_mosqueCode.isNotEmpty &&
        (username == '$_mosqueCode-' ||
            username.length <= _mosqueCode.length)) {
      setState(() => _error = 'أدخل اسم مستخدم بعد سابقة المسجد.');
      return;
    }
    if (_mosqueCode.isEmpty && username.length < 3) {
      setState(() => _error = 'أدخل اسم مستخدم صالحًا.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'كلمة المرور 6 أحرف على الأقل.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'كلمتا المرور غير متطابقتين.');
      return;
    }
    if (email.isNotEmpty && !email.contains('@')) {
      setState(() => _error = 'صيغة البريد الإلكتروني غير صحيحة.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      _created ??= await widget.repository.createUser(
        name: name,
        username: username,
        password: password,
        email: email.isEmpty ? null : email,
      );
      final user = _created!;
      if (_role == AdminAccountRole.teacher) {
        final teacherId = await widget.repository.createTeacher(name);
        await widget.repository.linkTeacherToUser(user.id, teacherId);
      }
      if (!mounted) return;
      Navigator.of(context).pop(CreatedAccount(user: user, role: _role));
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'تعذّر إنشاء الحساب: $error');
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
            'حساب جديد',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            'أنشئ حساب مشرف أو مدرس دون إنشاء طالب. اسم المستخدم يبدأ '
            'بسابقة المسجد دائمًا.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final role in AdminAccountRole.values) ...[
                Expanded(child: _roleCard(context, role)),
                if (role != AdminAccountRole.values.last)
                  const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'الاسم الكامل'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _username,
            textDirection: TextDirection.ltr,
            textInputAction: TextInputAction.next,
            enabled: !_loadingCode,
            decoration: InputDecoration(
              labelText: 'اسم المستخدم',
              hintText: _mosqueCode.isEmpty ? 'username' : '$_mosqueCode-name',
              helperText: _mosqueCode.isEmpty
                  ? 'سابقة المسجد غير متاحة الآن — سيولدها الخادم إن تركت الحقل فارغًا.'
                  : 'السابقة الثابتة: $_mosqueCode- (لا يمكن تغييرها).',
              suffixIcon: _loadingCode
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: _obscure,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
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
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'البريد الإلكتروني (اختياري)',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            AppCard(
              color: tokens.danger.withValues(alpha: 0.08),
              borderColor: tokens.danger,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 18, color: tokens.dangerText),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(color: tokens.dangerText, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          AppButton(
            label: _busy ? 'جارٍ إنشاء الحساب…' : 'إنشاء الحساب',
            icon: Icons.person_add_alt_1,
            loading: _busy,
            onPressed: _busy || _loadingCode ? null : _submit,
          ),
          const SizedBox(height: 8),
          Text(
            _role.hint,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _roleCard(BuildContext context, AdminAccountRole role) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final selected = _role == role;
    final color = role == AdminAccountRole.teacher
        ? tokens.accentMatn
        : tokens.info;
    return InkWell(
      borderRadius: BorderRadius.circular(tokens.radiusSmall),
      onTap: _busy ? null : () => setState(() => _role = role),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : tokens.surfacePage,
          borderRadius: BorderRadius.circular(tokens.radiusSmall),
          border: Border.all(
            color: selected ? color : tokens.borderStructural,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              role == AdminAccountRole.teacher
                  ? Icons.school_outlined
                  : Icons.admin_panel_settings_outlined,
              color: selected ? color : tokens.textMuted,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                role.label,
                style: TextStyle(
                  color: selected ? color : tokens.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (selected) Icon(Icons.check_circle, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}
