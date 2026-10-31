import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/screen_cache.dart';
import '../../data/auth_repository.dart';
import '../../domain/models/stored_account.dart';
import '../../domain/models/user_profile.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._repository, {
    VoidCallback? onAuthChanged,
    Future<void> Function(UserProfile profile)? onAuthenticated,
  }) : _onAuthChanged = onAuthChanged,
       _onAuthenticated = onAuthenticated,
       super(const AuthRestoring());

  static final _log = AppLogger.forTag('Auth');

  final AuthRepository _repository;

  /// Called whenever the auth state meaningfully changes (login/logout/restore)
  /// so `GoRouter` (via its `refreshListenable`) re-evaluates redirects.
  final VoidCallback? _onAuthChanged;

  /// Warm the read-only cache after a successful login/restore.
  final Future<void> Function(UserProfile profile)? _onAuthenticated;

  void _notify() => _onAuthChanged?.call();

  void _warmCache(UserProfile profile) {
    final callback = _onAuthenticated;
    if (callback == null) return;
    unawaited(callback(profile).catchError((_) {}));
  }

  /// Called at app startup: restores the session, or routes to login.
  Future<void> restoreSession() async {
    emit(const AuthRestoring());

    // Fast path: the saved account profile lets the UI render immediately,
    // even before (or without) a network round-trip.
    UserProfile? cached;
    try {
      cached = await _repository.cachedProfile();
    } catch (_) {
      cached = null;
    }
    if (cached != null) {
      _log.info('Cached session restored for user #${cached.id}');
      emit(AuthAuthenticated(cached));
      _notify();
      _warmCache(cached);
    }

    try {
      final profile = await _repository.restoreSession();
      _log.info(
        'Session restored for user #${profile.id} (${profile.role.value})'
        '${profile.isDemo ? ' [demo]' : ''}',
      );
      emit(AuthAuthenticated(profile));
      _warmCache(profile);
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        _log.debug('Session expired');
        emit(const AuthUnauthenticated());
      } else if (state is! AuthAuthenticated) {
        _log.debug('No restoreable session');
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      _log.warning('Session restore failed unexpectedly: $e');
      if (state is! AuthAuthenticated) {
        emit(const AuthUnauthenticated());
      }
    }
    _notify();
  }

  Future<void> login(String username, String password) async {
    ScreenCache.instance.clear();
    _log.debug('Login attempt for "$username"');
    emit(const AuthLoginLoading());
    try {
      final profile = await _repository.login(username, password);
      _log.info(
        'Login success: user #${profile.id} (${profile.role.value})'
        '${profile.isDemo ? ' [demo]' : ''}',
      );
      emit(AuthAuthenticated(profile));
      _warmCache(profile);
    } on ApiException catch (e) {
      _log.warning('Login failed: ${e.code} ${e.message(arabic: false)}');
      emit(AuthLoginFailure(e));
    } catch (e) {
      _log.error('Login failed unexpectedly', error: e);
      emit(
        AuthLoginFailure(
          ApiException(
            code: 'UNEXPECTED',
            messageAr: 'حدث خطأ غير متوقع، حاول مرة أخرى',
            messageEn: 'An unexpected error occurred, please try again',
          ),
        ),
      );
    }
    _notify();
  }

  /// Re-reads `/me` so permission changes applied by an admin become visible
  /// without signing out (account switch, app resume, or self-edit).
  Future<UserProfile?> refreshProfile() async {
    if (state is! AuthAuthenticated) return null;
    try {
      final profile = await _repository.me();
      emit(AuthAuthenticated(profile));
      _notify();
      _warmCache(profile);
      return profile;
    } on ApiException catch (e) {
      _log.debug('Profile refresh failed: ${e.code}');
      return null;
    } catch (e) {
      _log.warning('Profile refresh failed unexpectedly: $e');
      return null;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    final profile = await _repository.updateMe(
      name: name,
      email: email,
      phone: phone,
    );
    emit(AuthAuthenticated(profile));
    _notify();
    _warmCache(profile);
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) {
    return _repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );
  }

  Future<List<StoredAccount>> accounts() => _repository.accounts();

  Future<List<StoredAccount>> accountsWithNames() =>
      _repository.accountsWithNames();

  Future<UserProfile?> switchAccount(int userId) async {
    ScreenCache.instance.clear();
    final profile = await _repository.switchAccount(userId);
    if (profile != null) {
      emit(AuthAuthenticated(profile));
      _notify();
      _warmCache(profile);
    }
    return profile;
  }

  Future<void> addAccount(String username, String password) async {
    ScreenCache.instance.clear();
    final profile = await _repository.login(username, password);
    emit(AuthAuthenticated(profile));
    _notify();
    _warmCache(profile);
  }

  Future<UserProfile?> logout() async {
    ScreenCache.instance.clear();
    _log.info('Logout');
    final next = await _repository.logout();
    if (next != null) {
      emit(AuthAuthenticated(next));
      _notify();
      _warmCache(next);
    } else {
      emit(const AuthLoggedOut());
      _notify();
    }
    return next;
  }
}
