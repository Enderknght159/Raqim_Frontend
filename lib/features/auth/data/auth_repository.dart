import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage.dart';
import '../domain/models/user_profile.dart';
import 'auth_remote_data_source.dart';

/// Auth repository — the single dependency for the auth feature.
/// Cubits depend on this (not dio directly) for testability.
class AuthRepository {
  AuthRepository({required this.remote, required this.storage});

  final AuthRemoteDataSource remote;
  final SecureStorage storage;

  Future<bool> isLoggedIn() async {
    final token = await storage.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<UserProfile> login(String username, String password) async {
    final result = await remote.login(username, password);
    await storage.writeAccessToken(result.accessToken);
    await storage.writeRefreshToken(result.refreshToken);
    return me();
  }

  Future<UserProfile> me() => remote.me();

  Future<void> logout() async {
    await remote.logout();
    await storage.clear();
  }

  /// Restores the profile from cached tokens (app restart), or throws
  /// [ApiException.unauthorized] if there is no session.
  Future<UserProfile> restoreSession() async {
    if (!await isLoggedIn()) throw const ApiException.unauthorized();
    return me();
  }
}