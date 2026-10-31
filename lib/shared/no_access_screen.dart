import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/router/route_guards.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_button.dart';
import '../core/widgets/app_card.dart';
import '../features/auth/presentation/cubits/auth_cubit.dart';
import '../features/auth/presentation/cubits/auth_state.dart';

/// Sends the user back to the previous page when possible; otherwise to their
/// role landing page. Never pops back to a guarded route in a loop.
void goBackOrHome(BuildContext context) {
  if (context.canPop()) {
    context.pop();
    return;
  }
  goHome(context);
}

/// Goes to the user's first available section (or the splash when signed out).
void goHome(BuildContext context) {
  var target = '/';
  try {
    final auth = context.read<AuthCubit>().state;
    if (auth is AuthAuthenticated) target = firstSectionPath(auth.profile);
  } catch (_) {
    // Widget tests may mount a page without an AuthCubit.
  }
  context.go(target);
}

/// Arabic, scaffolded "no permission" page with retry and a safe way back.
class NoAccessScreen extends StatelessWidget {
  const NoAccessScreen({super.key, this.onRetry, this.message});

  final Future<void> Function()? onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        goHome(context);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'العودة',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => goHome(context),
          ),
          title: const Text('لا تملك الصلاحية'),
        ),
        body: NoAccessView(
          message: message,
          onRetry: onRetry == null
              ? null
              : () {
                  onRetry!();
                },
          onBack: () => goHome(context),
          backLabel: 'العودة للرئيسية',
        ),
      ),
    );
  }
}

/// Content-only variant reused by [NoAccessScreen] and by async error states.
class NoAccessView extends StatelessWidget {
  const NoAccessView({
    super.key,
    this.message,
    this.onRetry,
    this.onBack,
    this.backLabel = 'رجوع',
  });

  final String? message;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: tokens.infoTint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    color: tokens.info,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'لا تملك الصلاحية لعمل هذا الإجراء',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: tokens.info,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message ??
                      'هذا الإجراء غير متاح لحسابك. راجع المشرف العام إذا كنت '
                          'تعتقد أن لديك الصلاحية.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.textSecondary,
                    height: 1.5,
                  ),
                ),
                if (onRetry != null || onBack != null) ...[
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (onRetry != null)
                        AppButton(
                          label: 'إعادة المحاولة',
                          icon: Icons.refresh,
                          variant: AppButtonVariant.secondary,
                          expand: false,
                          onPressed: onRetry,
                        ),
                      if (onBack != null)
                        AppButton(
                          label: backLabel,
                          icon: Icons.arrow_back,
                          variant: AppButtonVariant.secondary,
                          expand: false,
                          onPressed: onBack,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
