import 'dart:async';

/// Shares one repository request between several independently-loading
/// section cards on the same page.
///
/// A page may need the same payload in two places (the Quran map and the
/// certificates card both read the certificate list). Each section still owns
/// its own skeleton/error/retry, but the request itself runs once per
/// [revision]: bumping the revision (pull-to-refresh, writes) drops the memo,
/// so every section refetches.
///
/// A failed request is forgotten immediately, which means the inline
/// «إعادة المحاولة» of a section really retries instead of reusing a rejected
/// future.
class SectionMemo<T> {
  SectionMemo(this._load);

  final Future<T> Function() _load;

  int _revision = -1;
  Future<T>? _future;

  /// Returns the in-flight (or finished) future for [revision], starting a new
  /// request only when the revision changed or the previous one failed.
  Future<T> call(int revision) {
    final active = _future;
    if (active != null && _revision == revision) return active;

    final future = _load();
    _revision = revision;
    _future = future;
    unawaited(
      future.then<void>(
        (_) {},
        onError: (Object _, StackTrace _) {
          if (identical(_future, future)) _future = null;
        },
      ),
    );
    return future;
  }
}
