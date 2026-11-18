import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import '../storage/screen_cache.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/skeleton.dart';

/// Limits how many section requests are in flight at once.
///
/// Pages are built from several independent [AsyncSection] cards, so the
/// scheduler runs their requests **one at a time in enqueue order**. This
/// avoids firing every endpoint of a page simultaneously and keeps the first
/// (above-the-fold) section ahead of the rest.
class SectionScheduler {
  SectionScheduler._();

  static final SectionScheduler instance = SectionScheduler._();

  static const int _maxConcurrent = 1;

  int _active = 0;
  final Queue<void Function()> _queue = Queue<void Function()>();

  Future<T> run<T>(Future<T> Function() job) {
    final completer = Completer<T>();

    void start() {
      _active++;
      Future<T>.sync(job)
          .then(
            (value) {
              if (!completer.isCompleted) completer.complete(value);
            },
            onError: (Object error, StackTrace stack) {
              if (!completer.isCompleted) {
                completer.completeError(error, stack);
              }
            },
          )
          .whenComplete(() {
            _active--;
            _drain();
          });
    }

    if (_active < _maxConcurrent) {
      start();
    } else {
      _queue.add(start);
    }
    return completer.future;
  }

  void _drain() {
    while (_active < _maxConcurrent && _queue.isNotEmpty) {
      _queue.removeFirst()();
    }
  }
}

/// A single independently-loading section of a page.
///
/// Unlike the page-level `AsyncView`, a slow card never blocks the rest of the
/// page: it shows a compact [SectionSkeleton] while its own future runs, keeps
/// previously cached content visible during a refresh, and offers a small
/// inline retry instead of replacing the whole screen with an error page.
///
/// * [cacheKey] enables the session-only [ScreenCache] (immediate stale paint).
/// * [delay] staggers secondary sections so the first screenful wins the
///   request queue.
/// * [revision] lets a pull-to-refresh bump every section at once.
class AsyncSection<T> extends StatefulWidget {
  const AsyncSection({
    super.key,
    required this.load,
    required this.builder,
    this.cacheKey,
    this.skeleton,
    this.delay = Duration.zero,
    this.revision = 0,
    this.errorBuilder,
  });

  final Future<T> Function() load;
  final Widget Function(BuildContext context, T data) builder;
  final String? cacheKey;
  final Widget? skeleton;
  final Duration delay;
  final int revision;
  final Widget Function(BuildContext context, VoidCallback retry)? errorBuilder;

  @override
  State<AsyncSection<T>> createState() => _AsyncSectionState<T>();
}

class _AsyncSectionState<T> extends State<AsyncSection<T>> {
  T? _data;
  bool _hasData = false;
  Object? _error;
  int _requestId = 0;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _readCache();
    _schedule();
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AsyncSection<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cacheKey != widget.cacheKey) {
      _data = null;
      _hasData = false;
      _readCache();
      _schedule();
      return;
    }
    if (oldWidget.revision != widget.revision) _schedule();
  }

  void _readCache() {
    final key = widget.cacheKey;
    if (key == null) return;
    final cached = ScreenCache.instance.read<T>(key);
    if (cached == null) return;
    _data = cached;
    _hasData = true;
  }

  void _schedule() {
    final id = ++_requestId;
    _delayTimer?.cancel();
    _error = null;
    Future<void> start() async {
      if (!mounted || id != _requestId) return;
      try {
        final value = await SectionScheduler.instance.run(widget.load);
        if (!mounted || id != _requestId) return;
        final key = widget.cacheKey;
        if (key != null) ScreenCache.instance.write(key, value);
        setState(() {
          _data = value;
          _hasData = true;
          _error = null;
        });
      } catch (error) {
        if (!mounted || id != _requestId) return;
        setState(() {
          _error = error;
        });
      }
    }

    if (widget.delay > Duration.zero) {
      _delayTimer = Timer(widget.delay, () {
        if (mounted && id == _requestId) unawaited(start());
      });
    } else {
      // Let the page shell paint before the first request starts.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && id == _requestId) unawaited(start());
      });
    }
  }

  void _retry() {
    setState(() {
      _error = null;
    });
    _schedule();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasData) return widget.builder(context, _data as T);
    if (_error != null) {
      final custom = widget.errorBuilder;
      if (custom != null) return custom(context, _retry);
      return SectionError(onRetry: _retry);
    }
    return widget.skeleton ?? const SectionSkeleton();
  }
}

/// Card-shaped skeleton used while an [AsyncSection] loads for the first time.
class SectionSkeleton extends StatelessWidget {
  const SectionSkeleton({
    super.key,
    this.height = 72,
    this.lines = 2,
    this.showCard = true,
  });

  final double height;
  final int lines;
  final bool showCard;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Skeleton(width: 34, height: 34, radius: 10),
            SizedBox(width: 10),
            Expanded(child: Skeleton(height: 14)),
            SizedBox(width: 12),
            Skeleton(width: 44, height: 14),
          ],
        ),
        const SizedBox(height: 12),
        Skeleton(height: height),
        for (var i = 1; i < lines; i++) ...[
          const SizedBox(height: 8),
          const Skeleton(height: 12, width: 180),
        ],
      ],
    );
    if (!showCard) return body;
    return AppCard(child: body);
  }
}

/// Compact inline error with a retry, used inside a section instead of a
/// full-page error view.
class SectionError extends StatelessWidget {
  const SectionError({
    super.key,
    required this.onRetry,
    this.message = 'تعذر تحميل هذا القسم',
  });

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, size: 18, color: tokens.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}
