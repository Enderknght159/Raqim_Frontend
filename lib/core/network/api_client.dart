import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/secure_storage.dart';
import 'api_exception.dart';
import 'token_refresher.dart';

/// Configures the shared [Dio] instance with auth + refresh interceptors and
/// Arabic-first headers. Exposed as a singleton so repositories can depend on
/// a single client.
class ApiClient {
  ApiClient._(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.networkTimeout,
        receiveTimeout: AppConfig.networkTimeout,
        sendTimeout: AppConfig.networkTimeout,
        headers: {
          'Accept-Language': 'ar',
          'Content-Type': 'application/json',
        },
      ),
    );
    _refresher = TokenRefresher(storage: _storage, dio: _dio);
    _dio.interceptors.add(_authInterceptor);
    _dio.interceptors.add(_errorInterceptor);
    if (AppConfig.isDev) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: false),
      );
    }
  }

  static ApiClient? _instance;
  late final Dio _dio;
  late final SecureStorage _storage;
  late final TokenRefresher _refresher;

  /// Returns the shared instance. Call [init] once at app startup.
  static ApiClient get instance {
    final existing = _instance;
    if (existing == null) {
      throw StateError('ApiClient.init() must be called before use');
    }
    return existing;
  }

  static Future<ApiClient> init(SecureStorage storage) async {
    final existing = _instance;
    if (existing != null) return existing;
    final client = ApiClient._(storage);
    _instance = client;
    return client;
  }

  Dio get dio => _dio;

  Interceptor get _authInterceptor => InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final isAuthRequest = error.requestOptions.extra['skipAuth'] == true;
          final is401 = error.response?.statusCode == 401;
          if (is401 && !isAuthRequest && error.requestOptions.extra['retried'] != true) {
            final refreshed = await _refresher.refresh();
            if (refreshed) {
              final token = await _storage.readAccessToken();
              final retry = error.requestOptions;
              retry.extra['retried'] = true;
              retry.headers['Authorization'] = 'Bearer $token';
              try {
                final response = await _dio.fetch(retry);
                return handler.resolve(response);
              } on DioException catch (e) {
                return handler.next(e);
              }
            }
          }
          handler.next(error);
        },
      );

  Interceptor get _errorInterceptor => InterceptorsWrapper(
        onError: (error, handler) {
          handler.next(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: _mapDioError(error),
            ),
          );
        },
      );

  ApiException _mapDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const ApiException.network();
    }
    final status = error.response?.statusCode;
    if (status == 401) return const ApiException.unauthorized();
    if (status != null && status >= 500) return ApiException.server(statusCode: status);
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      return ApiException(
        code: data['code'] as String?,
        messageAr: message is Map ? message['ar'] as String? : null,
        messageEn: message is Map ? message['en'] as String? : null,
        field: data['field'] as String?,
        statusCode: status,
      );
    }
    return ApiException.server(statusCode: status);
  }
}