import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';

/// E18 — Admin "حسابي": profile card + editable fields (like the student
/// page) + change password + switch account + filled-red logout.
class AdminAccountScreen extends StatefulWidget {
  const AdminAccountScreen({super.key});

  @override
  State<AdminAccountScreen> createState() => _AdminAccountScreenState();
}

class _AdminAccountScreenState extends State<AdminAccountScreen> {
  late final _name = TextEditingController(text: 'مدير المسجد');
  late final _username = TextEditingController(text: 'admin');
  late final _mosque = TextEditingController(text: 'جامع الفرقان · frq');
  late final _phone = TextEditingController(text: '+201000000000');

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _mosque.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: tokens.infoTint,
                  child: Icon(Icons.admin_panel_settings,
                      color: tokens.info, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_name.text,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          StatusBadge(label: 'أدمن', color: tokens.info),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(_mosque.text,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: tokens.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(icon: Icons.person_outline, title: 'البيانات'),
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
                  
                  decoration: const InputDecoration(labelText: 'اسم المستخدم'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _mosque,
                  
                  decoration: const InputDecoration(labelText: 'المسجد'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  
                  decoration: const InputDecoration(labelText: 'الهاتف'),
                ),
                const SizedBox(height: 10),
                AppButton(
                  label: 'حفظ البيانات',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {
                    _notice(context, 'تم حفظ البيانات (تجريبي)');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(icon: Icons.security_outlined, title: 'الأمان والحساب'),
          const SizedBox(height: 8),
          _tile(context, Icons.lock_outline, 'تغيير كلمة المرور',
              () => _changePassword(context)),
          const SizedBox(height: 8),
          AppButton(
            label: 'تبديل الحساب',
            variant: AppButtonVariant.secondary,
            icon: Icons.swap_horiz,
            onPressed: () => _notice(context, 'تبديل الحساب (وضع تجريبي)'),
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
    context.read<AuthCubit>().logout();
  }

  Widget _tile(BuildContext context, IconData icon, String label,
      VoidCallback onTap) {
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
              child: Text(label,
                  style: TextStyle(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          Icon(Icons.chevron_left, color: tokens.borderStructural),
        ],
      ),
    );
  }

  void _notice(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _changePassword(BuildContext context) {
    final oldPw = TextEditingController();
    final newPw = TextEditingController();
    final confirm = TextEditingController();
    var error = '';
    showModalBottomSheet<void>(
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
              Text('تغيير كلمة المرور',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              TextField(
                  controller: oldPw,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'الحالية')),
              const SizedBox(height: 12),
              TextField(
                  controller: newPw,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'الجديدة')),
              const SizedBox(height: 12),
              TextField(
                  controller: confirm,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: 'التأكيد',
                      errorText: error.isEmpty ? null : error)),
              const SizedBox(height: 16),
              AppButton(
                label: 'حفظ',
                onPressed: () {
                  if (newPw.text.isEmpty || newPw.text != confirm.text) {
                    setSheetState(() => error = 'كلمتا المرور غير متطابقتين');
                    return;
                  }
                  Navigator.of(context).pop();
                  _notice(context, 'تم تغيير كلمة المرور (تجريبي)');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
