import 'dart:async';
import 'dart:convert';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/cache_store.dart';
import '../../../../core/storage/secure_storage.dart';
import '../domain/auth_session.dart';
import '../domain/models/stored_account.dart';
import '../domain/models/user_profile.dart';
import 'auth_remote_data_source.dart';

/// Auth repository — the single dependency for the auth feature.
/// Cubits depend on this (not dio directly) for testability.
class AuthRepository {
  AuthRepository({
    required this.remote,
    required this.storage,
    required this.session,
    this.cache,
  });

  static final _log = AppLogger.forTag('AuthRepo');

  final AuthRemoteDataSource remote;
  final SecureStorage storage;
  final ApiSession session;
  final CacheStore? cache;

  Future<bool> isLoggedIn() async {
    final token = await storage.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<UserProfile> login(String username, String password) async {
    final result = await remote.login(username, password);
    await storage.writeAccessToken(result.accessToken);
    await storage.writeRefreshToken(result.refreshToken);
    final profile = await me();
    await _saveAccount(
      StoredAccount(
        userId: profile.id,
        username: username,
        name: await _accountName(profile),
        role: profile.role.value,
        access: result.accessToken,
        refresh: result.refreshToken,
        profileJson: remote.lastMeJson ?? const <String, dynamic>{},
        mosqueName: profile.mosqueName,
        mosqueCode: profile.mosqueCode,
      ),
    );
    return profile;
  }

  Future<String> _accountName(UserProfile profile) async {
    final stored = profile.name.trim();
    final username = profile.username?.trim() ?? '';
    if (stored.isNotEmpty && stored != username) return stored;
    if (profile.studentId != null) {
      final studentName = await remote.studentProfileName();
      if (studentName != null && studentName.trim().isNotEmpty) {
        return studentName.trim();
      }
    }
    return stored.isNotEmpty ? stored : username;
  }

  Future<void> _refreshAccountName(UserProfile profile) async {
    if (profile.studentId == null) return;
    final name = await remote.studentProfileName();
    if (name == null || name.trim().isEmpty) return;
    final saved = await accounts();
    final updated = [
      for (final item in saved)
        if (item.userId == profile.id)
          StoredAccount(
            userId: item.userId,
            username: item.username,
            name: name.trim(),
            role: item.role,
            access: item.access,
            refresh: item.refresh,
            profileJson: item.profileJson,
            mosqueName: item.mosqueName,
            mosqueCode: item.mosqueCode,
          )
        else
          item,
    ];
    await storage.writeAccountsJson(
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }

  /// Loads the real `/me` profile and stores it for the API repositories.
  Future<UserProfile> me() async {
    final profile = await remote.me();
    session.profile = profile;
    cache?.scope = 'user:${profile.id}';
    _log.info(
      'Profile loaded: user #${profile.id} (${profile.role.value})'
      ' mosque=${profile.mosqueName ?? '-'}',
    );
    return profile;
  }

  Future<List<StoredAccount>> accounts() async {
    final raw = await storage.readAccountsJson();
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((e) => StoredAccount.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<int?> activeAccountId() async {
    final raw = await storage.readActiveAccountId();
    return raw == null ? null : int.tryParse(raw);
  }

  /// Saved accounts with full student names resolved for the switcher.
  /// Falls back to the stored value when an account token is no longer valid.
  Future<List<StoredAccount>> accountsWithNames() async {
    final saved = await accounts();
    var changed = false;
    final updated = <StoredAccount>[];
    for (final account in saved) {
      final username = account.username.trim();
      final needsName =
          account.role == 'student' &&
          (account.name.trim().isEmpty || account.name.trim() == username);
      if (!needsName) {
        updated.add(account);
        continue;
      }
      final name = await remote.studentProfileName(access: account.access);
      if (name == null || name.trim().isEmpty) {
        updated.add(account);
        continue;
      }
      changed = true;
      updated.add(
        StoredAccount(
          userId: account.userId,
          username: account.username,
          name: name.trim(),
          role: account.role,
          access: account.access,
          refresh: account.refresh,
          profileJson: account.profileJson,
          mosqueName: account.mosqueName,
          mosqueCode: account.mosqueCode,
        ),
      );
    }
    if (changed) {
      await storage.writeAccountsJson(
        jsonEncode(updated.map((e) => e.toJson()).toList()),
      );
    }
    return updated;
  }

  /// Fast startup path: use the saved profile immediately, then refresh from
  /// the server in the background.
  Future<UserProfile?> cachedProfile() async {
    final saved = await accounts();
    final activeId = await activeAccountId();
    final account =
        saved.where((a) => a.userId == activeId).firstOrNull ??
        saved.firstOrNull;
    if (account == null || account.profileJson.isEmpty) return null;
    final profile = UserProfile.fromJson(account.profileJson);
    if (profile.id == 0) return null;
    session.profile = profile;
    cache?.scope = 'user:${profile.id}';
    return profile;
  }

  Future<void> _saveAccount(StoredAccount account) async {
    final existing = await accounts();
    final updated = [
      for (final item in existing)
        if (item.userId != account.userId) item,
      account,
    ];
    await storage.writeAccountsJson(
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
    await storage.writeActiveAccountId('${account.userId}');
  }

  /// Switches to a saved account without logging out the current one.
  ///
  /// The fresh `/me` profile is fetched with the new token so permission
  /// changes made by an admin apply immediately; the cached profile is only a
  /// fallback when the network is unavailable.
  Future<UserProfile?> switchAccount(int userId) async {
    final saved = await accounts();
    final account = saved.where((a) => a.userId == userId).firstOrNull;
    if (account == null) return null;
    await storage.writeAccessToken(account.access);
    await storage.writeRefreshToken(account.refresh);
    await storage.writeActiveAccountId('${account.userId}');
    try {
      final profile = await me();
      final displayName = await _accountName(profile);
      await _persistAccountProfile(profile, displayName: displayName);
      _log.info('Switched to account #${profile.id} (${profile.username})');
      return profile;
    } catch (e) {
      _log.warning('Account switch refresh failed, using cached profile: $e');
    }
    final profile = UserProfile.fromJson(account.profileJson);
    session.profile = profile;
    cache?.scope = 'user:${profile.id}';
    unawaited(_refreshAccountName(profile));
    _log.info(
      'Switched to cached account #${profile.id} (${profile.username})',
    );
    return profile;
  }

  /// Persists the latest `/me` payload for the active saved account so a
  /// later account switch does not resurrect stale permissions.
  Future<void> _persistAccountProfile(
    UserProfile profile, {
    String? displayName,
  }) async {
    final saved = await accounts();
    if (saved.isEmpty) return;
    final updated = [
      for (final item in saved)
        if (item.userId == profile.id)
          StoredAccount(
            userId: profile.id,
            username: item.username,
            name: displayName ?? item.name,
            role: profile.role.value,
            access: item.access,
            refresh: item.refresh,
            profileJson: remote.lastMeJson ?? item.profileJson,
            mosqueName: profile.mosqueName,
            mosqueCode: profile.mosqueCode,
          )
        else
          item,
    ];
    await storage.writeAccountsJson(
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }

  Future<UserProfile?> logout() async {
    final saved = await accounts();
    final activeId = await activeAccountId();
    final active =
        saved.where((a) => a.userId == activeId).firstOrNull ??
        saved.firstOrNull;
    final refresh = active?.refresh ?? await storage.readRefreshToken();
    await remote.logout(refresh: refresh);

    final remaining = [
      for (final item in saved)
        if (item.userId != active?.userId) item,
    ];
    await storage.writeAccountsJson(
      jsonEncode(remaining.map((e) => e.toJson()).toList()),
    );
    await storage.clearActiveTokens();
    session.profile = null;

    if (remaining.isEmpty) {
      await storage.writeActiveAccountId(null);
      return null;
    }

    final next = remaining.first;
    await storage.writeAccessToken(next.access);
    await storage.writeRefreshToken(next.refresh);
    await storage.writeActiveAccountId('${next.userId}');
    final profile = UserProfile.fromJson(next.profileJson);
    session.profile = profile;
    cache?.scope = 'user:${profile.id}';
    return profile;
  }

  Future<UserProfile> updateMe({
    String? name,
    String? email,
    String? phone,
  }) async {
    await remote.updateMe(name: name, email: email, phone: phone);
    final profile = await me();
    final displayName = await _accountName(profile);
    final saved = await accounts();
    final updated = [
      for (final item in saved)
        if (item.userId == profile.id)
          StoredAccount(
            userId: profile.id,
            username: item.username,
            name: displayName,
            role: profile.role.value,
            access: item.access,
            refresh: item.refresh,
            profileJson: remote.lastMeJson ?? item.profileJson,
            mosqueName: profile.mosqueName,
            mosqueCode: profile.mosqueCode,
          )
        else
          item,
    ];
    await storage.writeAccountsJson(
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
    return profile;
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
    try {
      final profile = await me();
      await _refreshAccountName(profile);
      await _persistAccountProfile(profile);
      return profile;
    } on ApiException catch (e) {
      if (!e.isNetwork) rethrow;
      final saved = await accounts();
      final activeId = await activeAccountId();
      final account =
          saved.where((a) => a.userId == activeId).firstOrNull ??
          saved.firstOrNull;
      if (account == null) rethrow;
      final profile = UserProfile.fromJson(account.profileJson);
      session.profile = profile;
      cache?.scope = 'user:${profile.id}';
      _log.info('Restored account #${profile.id} from local session (offline)');
      return profile;
    }
  }
}
