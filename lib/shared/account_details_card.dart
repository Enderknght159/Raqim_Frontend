import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/network/api_exception.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_button.dart';
import '../core/widgets/app_card.dart';
import '../features/auth/domain/models/user_profile.dart';
import '../features/auth/presentation/cubits/auth_cubit.dart';
import '../features/auth/presentation/cubits/auth_state.dart';

/// Self-service account form shared by the admin and teacher «حسابي» tabs.
///
/// Every signed-in account owns its display name and login username, even when
/// it holds no permissions, so this card never depends on a module grant. The
/// server still validates uniqueness and rejects student accounts.
class AccountDetailsCard extends StatefulWidget {
  const AccountDetailsCard({super.key, this.showPhone = false, this.onSaved});

  /// Account phone is only exposed to the mosque admin (others manage student
  /// phones from the students module).
  final bool showPhone;

  final ValueChanged<UserProfile>? onSaved;

  @override
  State<AccountDetailsCard> createState() => _AccountDetailsCardState();
}

class _AccountDetailsCardState extends State<AccountDetailsCard> {
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _phone = TextEditingController();
  bool _initialized = false;
  bool _saving = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final profile = _readProfile();
    _name.text = profile?.name ?? 'مدير المسجد';
    _username.text = profile?.username ?? '';
    _phone.text = profile?.phone ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _phone.dispose();
    super.dispose();
  }

  UserProfile? _readProfile() {
    try {
      final auth = context.read<AuthCubit>().state;
      return auth is AuthAuthenticated ? auth.profile : null;
    } catch (_) {
      // Standalone render (widget tests / no auth scope).
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const ValueKey('account-name'),
            controller: _name,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'الاسم الكامل'),
          ),
          const SizedBox(height: 10),
          TextField(
            key: const ValueKey('account-username'),
            controller: _username,
            textDirection: TextDirection.ltr,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(
              labelText: 'اسم المستخدم',
              helperText: 'يُستخدم لتسجيل الدخول — حروف إنجليزية وأرقام',
            ),
          ),
          if (widget.showPhone) ...[
            const SizedBox(height: 10),
            TextField(
              key: const ValueKey('account-phone'),
              controller: _phone,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(labelText: 'الهاتف'),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.danger),
            ),
          ],
          const SizedBox(height: 12),
          AppButton(
            key: const ValueKey('account-save'),
            label: _saving ? 'جارٍ الحفظ…' : 'حفظ البيانات',
            variant: AppButtonVariant.secondary,
            loading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    final name = _name.text.trim();
    final username = _username.text.trim();
    final phone = _phone.text.trim();

    if (name.isEmpty) {
      setState(() => _error = 'أدخل الاسم الكامل');
      return;
    }
    if (username.isEmpty) {
      setState(() => _error = 'أدخل اسم المستخدم');
      return;
    }
    if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]{2,99}$').hasMatch(username)) {
      setState(
        () => _error =
            'اسم المستخدم 3 أحرف على الأقل، ويقبل الحروف الإنجليزية '
            'والأرقام والنقطة والشرطة فقط',
      );
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await context.read<AuthCubit>().updateProfile(
        name: name,
        username: username,
        phone: widget.showPhone ? phone : null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('تم حفظ البيانات')));
      final profile = _readProfile();
      if (profile != null) widget.onSaved?.call(profile);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message(arabic: true));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'تعذّر الحفظ: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
