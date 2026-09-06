import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthUnauthenticated());

  final AuthRepository _repository;

  /// Called at app startup: restores the session if a token exists.
  Future<void> restoreSession() async {
    emit(const AuthRestoring());
    try {
      final profile = await _repository.restoreSession();
      emit(AuthAuthenticated(profile));
    } on ApiException {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> login(String username, String password) async {
    emit(const AuthLoginLoading());
    try {
      final profile = await _repository.login(username, password);
      emit(AuthAuthenticated(profile));
    } on ApiException catch (e) {
      emit(AuthLoginFailure(e));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthLoggedOut());
  }
}