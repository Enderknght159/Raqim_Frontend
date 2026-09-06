import 'package:dio/dio.dart';

import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../domain/models/user_profile.dart';

/// Remote auth data source — talks directly to the API.
class AuthRemoteDataSource {
  AuthRemoteDataSource({required ApiClient apiClient})
      : _dio = apiClient.dio;

  final Dio _dio;

  Future<LoginResult> login(String username, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'username': username, 'password': password},
        options: Options(extra: {'skipAuth': true}),
      );
      final data = response.data as Map<String, dynamic>;
      return LoginResult(
        accessToken: data['access'] as String,
        refreshToken: data['refresh'] as String,
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : const ApiException.unauthorized();
    }
  }

  Future<UserProfile> me() async {
    final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.me);
    return UserProfile.fromJson(response.data ?? const {});
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
}

class LoginResult {
  const LoginResult({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}