import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

/// Log severity levels (higher = more important).
enum AppLogLevel {
  verbose(0, 'VERBOSE', '\x1B[90m'),
  debug(1, 'DEBUG', '\x1B[36m'),
  info(2, 'INFO', '\x1B[32m'),
  warning(3, 'WARN', '\x1B[33m'),
  error(4, 'ERROR', '\x1B[31m');

  const AppLogLevel(this.rank, this.label, this.ansi);

  final int rank;
  final String label;
  final String ansi;
}

const _ansiReset = '\x1B[0m';

/// App-wide logging service.
///
/// - Levels are filtered by a single global [AppLogLevel.minLevel].
/// - Each logger carries a `tag` (feature/screen) so lines are greppable.
/// - Output goes through [outputSink] (defaults to [debugPrint], which is
///   throttled and stripped in release builds).
///
/// Usage:
/// ```dart
/// final log = AppLogger.forTag('Auth');
/// log.info('Login successful');
/// ```
class AppLogger {
  AppLogger({String tag = 'App'}) : _tag = tag;

  /// Tagged logger for a feature/screen (e.g. `Auth`, `API`, `Courses`).
  static AppLogger forTag(String tag) => AppLogger(tag: tag);

  /// Global minimum level. Lines below it are dropped.
  static AppLogLevel minLevel = _minLevelFromConfig();

  /// Global master switch.
  static bool enabled = AppConfig.loggingEnabled;

  /// Where lines go. Overridable in tests.
  static void Function(String line) outputSink = debugPrint;

  final String _tag;

  void verbose(String message, {Object? error}) =>
      _log(AppLogLevel.verbose, message, error);
  void debug(String message, {Object? error}) =>
      _log(AppLogLevel.debug, message, error);
  void info(String message, {Object? error}) =>
      _log(AppLogLevel.info, message, error);
  void warning(String message, {Object? error}) =>
      _log(AppLogLevel.warning, message, error);
  void error(String message, {Object? error}) =>
      _log(AppLogLevel.error, message, error);

  void _log(AppLogLevel level, String message, Object? error) {
    if (!enabled || level.rank < minLevel.rank) return;
    final timestamp = _time();
    final errorPart = error == null ? '' : '\n$error';
    final line = '${level.ansi}[$timestamp][${level.label}][$_tag]'
        '$_ansiReset $message$errorPart';
    outputSink(line);
  }

  static String _time() {
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(now.hour)}:${two(now.minute)}:${two(now.second)}.'
        '${now.millisecond.toString().padLeft(3, '0')}';
  }

  static AppLogLevel _minLevelFromConfig() {
    return AppLogLevel.values.firstWhere(
      (l) => l.name == AppConfig.logLevel,
      orElse: () => AppLogLevel.debug,
    );
  }
}