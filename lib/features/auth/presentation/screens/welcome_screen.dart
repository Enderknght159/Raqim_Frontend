import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_breakpoints.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/character_art.dart';
import '../../../../core/widgets/raqim_logo.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

/// A2 — Welcome / username step (`/welcome`).
///
/// First step of the two-step auth: the user enters their (globally unique)
/// username; the next screen asks for the password.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _usernameController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _continue() {
    final username = _usernameController.text.trim().toLowerCase();
    if (username.isEmpty) {
      setState(() => _submitted = true);
      return;
    }
    context.push('/login?username=${Uri.encodeComponent(username)}');
  }

  void _showUsernameHelp() {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    showAppSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'من أين آتي باسم المستخدم؟',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _helpLine(
              context,
              tokens,
              'اسم المستخدم تصدره إدارة المسجد لجميع الأعضاء.',
            ),
            _helpLine(
              context,
              tokens,
              'إن نسيت بياناتك فاطلبها من مشرف المسجد أو إدارته.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _helpLine(BuildContext context, AppTokens tokens, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: tokens.brand),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= AppBreakpoints.expandedMin;
            final form = _buildForm(tokens);
            final art = const CharacterArt(
              state: CharacterState.welcome,
              size: 200,
            );
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: 24 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: wide
                        ? Row(
                            children: [
                              Expanded(child: Center(child: art)),
                              const SizedBox(width: 48),
                              Expanded(child: Center(child: form)),
                            ],
                          )
                        : Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: form,
                            ),
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm(AppTokens tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Center(child: RaqimLogo(size: 160)),
        const SizedBox(height: 16),
        Text(
          'منصة إدارة الحلقات والمدارس القرآنية',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: _usernameController,
          autofocus: true,
          textInputAction: TextInputAction.go,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
          onChanged: (_) {
            if (_submitted) setState(() => _submitted = false);
          },
          onSubmitted: (_) => _continue(),
          decoration: InputDecoration(
            labelText: 'اسم المستخدم',
            hintText: 'frq-532',
            errorText: _submitted && _usernameController.text.trim().isEmpty
                ? 'أدخل اسم المستخدم'
                : null,
          ),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: 'متابعة',
          trailingIcon: Icons.arrow_forward,
          onPressed: _continue,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _showUsernameHelp,
                child: Text(
                  'من أين آتي باسم المستخدم؟',
                  style: TextStyle(color: tokens.brandText),
                ),
              ),
            ),
            Container(width: 1, height: 18, color: tokens.borderStructural),
            Expanded(
              child: TextButton(
                onPressed: () => context.push('/not-allowed'),
                child: Text(
                  'إضافة مسجدي',
                  style: TextStyle(color: tokens.textMuted),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
