import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:raqim/core/storage/secure_storage.dart';
import 'package:raqim/core/theme/app_theme.dart';
import 'package:raqim/features/auth/data/auth_remote_data_source.dart';
import 'package:raqim/features/auth/data/auth_repository.dart';
import 'package:raqim/features/auth/domain/auth_session.dart';
import 'package:raqim/features/auth/domain/models/app_role.dart';
import 'package:raqim/features/auth/domain/models/user_profile.dart';
import 'package:raqim/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:raqim/features/admin/presentation/screens/admin_account_screen.dart';

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository(this.profile)
    : super(
        remote: AuthRemoteDataSource(dio: Dio()),
        storage: SecureStorage(),
        session: ApiSession(),
      );

  final UserProfile profile;

  @override
  Future<UserProfile?> cachedProfile() async => profile;

  @override
  Future<UserProfile> restoreSession() async => profile;

  @override
  Future<bool> isLoggedIn() async => true;
}

Future<void> _pumpAccount(WidgetTester tester, UserProfile profile) async {
  final cubit = AuthCubit(_FakeAuthRepository(profile));
  addTearDown(cubit.close);
  await cubit.restoreSession();
  await tester.pumpWidget(
    BlocProvider<AuthCubit>.value(
      value: cubit,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const AdminAccountScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('general supervisor can edit account identity and password', (
    tester,
  ) async {
    await _pumpAccount(
      tester,
      const UserProfile(
        id: 1,
        name: 'مدير المسجد',
        username: 'frq-1',
        phone: '0500000001',
        mosqueName: 'جامع الفرقان',
        mosqueCode: 'frq',
        role: AppRole.admin,
      ),
    );

    expect(find.text('بيانات الحساب'), findsOneWidget);
    expect(find.text('تغيير كلمة المرور'), findsOneWidget);

    final username = tester.widget<TextField>(
      find.byKey(const ValueKey('account-username')),
    );
    expect(username.readOnly, isTrue);
    expect(username.controller?.text, 'frq-1');
  });

  testWidgets('non-admin has no identity card and no password tile', (
    tester,
  ) async {
    await _pumpAccount(
      tester,
      const UserProfile(
        id: 2,
        name: 'مشرف الحلقات',
        username: 'frq-2',
        mosqueName: 'جامع الفرقان',
        mosqueCode: 'frq',
        role: AppRole.supervisor,
      ),
    );

    expect(find.text('بيانات الحساب'), findsNothing);
    expect(find.text('تغيير كلمة المرور'), findsNothing);
    expect(find.text('تبديل الحساب'), findsOneWidget);
    expect(find.text('خروج'), findsOneWidget);
  });
}
