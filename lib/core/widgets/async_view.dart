import 'package:flutter/material.dart';

import 'skeleton.dart';

/// Generic async-content view: shows a skeleton while the **first** load is
/// pending, the content once ready, or an error/retry state.
///
/// Reloads (a new [future] passed in) are silent: the previous content stays
/// on screen until the new data arrives — no skeleton flash when refreshing a
/// page or when a bottom sheet closes and the page it opened from reloads.
class AsyncView<T> extends StatefulWidget {
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
  State<AsyncView<T>> createState() => _AsyncViewState<T>();
}

class _AsyncViewState<T> extends State<AsyncView<T>> {
  Future<T>? _activeFuture;
  T? _data;
  bool _hasData = false;
  bool _waiting = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _subscribe(widget.future);
  }

  @override
  void didUpdateWidget(AsyncView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.future, widget.future)) {
      _subscribe(widget.future);
    }
  }

  void _subscribe(Future<T> future) {
    _activeFuture = future;
    _waiting = true;
    _failed = false;
    future.then(
      (value) {
        if (!mounted || !identical(_activeFuture, future)) return;
        setState(() {
          _data = value;
          _hasData = true;
          _waiting = false;
        });
      },
      onError: (Object error) {
        if (!mounted || !identical(_activeFuture, future)) return;
        setState(() {
          _waiting = false;
          _failed = true;
        });
      },
    );
  }

  void _retry() => widget.onRetry?.call();

  @override
  Widget build(BuildContext context) {
    // First load (no previous data yet): skeleton.
    if (_waiting && !_hasData) {
      return widget.loading ??
          const Padding(
            padding: EdgeInsets.all(16),
            child: SkeletonBlock(rows: 4),
          );
    }
    // Error on the first load only — a failed reload keeps the stale content.
    if (_failed && !_hasData) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(widget.errorTitle),
            if (widget.onRetry != null) ...[
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _retry,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      );
    }
    return widget.builder(context, _data as T);
  }
}
