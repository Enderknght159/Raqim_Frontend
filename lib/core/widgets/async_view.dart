import 'package:flutter/material.dart';

import 'skeleton.dart';

/// Generic async-content view: shows a skeleton while loading, the content
/// once ready, or an error/retry state.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.future,
    required this.builder,
    this.loading,
    this.onRetry,
    this.errorTitle = 'تعذر التحميل',
  });

  final Future<T> future;
  final Widget Function(BuildContext, T) builder;
  final Widget? loading;
  final VoidCallback? onRetry;
  final String errorTitle;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading ?? const Padding(
            padding: EdgeInsets.all(16),
            child: SkeletonBlock(rows: 4),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                Text(errorTitle),
                if (onRetry != null) ...[
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: onRetry,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ],
            ),
          );
        }
        return builder(context, snapshot.data as T);
      },
    );
  }
}