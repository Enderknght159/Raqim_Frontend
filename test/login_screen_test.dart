import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:raqim/core/network/api_exception.dart';
import 'package:raqim/core/theme/app_theme.dart';
import 'package:raqim/core/storage/secure_storage.dart';
import 'package:raqim/features/auth/data/auth_remote_data_source.dart';
import 'package:raqim/features/auth/data/auth_repository.dart';
import 'package:raqim/features/auth/domain/auth_session.dart';
import 'package:raqim/features/auth/domain/models/user_profile.dart';
import 'package:raqim/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:raqim/features/auth/presentation/screens/login_screen.dart';

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository()
    : super(
        remote: AuthRemoteDataSource(dio: Dio()),
        storage: SecureStorage(),
        session: ApiSession(),
      );

  int loginCalls = 0;
  String? lastUsername;

  @override
  Future<bool> isLoggedIn() async => false;

  @override
  Future<UserProfile> me() async => const UserProfile(id: 0, name: '');

  @override
  Future<UserProfile> login(String username, String password) async {
    loginCalls++;
    lastUsername = username;
    throw const ApiException.unauthorized();
  }
}

Future<void> _pumpLogin(WidgetTester tester, _FakeAuthRepository repo) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: BlocProvider<AuthCubit>(
        create: (_) => AuthCubit(repo),
        child: const LoginScreen(username: 'frq-532'),
      ),
    ),
  );
}

void main() {
  testWidgets('A3 login: requires password and shows the E1 error', (
    tester,
  ) async {
    final repo = _FakeAuthRepository();
    await _pumpLogin(tester, repo);

    // Username (read-only) is shown.
    expect(find.text('frq-532'), findsOneWidget);

    // Empty submit → field error, no repository call.
    await tester.tap(find.text('دخول'));
    await tester.pump();
    expect(find.text('أدخل كلمة المرور'), findsOneWidget);
    expect(repo.loginCalls, 0);

    // Fill password, submit → repo called with the passed username;
    // fake throws → error banner appears with its Arabic message.
    await tester.enterText(find.byType(TextField).first, 'secret');
    await tester.pump();
    await tester.tap(find.text('دخول'));
    await tester.pumpAndSettle();

    expect(repo.loginCalls, 1);
    expect(repo.lastUsername, 'frq-532');
    expect(find.text('انتهت صلاحية الجلسة'), findsOneWidget);
  });
}
