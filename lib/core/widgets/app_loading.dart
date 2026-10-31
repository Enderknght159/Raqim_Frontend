import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../network/api_exception.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';
import 'app_card.dart';

/// Three small brand-colored dots with a smooth wave. Deliberately simple:
/// no logo and no long text.
class AppLoadingDots extends StatefulWidget {
  const AppLoadingDots({
    super.key,
    this.size = 11,
    this.spacing = 8,
    this.count = 3,
  });

  final double size;
  final double spacing;
  final int count;

  @override
  State<AppLoadingDots> createState() => _AppLoadingDotsState();
}

class _AppLoadingDotsState extends State<AppLoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final colors = [tokens.brand, tokens.info, tokens.reward];
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.count; i++) ...[
              if (i > 0) SizedBox(width: widget.spacing),
              Transform.translate(
                offset: Offset(
                  0,
                  reduceMotion
                      ? 0
                      : -5 *
                            math.sin(
                              (_controller.value + i / widget.count) *
                                  math.pi *
                                  2,
                            ),
                ),
                child: Opacity(
                  opacity: reduceMotion
                      ? 0.85
                      : 0.55 +
                            0.45 *
                                (0.5 +
                                    0.5 *
                                        math.cos(
                                          (_controller.value +
                                                  i / widget.count) *
                                              math.pi *
                                              2,
                                        )),
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

Widget _centeredScrollable(Widget child) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final minHeight = constraints.maxHeight.isFinite
          ? (constraints.maxHeight - 48).clamp(0.0, double.infinity)
          : 0.0;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Center(child: child),
        ),
      );
    },
  );
}

/// Branded first-load state: a calm animated indicator on the page surface.
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final dots = Center(
      child: AppLoadingDots(size: compact ? 9 : 12, spacing: compact ? 6 : 8),
    );
    if (compact) return dots;
    return ColoredBox(
      color: tokens.surfacePage,
      child: SizedBox.expand(child: dots),
    );
  }
}

/// Branded error state with an optional retry action.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    this.error,
    this.title = 'تعذر تحميل البيانات',
    this.onRetry,
  });

  final Object? error;
  final String title;
  final VoidCallback? onRetry;

  String get _message {
    final e = error;
    if (e is ApiException) {
      if (e.isNetwork) {
        return 'لا يوجد اتصال بالإنترنت. تحقق من الشبكة ثم أعد المحاولة.';
      }
      return e.message(arabic: true);
    }
    return 'حدث خطأ غير متوقع. حاول مرة أخرى.';
  }

  bool get _isOffline =>
      error is ApiException && (error as ApiException).isNetwork;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final accent = _isOffline ? tokens.rewardText : tokens.dangerText;
    final tint = _isOffline
        ? tokens.reward.withValues(alpha: 0.12)
        : tokens.danger.withValues(alpha: 0.08);
    return ColoredBox(
      color: tokens.surfacePage,
      child: _centeredScrollable(
        AppCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
                child: Icon(
                  _isOffline
                      ? Icons.cloud_off_outlined
                      : Icons.error_outline_rounded,
                  color: accent,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _isOffline ? 'لا يوجد اتصال' : title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: tokens.info,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 18),
                AppButton(
                  label: 'إعادة المحاولة',
                  icon: Icons.refresh,
                  variant: AppButtonVariant.secondary,
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
