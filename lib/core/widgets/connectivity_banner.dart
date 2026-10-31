import 'package:flutter/material.dart';

import '../network/connectivity_status.dart';
import '../theme/app_theme.dart';

/// Shows a thin banner when the app is offline and serving cached reads.
///
/// The offline state itself is hysteresis-driven in [ConnectivityStatus], so
/// the banner only appears after the outage is sustained; the animations here
/// just avoid a hard layout jump when it shows/hides.
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key, this.status});

  /// Optional status override for tests; defaults to the app-wide instance.
  final ConnectivityStatus? status;

  @override
  Widget build(BuildContext context) {
    final connectivity = status ?? ConnectivityStatus.instance;
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return ValueListenableBuilder<bool>(
      valueListenable: connectivity.online,
      builder: (context, online, _) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: online
                ? const SizedBox.shrink(key: ValueKey<String>('online'))
                : Container(
                    key: const ValueKey<String>('offline'),
                    width: double.infinity,
                    color: tokens.reward.withValues(alpha: 0.12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_off_outlined,
                          size: 16,
                          color: tokens.rewardText,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'وضع عدم الاتصال — تُعرض بيانات مخزنة للقراءة فقط',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: tokens.rewardText,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
