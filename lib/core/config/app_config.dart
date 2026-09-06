/// App configuration loaded from `--dart-define` flags.
///
/// Usage:
///   flutter run --dart-define=API_BASE_URL=https://api.raqim.example --dart-define=ENV=staging
class AppConfig {
  AppConfig._();

  /// Base URL of the Django REST API. Defaults to a local dev server.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
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

  static bool get isProd => env == 'prod';
  static bool get isStaging => env == 'staging';
  static bool get isDev => env == 'dev';
}