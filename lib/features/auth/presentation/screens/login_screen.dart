import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/raqim_logo.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';

/// A3 — Password step (`/login?username=...`).
///
/// Second step of the two-step auth: the username (which resolved the mosque)
/// is shown read-only, and the field focus is on the password.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.username = ''});

  final String username;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _submitted = false;
  bool _inFlight = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _submitted = true);
      return;
    }
    if (_inFlight) return;
    _inFlight = true;
    context.read<AuthCubit>().login(widget.username, password).whenComplete(() {
      if (mounted) setState(() => _inFlight = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 8,
            bottom: 24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final loading = state is AuthLoginLoading;
                  final error =
                      state is AuthLoginFailure ? state.error : null;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: IconButton(
                          tooltip: 'رجوع',
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(child: RaqimLogo(size: 120)),
                      const SizedBox(height: 16),
                      _identityCard(tokens),
                      const SizedBox(height: 24),
                      Text(
                        'تسجيل الدخول',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: tokens.info,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'أدخل كلمة المرور للمتابعة',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: tokens.textMuted),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        autofocus: true,
                        obscureText: _obscure,
                        onChanged: (_) {
                          if (_submitted) setState(() => _submitted = false);
                        },
                        onSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _obscure ? 'إظهار' : 'إخفاء',
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                          errorText:
                              _submitted && _passwordController.text.isEmpty
                                  ? 'أدخل كلمة المرور'
                                  : null,
                        ),
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 16),
                        _errorBanner(tokens, error),
                      ],
                      const SizedBox(height: 24),
                      AppButton(
                        label: 'دخول',
                        trailingIcon: Icons.arrow_forward,
                        loading: loading,
                        onPressed: _submit,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _identityCard(AppTokens tokens) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.brandTint,
        borderRadius: BorderRadius.circular(tokens.radiusMedium),
        border: Border.all(color: tokens.brandBorder, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.account_circle, size: 40, color: tokens.brandText),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.username.isEmpty ? '—' : widget.username,
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: tokens.info,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'يتم تحديد المسجد تلقائيًا من اسم المستخدم',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBanner(AppTokens tokens, ApiException error) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tokens.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(tokens.radiusSmall),
        border: Border.all(color: tokens.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: tokens.danger, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error.message(arabic: true),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: tokens.dangerText),
            ),
          ),
        ],
      ),
    );
  }
}
