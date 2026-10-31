/// In-memory, session-only cache of the last successful `AsyncView` payload
/// for a route. Keeps the previous page content visible while it revalidates,
/// including the first frame after navigating back to a page. Never persisted;
/// [clear] is called whenever the active account changes.
class ScreenCache {
  ScreenCache._();

  static final ScreenCache instance = ScreenCache._();

  final Map<String, Object?> _values = {};

  T? read<T>(String key) {
    final value = _values[key];
    return value is T ? value : null;
  }

  void write<T>(String key, T value) {
    _values[key] = value;
  }

  void clear() => _values.clear();
}
