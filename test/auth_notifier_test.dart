import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:raqim/core/storage/secure_storage.dart';
import 'package:raqim/features/auth/data/auth_remote_data_source.dart';
import 'package:raqim/features/auth/data/auth_repository.dart';
import 'package:raqim/features/auth/domain/models/user_profile.dart';
import 'package:raqim/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:raqim/features/auth/presentation/cubits/auth_state.dart';

class _SuccessRepo extends AuthRepository {
  _SuccessRepo()
      : super(
          remote: AuthRemoteDataSource(dio: Dio()),
          storage: SecureStorage(),
        );

  @override
  Future<bool> isLoggedIn() async => false;

  @override
  Future<UserProfile> me() async => UserProfile.demo(username: 'admin');

  @override
  Future<UserProfile> login(String username, String password) async =>
      UserProfile.demo(username: username);
}

void main() {
  test('login success notifies onAuthChanged (drives GoRouter refresh)', () async {
    final notifier = _Counter();
    final cubit = AuthCubit(_SuccessRepo(), onAuthChanged: notifier.bump);

    expect(notifier.count, 0);
    await cubit.login('admin', 'password');

    expect(cubit.state, isA<AuthAuthenticated>());
    expect(notifier.count, 1, reason: 'router must re-evaluate redirects');
  });

  test('failed login also notifies so the UI settles', () async {
    final notifier = _Counter();
    final repo = _FailingRepo();
    final cubit = AuthCubit(repo, onAuthChanged: notifier.bump);

    await cubit.login('x', 'y');

    expect(cubit.state, isA<AuthLoginFailure>());
    expect(notifier.count, 1);
  });
}

class _Counter {
  int count = 0;
  void bump() => count++;
}

class _FailingRepo extends _SuccessRepo {
  @override
  Future<UserProfile> login(String username, String password) async =>
      throw Exception('boom');
}