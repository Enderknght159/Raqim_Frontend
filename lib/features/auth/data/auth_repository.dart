import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage.dart';
import '../domain/models/user_profile.dart';
import 'auth_remote_data_source.dart';

/// Auth repository — the single dependency for the auth feature.
/// Cubits depend on this (not dio directly) for testability.
class AuthRepository {
  AuthRepository({required this.remote, required this.storage});

  static final _log = AppLogger.forTag('AuthRepo');

  final AuthRemoteDataSource remote;
  final SecureStorage storage;

  /// Last username used, for the demo fallback profile.
  String? _lastUsername;

  Future<bool> isLoggedIn() async {
    final token = await storage.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<UserProfile> login(String username, String password) async {
    _lastUsername = username;
    final result = await remote.login(username, password);
    await storage.writeAccessToken(result.accessToken);
    await storage.writeRefreshToken(result.refreshToken);
    return me();
  }

  /// Loads the profile used after a successful login.
  ///
  /// **Trial build:** the backend is only used to *validate credentials*; the
  /// interface shown is the local student demo (pure local data). The user's
  /// real `/me` (role/sections/permissions) drives the real shells
  /// (supervisor/admin/teacher) once those are built — until then every
  /// logged-in account lands on the student demo.
  Future<UserProfile> me() async {
    _log.info('Trial build: using local student demo profile');
    return UserProfile.demo(username: _lastUsername);
  }

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
