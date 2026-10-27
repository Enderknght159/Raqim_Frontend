import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:go_router/go_router.dart';

import 'package:raqim/core/theme/app_theme.dart';
import 'package:raqim/features/student/data/local/demo_seed.dart';
import 'package:raqim/features/student/data/local/student_database.dart';
import 'package:raqim/features/student/data/student_local_repository.dart';
import 'package:raqim/features/student/presentation/screens/achievement_screen.dart';
import 'package:raqim/features/student/presentation/screens/course_detail_screen.dart';
import 'package:raqim/features/student/presentation/screens/my_courses_screen.dart';
import 'package:raqim/features/student/presentation/screens/my_teams_screen.dart';
import 'package:raqim/features/student/presentation/screens/notifications_screen.dart';
import 'package:raqim/features/student/presentation/screens/points_screen.dart';
import 'package:raqim/features/student/presentation/screens/profile_screen.dart';
import 'package:raqim/features/student/presentation/screens/quran_screen.dart';
import 'package:raqim/features/student/presentation/student_shell.dart';
import 'package:raqim/features/student/presentation/widgets/certificates_sheet.dart';

Future<StudentLocalRepository> _repo() async {
  final db = StudentDatabase.forTesting(NativeDatabase.memory());
  await seedDemoDataIfNeeded(db);
  return StudentLocalRepository(db);
}

Widget _wrap(StudentLocalRepository repo, Widget child) {
  return StudentRepositoryScope(
    repository: repo,
    child: MaterialApp(theme: AppTheme.light(), home: child),
  );
}

void main() {
  // Each test builds its own in-memory StudentDatabase (expected in tests).
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets(
    'MyTeamsScreen renders and opens a team detail without crashing',
    (tester) async {
      final repo = await _repo();
      await tester.pumpWidget(_wrap(repo, const MyTeamsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('حلقة القرآن - أ'), findsOneWidget);

      // Open the first team card.
      await tester.tap(find.text('حلقة القرآن - أ'));
      await tester.pumpAndSettle();
      expect(find.text('معلم الحلقة'), findsOneWidget);
    },
  );

  testWidgets('ProfileScreen renders without crashing', (tester) async {
    final repo = await _repo();
    await tester.pumpWidget(_wrap(repo, const ProfileScreen()));
    await tester.pumpAndSettle();

    expect(find.text('أرقام الهاتف'), findsOneWidget);
    expect(find.text('جامع الفرقان'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsWidgets);

    // "خروج" is at the bottom of a lazy ListView → scroll to it.
    await tester.scrollUntilVisible(find.text('خروج'), 300);
    expect(find.text('خروج'), findsOneWidget);
  });

  testWidgets('Course points card opens the full points breakdown', (
    tester,
  ) async {
    final repo = await _repo();
    final router = GoRouter(
      initialLocation: '/course',
      routes: [
        GoRoute(
          path: '/course',
          builder: (context, state) => const CourseDetailScreen(courseId: 1),
        ),
        GoRoute(
          path: '/my-progress/courses/:id/points',
          builder: (context, state) => StudentPointsScreen(
            courseId: int.parse(state.pathParameters['id']!),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      StudentRepositoryScope(
        repository: repo,
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('متاح للشراء'));
    await tester.pumpAndSettle();

    expect(find.text('محصلة النقاط'), findsOneWidget);
    expect(find.text('المتاح للشراء'), findsOneWidget);
    expect(find.text('المكافآت'), findsOneWidget);
    expect(find.text('الشراء'), findsOneWidget);
    expect(find.text('التحصيل'), findsOneWidget);
    expect(find.text('دخل صرف'), findsNothing);
  });

  testWidgets('Certificates sheet lists every certificate', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showCertificatesSheet(context, [
                  for (var juz = 1; juz <= 4; juz++)
                    (
                      startJuz: juz,
                      endJuz: juz,
                      mark: 90,
                      byHeart: true,
                      date: DateTime(2026, 10, juz),
                    ),
                ]),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('4 شهادة'), findsOneWidget);
    expect(find.text('الجزء 1 – 1'), findsOneWidget);
  });

  testWidgets('QuranScreen renders (guards the fixed-row layout crash)', (
    tester,
  ) async {
    final repo = await _repo();
    await tester.pumpWidget(_wrap(repo, const QuranScreen()));
    await tester.pumpAndSettle();

    expect(find.text('خريطة الحفظ'), findsOneWidget);
    expect(find.text('نسبة إتمام الحفظ للقرآن كاملًا'), findsOneWidget);
  });

  testWidgets('Quran map cell opens its tasmi details (unit/reciter/date)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = await _repo();
    await tester.pumpWidget(_wrap(repo, const QuranScreen()));
    await tester.pumpAndSettle();

    final cell = find.descendant(
      of: find.byType(GridView),
      matching: find.text('592'),
    );
    expect(cell, findsOneWidget);
    await tester.ensureVisible(cell);
    await tester.pumpAndSettle();
    await tester.tap(cell);
    await tester.pumpAndSettle();

    expect(find.textContaining('صفحة 592'), findsOneWidget);
    expect(find.textContaining('الوحدة 1'), findsWidgets);
    expect(find.textContaining('المسمِّع'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('NotificationsScreen groups records and marks them read', (
    tester,
  ) async {
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

  test('Course card rank is the real course rank (never a fixed 1)', () async {
    final db = StudentDatabase.forTesting(NativeDatabase.memory());
    await seedDemoDataIfNeeded(db);
    final repo = StudentLocalRepository(db);

    // Give student 2 a large reward in course 1 so they outrank student 1.
    final firstSession = (await (db.select(
      db.sessions,
    )..where((t) => t.courseId.equals(1))).get()).first;
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: const Value(900001),
            studentId: 2,
            sessionId: firstSession.id,
            type: 'reward',
            pointsValue: 5000,
            date: DateTime.now(),
          ),
        );

    final overviews = await repo.courseOverviews();
    final course1 = overviews.firstWhere((o) => o.course.id == 1);
    expect(course1.rank, isNotNull);
    expect(course1.rank, isNot(1));
    expect(course1.rank, greaterThan(1));
  });

  testWidgets('phone portrait keeps the bottom-sheet presentation', (
    tester,
  ) async {
    final repo = await _repo();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(repo, const MyTeamsScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حلقة القرآن - أ'));
    await tester.pumpAndSettle();

    expect(find.text('معلم الحلقة'), findsOneWidget);
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('responsive smoke: student screens have no overflow', (
    tester,
  ) async {
    final repo = await _repo();
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final screens = <Widget>[
      const MyCoursesScreen(),
      const QuranScreen(),
      const AchievementScreen(),
      const MyTeamsScreen(),
      const ProfileScreen(),
      const NotificationsScreen(),
      const CourseDetailScreen(courseId: 1),
      const StudentPointsScreen(courseId: 1),
    ];
    const sizes = [
      Size(390, 844),
      Size(844, 390),
      Size(768, 1024),
      Size(1280, 800),
    ];

    for (final screen in screens) {
      for (final size in sizes) {
        tester.view.physicalSize = size;
        await tester.pumpWidget(_wrap(repo, screen));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${screen.runtimeType} @ ${size.width}x${size.height}',
        );
      }
    }
  });
}
