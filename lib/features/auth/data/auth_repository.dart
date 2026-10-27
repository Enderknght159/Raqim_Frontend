import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage.dart';
import '../domain/auth_session.dart';
import '../domain/models/user_profile.dart';
import 'auth_remote_data_source.dart';

/// Auth repository — the single dependency for the auth feature.
/// Cubits depend on this (not dio directly) for testability.
class AuthRepository {
  AuthRepository({
    required this.remote,
    required this.storage,
    required this.session,
  });

  static final _log = AppLogger.forTag('AuthRepo');

  final AuthRemoteDataSource remote;
  final SecureStorage storage;
  final ApiSession session;

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

  /// Loads the real `/me` profile and stores it for the API repositories.
  Future<UserProfile> me() async {
    final profile = await remote.me();
    session.profile = profile;
    _log.info(
      'Profile loaded: user #${profile.id} (${profile.role.value})'
      ' mosque=${profile.mosqueName ?? '-'}',
    );
    return profile;
  }

  Future<void> logout() async {
    final refresh = await storage.readRefreshToken();
    await remote.logout(refresh: refresh);
    await storage.clear();
    session.profile = null;
  }

  Future<UserProfile> updateMe({
    String? name,
    String? email,
    String? phone,
  }) async {
    await remote.updateMe(name: name, email: email, phone: phone);
    return me();
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) {
    return remote.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );
  }

  /// Restores the profile from cached tokens (app restart), or throws
  /// [ApiException.unauthorized] if there is no session.
  Future<UserProfile> restoreSession() async {
    if (!await isLoggedIn()) throw const ApiException.unauthorized();
    return me();
  }
}
