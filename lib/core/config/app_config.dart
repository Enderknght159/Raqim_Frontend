/// App configuration loaded from `--dart-define` flags.
///
/// Usage:
///   flutter run --dart-define=API_BASE_URL=https://api.raqim.example --dart-define=ENV=staging
class AppConfig {
  AppConfig._();

  /// Base URL of the API. Defaults to the live Laravel backend.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://raqim.mayar-hamza.com/api/v1',
  );

  /// Environment name: `dev`, `staging` or `prod`.
  static const String env = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  /// Default app locale.
  static const String defaultLocale = 'ar';

  /// Supported locales (first is default).
  static const List<String> supportedLocales = ['ar', 'en'];

  /// Request timeout for dio calls.
  static const Duration networkTimeout = Duration(seconds: 20);

  /// Master switch for app/API logging. Override with
  /// `--dart-define=LOGGING_ENABLED=false` (e.g. for release builds).
  static const bool loggingEnabled = bool.fromEnvironment(
    'LOGGING_ENABLED',
    defaultValue: true,
  );

  /// Minimum level to emit: `verbose` | `debug` | `info` | `warning` | `error`.
  static const String logLevel = String.fromEnvironment(
    'LOG_LEVEL',
    defaultValue: 'debug',
  );

  /// Whether API log lines include request/response bodies.
  static const bool logApiBodies = bool.fromEnvironment(
    'LOG_API_BODIES',
    defaultValue: true,
  );

  static bool get isProd => env == 'prod';
  static bool get isStaging => env == 'staging';
  static bool get isDev => env == 'dev';
}