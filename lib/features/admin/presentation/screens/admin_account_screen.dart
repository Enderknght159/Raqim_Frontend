import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/cubits/auth_state.dart';
import '../../../../shared/account_switcher.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

/// E18 — Admin "حسابي": profile card + editable fields (like the student
/// page) + change password + switch account + filled-red logout.
class AdminAccountScreen extends StatefulWidget {
  const AdminAccountScreen({super.key});

  @override
  State<AdminAccountScreen> createState() => _AdminAccountScreenState();
}

class _AdminAccountScreenState extends State<AdminAccountScreen> {
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _phone = TextEditingController();
  bool _initialized = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    AuthState? auth;
    try {
      auth = context.read<AuthCubit>().state;
    } catch (_) {
      auth = null;
    }
    if (auth is AuthAuthenticated) {
      final profile = auth.profile;
      _name.text = profile.name;
      _username.text = profile.username ?? '';
      _phone.text = profile.phone ?? '';
    } else {
      // Standalone render (widget tests / no auth scope).
      _name.text = 'مدير المسجد';
      _username.text = 'admin';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    AuthState? auth;
    try {
      auth = context.watch<AuthCubit>().state;
    } catch (_) {
      auth = null;
    }
    final profile = auth is AuthAuthenticated ? auth.profile : null;
    return Scaffold(
      body: ResponsivePage(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: tokens.infoTint,
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: tokens.info,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.name ?? _name.text,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            StatusBadge(
                              label: profile?.role.arabicName ?? 'أدمن',
                              color: tokens.info,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [profile?.mosqueName, profile?.mosqueCode]
                              .whereType<String>()
                              .where((e) => e.isNotEmpty)
                              .join(' · '),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: tokens.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SectionHeader(
              icon: Icons.person_outline,
              title: 'بيانات الحساب',
            ),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'الاسم'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _username,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'اسم المستخدم',
                      helperText: 'لا يمكن تغيير اسم المستخدم من هنا',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'الهاتف'),
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: _saving ? 'جارٍ الحفظ…' : 'حفظ البيانات',
                    variant: AppButtonVariant.secondary,
                    loading: _saving,
                    onPressed: _saving ? null : () => _save(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SectionHeader(
              icon: Icons.security_outlined,
              title: 'الأمان والحساب',
            ),
            const SizedBox(height: 8),
            _tile(
              context,
              Icons.lock_outline,
              'تغيير كلمة المرور',
              () => _changePassword(context),
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'تبديل الحساب',
              variant: AppButtonVariant.secondary,
              icon: Icons.swap_horiz,
              onPressed: () => _switchAccount(context),
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'خروج',
              variant: AppButtonVariant.destructive,
              icon: Icons.logout,
              onPressed: () => _confirmLogout(context),
            ),
            const SizedBox(height: 16),
            const SectionHeader(
              icon: Icons.mosque_outlined,
              title: 'بيانات المسجد',
            ),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _readOnlyRow(context, 'المسجد', profile?.mosqueName ?? '—'),
                  _readOnlyRow(context, 'الرمز', profile?.mosqueCode ?? '—'),
                  const SizedBox(height: 4),
                  Text(
                    profile?.isAdmin == true
                        ? 'تعديل بيانات المسجد من تبويب النظام ← الإعدادات.'
                        : 'بيانات المسجد للقراءة فقط، وتعديلها من صلاحية المشرف العام.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Confirms before ending the session (admin side).
  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).extension<AppTokens>()!.danger,
            ),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final next = await context.read<AuthCubit>().logout();
    if (!context.mounted) return;
    context.go(next == null ? '/welcome' : '/');
  }

  Future<void> _save(BuildContext context) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await context.read<AuthCubit>().updateProfile(
        name: _name.text.trim(),
        phone: _phone.text.trim(),
      );
      if (!context.mounted) return;
      _notice(context, 'تم حفظ البيانات');
    } catch (e) {
      if (!context.mounted) return;
      _notice(context, 'تعذّر الحفظ: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _switchAccount(BuildContext context) {
    showAccountSwitcher(context);
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: tokens.textPrimary),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                label,
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
    );
  }

  Widget _readOnlyRow(BuildContext context, String label, String value) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(color: tokens.textMuted, fontSize: 13),
      ),
      subtitle: Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      trailing: Icon(Icons.lock_outline, size: 18, color: tokens.textMuted),
    );
  }

  void _notice(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _changePassword(BuildContext context) {
    final oldPw = TextEditingController();
    final newPw = TextEditingController();
    final confirm = TextEditingController();
    var error = '';
    var busy = false;
    showAppSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 0,
            bottom: 28 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'تغيير كلمة المرور',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: oldPw,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'الحالية'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPw,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'الجديدة'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirm,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'التأكيد',
                  errorText: error.isEmpty ? null : error,
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: busy ? 'جارٍ الحفظ…' : 'حفظ',
                loading: busy,
                onPressed: busy
                    ? null
                    : () async {
                        final oldValue = oldPw.text;
                        final newValue = newPw.text;
                        final confirmValue = confirm.text;
                        if (oldValue.isEmpty) {
                          setSheetState(
                            () => error = 'أدخل كلمة المرور الحالية',
                          );
                          return;
                        }
                        if (newValue.length < 6) {
                          setSheetState(
                            () =>
                                error = 'كلمة المرور الجديدة 6 أحرف على الأقل',
                          );
                          return;
                        }
                        if (newValue != confirmValue) {
                          setSheetState(
                            () => error = 'كلمتا المرور غير متطابقتين',
                          );
                          return;
                        }
                        if (newValue == oldValue) {
                          setSheetState(
                            () => error = 'اختر كلمة مرور مختلفة عن الحالية',
                          );
                          return;
                        }
                        setSheetState(() {
                          busy = true;
                          error = '';
                        });
                        try {
                          await context.read<AuthCubit>().changePassword(
                            oldPassword: oldValue,
                            newPassword: newValue,
                            newPasswordConfirmation: confirmValue,
                          );
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                          _notice(context, 'تم تغيير كلمة المرور');
                        } catch (e) {
                          if (!context.mounted) return;
                          setSheetState(() {
                            busy = false;
                            error = 'تعذّر التغيير: $e';
                          });
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
