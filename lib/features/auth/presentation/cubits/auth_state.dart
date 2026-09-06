import 'package:equatable/equatable.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/models/user_profile.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// No session yet — app is on the login screen.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Session being restored on app start.
class AuthRestoring extends AuthState {
  const AuthRestoring();
}

/// Authenticated with a loaded profile.
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.profile);

  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}

/// Login attempt in progress.
class AuthLoginLoading extends AuthState {
  const AuthLoginLoading();
}

/// Login failed.
class AuthLoginFailure extends AuthState {
  const AuthLoginFailure(this.error);

  final ApiException error;

  @override
  List<Object?> get props => [error];
}

/// Session restore failed (no/invalid token) — fall back to login.
class AuthSessionExpired extends AuthState {
  const AuthSessionExpired();
}

/// Logged out cleanly.
class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}