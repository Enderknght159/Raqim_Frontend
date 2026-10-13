import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'package:raqim/core/theme/app_theme.dart';
import 'package:raqim/features/student/data/local/demo_seed.dart';
import 'package:raqim/features/student/data/local/student_database.dart';
import 'package:raqim/features/student/data/student_local_repository.dart';
import 'package:raqim/features/student/presentation/screens/my_teams_screen.dart';
import 'package:raqim/features/student/presentation/screens/notifications_screen.dart';
import 'package:raqim/features/student/presentation/screens/profile_screen.dart';
import 'package:raqim/features/student/presentation/screens/quran_screen.dart';
import 'package:raqim/features/student/presentation/student_shell.dart';

Future<StudentLocalRepository> _repo() async {
  final db = StudentDatabase.forTesting(NativeDatabase.memory());
  await seedDemoDataIfNeeded(db);
  return StudentLocalRepository(db);
}

Widget _wrap(StudentLocalRepository repo, Widget child) {
  return StudentRepositoryScope(
    repository: repo,
    child: MaterialApp(
      theme: AppTheme.light(),
      home: child,
    ),
  );
}

void main() {
  // Each test builds its own in-memory StudentDatabase (expected in tests).
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('MyTeamsScreen renders and opens a team detail without crashing',
      (tester) async {
    final repo = await _repo();
    await tester.pumpWidget(_wrap(repo, const MyTeamsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('حلقة القرآن - أ'), findsOneWidget);

    // Open the first team card.
    await tester.tap(find.text('حلقة القرآن - أ'));
    await tester.pumpAndSettle();
    expect(find.text('معلم الحلقة'), findsOneWidget);
  });

  testWidgets('ProfileScreen renders without crashing', (tester) async {
    final repo = await _repo();
    await tester.pumpWidget(_wrap(repo, const ProfileScreen()));
    await tester.pumpAndSettle();

    expect(find.text('أرقام الهاتف'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsWidgets);

    // "خروج" is at the bottom of a lazy ListView → scroll to it.
    await tester.scrollUntilVisible(find.text('خروج'), 300);
    expect(find.text('خروج'), findsOneWidget);
  });

  testWidgets('QuranScreen renders (guards the fixed-row layout crash)',
      (tester) async {
    final repo = await _repo();
    await tester.pumpWidget(_wrap(repo, const QuranScreen()));
    await tester.pumpAndSettle();

    expect(find.text('خريطة الحفظ'), findsOneWidget);
    expect(find.text('نسبة إتمام الحفظ للقرآن كاملًا'), findsOneWidget);
  });

  testWidgets('NotificationsScreen groups records and marks them read',
      (tester) async {
    final repo = await _repo();
    expect(await repo.unreadNotifications(), greaterThan(0));

    await tester.pumpWidget(_wrap(repo, const NotificationsScreen()));
    await tester.pumpAndSettle();

    // At least the recorded activity titles appear (newest items are at top).
    expect(find.text('تسجيل حضور'), findsWidgets);
    expect(find.text('تسجيل حفظ'), findsWidgets);

    // Opening the screen marks everything as read.
    expect(await repo.unreadNotifications(), 0);
  });
}