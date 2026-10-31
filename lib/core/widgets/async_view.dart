import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../storage/screen_cache.dart';
import '../theme/app_theme.dart';
import 'app_loading.dart';

/// Generic async-content view with stale-while-revalidate support.
///
/// - [cached] is read immediately and rendered while [future] refreshes in the
///   background (thin progress line, no blocking loader).
/// - A first load with no cached value shows [AppLoadingView].
/// - A first-load failure shows [AppErrorView] with retry.
/// - A refresh failure keeps the cached/previous content and shows a stale line.
class AsyncView<T> extends StatefulWidget {
  const AsyncView({
    super.key,
    required this.future,
    required this.builder,
    this.cached,
    this.loading,
    this.onRetry,
    this.cacheKey,
    this.errorTitle = 'تعذر التحميل',
  });

  final Future<T> future;
  final Future<T?>? cached;

  /// Optional stable key. When omitted, the current route + payload type is
  /// used so revisiting a page shows its previous content immediately.
  final String? cacheKey;
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
  bool _revalidating = false;
  bool _networkDone = false;
  Object? _error;
  Object? _staleError;
  String? _cacheKey;
  bool _cacheRead = false;

  @override
  void initState() {
    super.initState();
    _subscribeCached(widget.cached);
    _subscribe(widget.future);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_cacheRead) return;
    _cacheRead = true;
    final key = widget.cacheKey;
    if (key == null) return;
    _cacheKey = key;
    final cached = ScreenCache.instance.read<T>(key);
    if (cached != null && !_hasData) {
      _data = cached;
      _hasData = true;
      _revalidating = true;
    }
  }

  @override
  void didUpdateWidget(AsyncView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.cached, widget.cached)) {
      _subscribeCached(widget.cached);
    }
    if (!identical(oldWidget.future, widget.future)) {
      _subscribe(widget.future);
    }
  }

  void _subscribeCached(Future<T?>? future) {
    if (future == null) return;
    future.then(
      (value) {
        if (!mounted || value == null || _networkDone) return;
        final key = _cacheKey;
        if (key != null) ScreenCache.instance.write(key, value);
        setState(() {
          _data = value;
          _hasData = true;
          _waiting = false;
          _revalidating = true;
          _staleError = null;
        });
      },
      onError: (Object _) {
        // A missing cache is normal; the network request still runs.
      },
    );
  }

  void _subscribe(Future<T> future) {
    _activeFuture = future;
    _waiting = true;
    _failed = false;
    _networkDone = false;
    _error = null;
    future.then(
      (value) {
        if (!mounted || !identical(_activeFuture, future)) return;
        final key = _cacheKey;
        if (key != null) ScreenCache.instance.write(key, value);
        setState(() {
          _networkDone = true;
          _data = value;
          _hasData = true;
          _waiting = false;
          _failed = false;
          _revalidating = false;
          _staleError = null;
        });
      },
      onError: (Object error) {
        if (!mounted || !identical(_activeFuture, future)) return;
        setState(() {
          _networkDone = true;
          _waiting = false;
          _revalidating = false;
          if (_hasData) {
            _staleError = error;
          } else {
            _failed = true;
            _error = error;
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_waiting && !_hasData) {
      return widget.loading ?? const AppLoadingView();
    }
    if (_failed && !_hasData) {
      VoidCallback? retry = widget.onRetry;
      if (retry == null) {
        try {
          final path = GoRouterState.of(context).uri.toString();
          retry = () => context.go(path);
        } catch (_) {
          retry = null;
        }
      }
      return AppErrorView(
        error: _error,
        title: widget.errorTitle,
        onRetry: retry,
      );
    }

    final content = widget.builder(context, _data as T);
    final showLine = _revalidating || _staleError != null;
    if (!showLine) return content;

    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Stack(
      children: [
        content,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _revalidating
              ? LinearProgressIndicator(
                  minHeight: 2,
                  color: tokens.brand,
                  backgroundColor: tokens.surfaceSubtle,
                )
              : Container(height: 2, color: tokens.reward),
        ),
      ],
    );
  }
}
