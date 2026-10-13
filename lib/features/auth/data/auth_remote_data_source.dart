import 'package:dio/dio.dart';

import '../../../../core/config/api_endpoints.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/api_exception.dart';
import '../domain/models/user_profile.dart';

/// Remote auth data source — talks directly to the API.
class AuthRemoteDataSource {
  AuthRemoteDataSource({required Dio dio}) : _dio = dio;

  static final _log = AppLogger.forTag('AuthAPI');

  final Dio _dio;

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
      final root = data is Map<String, dynamic> ? data : const <String, dynamic>{};
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
      final refreshToken = _firstString([
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
      return LoginResult(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : const ApiException.unauthorized();
    }
  }

  Future<UserProfile> me() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.me);
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        code: 'BAD_ME',
        messageAr: 'استجابة غير متوقعة من الخادم',
        messageEn: 'Unexpected server response',
      );
    }
    final nested = data['data'];
    final payload = nested is Map<String, dynamic> ? nested : data;
    return UserProfile.fromJson(payload);
  }

  Future<void> logout() async {
    try {
      await _dio.post(
        ApiEndpoints.logout,
        options: Options(extra: {'skipAuth': true}),
      );
    } on DioException {
      // Best-effort; local tokens are cleared regardless.
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
