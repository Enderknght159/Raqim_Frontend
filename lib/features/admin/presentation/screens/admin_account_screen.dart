import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/cubits/auth_state.dart';
import '../../../../shared/account_details_card.dart';
import '../../../../shared/account_switcher.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

/// E18 — Admin "حسابي": profile card + editable name/username + password
/// (mosque admin) + switch account + filled-red logout.
///
/// The profile and logout stay available even when the account holds no
/// permissions; only the password tile is restricted to the mosque admin.
class AdminAccountScreen extends StatefulWidget {
  const AdminAccountScreen({super.key});

  @override
  State<AdminAccountScreen> createState() => _AdminAccountScreenState();
}

class _AdminAccountScreenState extends State<AdminAccountScreen> {
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
    // Account identity (phone/password) is exclusive to the general supervisor
    // (mosque admin). Everyone else manages student phones through the
    // students module when they hold `students.update`.
    final isGeneralSupervisor = profile?.isAdmin == true;
    return Scaffold(
      body: ResponsivePage(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (profile?.hasNoAccess == true)
              InfoBanner(
                key: ValueKey('no-access-${profile!.id}'),
                icon: Icons.lock_outline,
                color: tokens.info,
                message:
                    'لا توجد صلاحيات مرتبطة بحسابك حاليًا. '
                    'يمكنك تعديل ملفك الشخصي أو تسجيل الخروج.',
              ),
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
                          profile?.name ?? 'مدير المسجد',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        if ((profile?.username ?? '').isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            '@${profile!.username}',
                            textDirection: TextDirection.ltr,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: tokens.textMuted),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            StatusBadge(
                              label: profile?.hasNoAccess == true
                                  ? 'بدون صلاحيات'
                                  : profile?.role.arabicName ?? 'أدمن',
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
            AccountDetailsCard(showPhone: isGeneralSupervisor),
            const SizedBox(height: 16),
            const SectionHeader(
              icon: Icons.security_outlined,
              title: 'الأمان والحساب',
            ),
            const SizedBox(height: 8),
            if (isGeneralSupervisor) ...[
              _tile(
                context,
                Icons.lock_outline,
                'تغيير كلمة المرور',
                () => _changePassword(context),
              ),
              const SizedBox(height: 8),
            ],
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
