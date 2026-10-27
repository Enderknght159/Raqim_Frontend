import 'package:dio/dio.dart';

import '../config/api_endpoints.dart';
import '../storage/secure_storage.dart';
import 'api_exception.dart';

/// Handles token refresh on `401` responses and retries the original request.
///
/// Concurrent 401s are queued: the first triggers a single refresh, and the
/// others wait for the new access token before retrying.
class TokenRefresher {
  TokenRefresher({required this.storage, required this.dio});

  final SecureStorage storage;
  final Dio dio;

  bool _refreshing = false;
  Future<void>? _inFlight;

  /// Attempts to refresh the access token. Returns `true` on success.
  Future<bool> refresh() {
    final inFlight = _inFlight;
    if (inFlight != null) return inFlight.then((_) => !_refreshing);
    final future = _doRefresh();
    _inFlight = future;
    return future.then((_) => !_refreshing);
  }

  Future<void> _doRefresh() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      final refreshToken = await storage.readRefreshToken();
      if (refreshToken == null) {
        throw const ApiException.unauthorized();
      }
      final response = await dio.post(
        ApiEndpoints.refresh,
        data: {'refresh': refreshToken},
        options: Options(extra: {'skipAuth': true}),
      );
      final accessToken = response.data['access'] as String?;
      if (accessToken == null) throw const ApiException.unauthorized();
      await storage.writeAccessToken(accessToken);
      // If the backend rotates refresh tokens, persist the new one too.
      final newRefresh = response.data['refresh'] as String?;
      if (newRefresh != null) {
        await storage.writeRefreshToken(newRefresh);
      }
    } finally {
      _refreshing = false;
      _inFlight = null;
    }
  }
}
