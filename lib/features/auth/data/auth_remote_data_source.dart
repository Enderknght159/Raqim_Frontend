import 'package:dio/dio.dart';

import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/connectivity_status.dart';
import '../../../../core/storage/cache_store.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/api_exception.dart';
import '../domain/models/user_profile.dart';

/// Remote auth data source — talks directly to the API.
class AuthRemoteDataSource {
  AuthRemoteDataSource({required Dio dio, CacheStore? cache})
    : _dio = dio,
      _cache = cache;

  static final _log = AppLogger.forTag('AuthAPI');

  final Dio _dio;
  final CacheStore? _cache;

  /// Last raw `/me` payload (stored for multi-account switching).
  Map<String, dynamic>? lastMeJson;

  Future<LoginResult> login(String username, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'username': username, 'password': password},
        options: Options(extra: {'skipAuth': true}),
      );
      final data = response.data;
      // Accept a top-level object or one nested under `data` (Laravel/Sanctum
      // envelopes vary between backends).
      final root = data is Map<String, dynamic>
          ? data
          : const <String, dynamic>{};
      final nested = root['data'];
      final payload = nested is Map<String, dynamic> ? nested : root;

      final accessToken = _firstString([
        payload['access'],
        payload['access_token'],
        payload['accessToken'],
        payload['token'],
        root['access'],
        root['access_token'],
        root['token'],
      ]);
      final refreshToken =
          _firstString([
            payload['refresh'],
            payload['refresh_token'],
            payload['refreshToken'],
            root['refresh'],
            root['refresh_token'],
          ]) ??
          '';

      if (accessToken == null || accessToken.isEmpty) {
        _log.warning(
          'Login succeeded (HTTP ${response.statusCode}) but no token was '
          'found in the response. Keys: ${root.keys.toList()}',
        );
        throw const ApiException(
          code: 'TOKEN_MISSING',
          messageAr: 'تم الدخول لكن لم يستلم التطبيق رمز الجلسة من الخادم',
          messageEn: 'Signed in but the server response had no session token',
          statusCode: 200,
        );
      }
      _log.info('Token received (HTTP ${response.statusCode})');
      return LoginResult(accessToken: accessToken, refreshToken: refreshToken);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : const ApiException.unauthorized();
    }
  }

  Future<UserProfile> me() async {
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.me);
      final data = response.data;
      if (data is! Map) {
        throw const ApiException(
          code: 'BAD_ME',
          messageAr: 'استجابة غير متوقعة من الخادم',
          messageEn: 'Unexpected server response',
        );
      }
      final root = Map<String, dynamic>.from(data);
      final nested = root['data'];
      final payload = nested is Map ? Map<String, dynamic>.from(nested) : root;
      lastMeJson = payload;
      await _cache?.writeAuthJson('/me', payload);
      ConnectivityStatus.instance.markOnline();
      return UserProfile.fromJson(payload);
    } on DioException catch (e) {
      final mapped = e.error;
      final network =
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          (mapped is ApiException && mapped.isNetwork);
      if (network) {
        final cached = await _cache?.readAuthJson('/me');
        if (cached is Map) {
          ConnectivityStatus.instance.markOffline();
          final payload = Map<String, dynamic>.from(cached);
          lastMeJson = payload;
          return UserProfile.fromJson(payload);
        }
      }
      throw mapped is ApiException ? mapped : const ApiException.server();
    }
  }

  /// Full student name for the account switcher. `/me` only carries the
  /// account username (and a null name for seeded student accounts).
  Future<String?> studentProfileName({String? access}) async {
    try {
      final client = access == null
          ? _dio
          : Dio(
              BaseOptions(
                baseUrl: _dio.options.baseUrl,
                connectTimeout: _dio.options.connectTimeout,
                receiveTimeout: _dio.options.receiveTimeout,
                sendTimeout: _dio.options.sendTimeout,
                headers: {
                  ..._dio.options.headers,
                  'Authorization': 'Bearer $access',
                },
              ),
            );
      final response = await client.get<dynamic>(ApiEndpoints.meProfile);
      final data = response.data;
      if (data is! Map) return null;
      final root = Map<String, dynamic>.from(data);
      final nested = root['data'];
      final payload = nested is Map ? Map<String, dynamic>.from(nested) : root;
      final name = payload['name'];
      return name is String && name.trim().isNotEmpty ? name.trim() : null;
    } on DioException {
      return null;
    }
  }

  Future<void> logout({String? refresh}) async {
    try {
      await _dio.post(
        ApiEndpoints.logout,
        data: refresh == null ? null : {'refresh': refresh},
        options: Options(extra: {'skipAuth': true}),
      );
    } on DioException {
      // Best-effort; local tokens are cleared regardless.
    }
  }

  Future<void> updateMe({String? name, String? email, String? phone}) async {
    try {
      await _dio.patch<dynamic>(
        ApiEndpoints.me,
        data: {'name': ?name, 'email': ?email, 'phone': ?phone},
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : const ApiException.server();
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      await _dio.post<dynamic>(
        ApiEndpoints.changePassword,
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'newPassword_confirmation': newPasswordConfirmation,
        },
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : const ApiException.server();
    }
  }

  static String? _firstString(List<Object?> values) {
    for (final value in values) {
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }
}

class LoginResult {
  const LoginResult({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}
