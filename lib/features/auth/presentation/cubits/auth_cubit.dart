import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository, {VoidCallback? onAuthChanged})
    : _onAuthChanged = onAuthChanged,
      super(const AuthRestoring());

  static final _log = AppLogger.forTag('Auth');

  final AuthRepository _repository;

  /// Called whenever the auth state meaningfully changes (login/logout/restore)
  /// so `GoRouter` (via its `refreshListenable`) re-evaluates redirects.
  final VoidCallback? _onAuthChanged;

  void _notify() => _onAuthChanged?.call();

  /// Called at app startup: restores the session, or routes to login.
  Future<void> restoreSession() async {
    emit(const AuthRestoring());
    try {
      final profile = await _repository.restoreSession();
      _log.info(
        'Session restored for user #${profile.id} (${profile.role.value})'
        '${profile.isDemo ? ' [demo]' : ''}',
      );
      emit(AuthAuthenticated(profile));
    } on ApiException {
      _log.debug('No restoreable session');
      emit(const AuthUnauthenticated());
    } catch (e) {
      _log.warning('Session restore failed unexpectedly: $e');
      emit(const AuthUnauthenticated());
    }
    _notify();
  }

  Future<void> login(String username, String password) async {
    _log.debug('Login attempt for "$username"');
    emit(const AuthLoginLoading());
    try {
      final profile = await _repository.login(username, password);
      _log.info(
        'Login success: user #${profile.id} (${profile.role.value})'
        '${profile.isDemo ? ' [demo]' : ''}',
      );
      emit(AuthAuthenticated(profile));
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

  Future<void> logout() async {
    _log.info('Logout');
    await _repository.logout();
    emit(const AuthLoggedOut());
    _notify();
  }
}
