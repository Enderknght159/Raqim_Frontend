import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:go_router/go_router.dart';

import 'package:raqim/core/theme/app_theme.dart';
import 'package:raqim/features/admin/data/admin_local_repository.dart';
import 'package:raqim/features/admin/presentation/admin_shell.dart';
import 'package:raqim/features/admin/presentation/screens/admin_account_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_assets_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_audit_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_change_requests_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_content_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_course_detail_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_courses_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_import_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_notifications_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_session_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_settings_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_student_course_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_student_profile_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_students_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_sync_kiosk_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_system_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_teacher_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_teams_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_tools_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:raqim/features/attendance/presentation/screens/session_attendance_screen.dart';
import 'package:raqim/features/student/data/local/demo_seed.dart';
import 'package:raqim/features/student/data/local/student_database.dart';
import 'package:raqim/features/student/data/student_local_repository.dart';
import 'package:raqim/features/student/presentation/student_shell.dart';

class _Repos {
  _Repos(this.admin, this.student);
  final AdminLocalRepository admin;
  final StudentLocalRepository student;
}

Future<_Repos> _repos() async {
  final db = StudentDatabase.forTesting(NativeDatabase.memory());
  await seedDemoDataIfNeeded(db);
  return _Repos(AdminLocalRepository(db), StudentLocalRepository(db));
}

Widget _wrap(_Repos repos, Widget child) {
  return AdminRepositoryScope(
    repository: repos.admin,
    child: StudentRepositoryScope(
      repository: repos.student,
      child: MaterialApp(theme: AppTheme.light(), home: child),
    ),
  );
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  testWidgets('Admin courses (E1) renders stats + course', (tester) async {
    final repos = await _repos();
    await tester.pumpWidget(_wrap(repos, const AdminCoursesScreen()));
    await tester.pumpAndSettle();
    expect(find.text('الدورات'), findsWidgets);
    expect(find.text('دورة الحفظ الصيفية'), findsOneWidget);
  });

  testWidgets('Admin content (E6) renders sections', (tester) async {
    final repos = await _repos();
    await tester.pumpWidget(_wrap(repos, const AdminContentScreen()));
    await tester.pumpAndSettle();
    expect(find.text('الطلاب'), findsOneWidget);
    expect(find.text('الحلقات والمعلمون'), findsOneWidget);
  });

  testWidgets('Admin students list search finds a student by name',
      (tester) async {
    final repos = await _repos();
    await tester.pumpWidget(_wrap(repos, const AdminStudentsScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'عبد الرحمن');
    await tester.pumpAndSettle();
    expect(find.textContaining('عبد الرحمن'), findsWidgets);
  });

  testWidgets('Admin students list search finds a student by barcode',
      (tester) async {
    final repos = await _repos();
    await tester.pumpWidget(_wrap(repos, const AdminStudentsScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'frq-5');
    await tester.pumpAndSettle();
    expect(find.text('زياد طارق'), findsOneWidget);
  });

  testWidgets('Admin student profile (E7) renders overview', (tester) async {
    final repos = await _repos();
    await tester
        .pumpWidget(_wrap(repos, const AdminStudentProfileScreen(studentId: 1)));
    await tester.pumpAndSettle();
    expect(find.text('نظرة عامة'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('سجلات الدورات'), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('سجلات الدورات'), findsOneWidget);
  });

  testWidgets('Admin course detail (E2) renders tabs', (tester) async {
    final repos = await _repos();
    await tester
        .pumpWidget(_wrap(repos, const AdminCourseDetailScreen(courseId: 1)));
    await tester.pumpAndSettle();
    expect(find.text('الجلسات'), findsWidgets);
    expect(find.text('الطلاب الأوائل'), findsOneWidget);
  });

  testWidgets('Admin session (E3) renders attendance + scan button',
      (tester) async {
    final repos = await _repos();
    await tester
        .pumpWidget(_wrap(repos, const AdminSessionScreen(sessionId: 100)));
    await tester.pumpAndSettle();
    expect(find.text('الحضور اللحظي'), findsOneWidget);
    expect(find.text('تسجيل الحضور (مسح + يدوي)'), findsOneWidget);
  });

  testWidgets('Admin teams (E8) renders', (tester) async {
    final repos = await _repos();
    await tester.pumpWidget(_wrap(repos, const AdminTeamsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('الحلقات والمعلمون'), findsOneWidget);
  });

  testWidgets('E8: add-team picks the teacher from the mosque teachers',
      (tester) async {
    final repos = await _repos();
    await tester.pumpWidget(_wrap(repos, const AdminTeamsScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_home_outlined));
    await tester.pumpAndSettle();

    expect(find.text('حلقة جديدة'), findsOneWidget);
    // Teacher is a picker, not a free text field.
    expect(find.text('اختر المعلم'), findsOneWidget);
    await tester.tap(find.text('اختر المعلم'));
    await tester.pumpAndSettle();
    expect(find.text('بلا معلم'), findsOneWidget);
    expect(find.text('أ. محمود عبد الله'), findsWidgets);

    await tester.tap(find.descendant(
      of: find.byType(DraggableScrollableSheet),
      matching: find.text('أ. محمود عبد الله'),
    ));
    await tester.pumpAndSettle();
    // The picked teacher is shown on the field (2: field + teacher tile).
    expect(find.text('أ. محمود عبد الله'), findsWidgets);
    expect(find.text('اختر المعلم'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('E5: quran unit picker sheet mirrors the student map',
      (tester) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/sessions/100'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
        find.text('تسجيل (حفظ · متون · معاملة)'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(find.text('تسجيل (حفظ · متون · معاملة)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تسجيل (حفظ · متون · معاملة)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('لم تُحدد صفحات'));
    await tester.pumpAndSettle();

    // Student-map shaped sheet: title, juz nav and 7× square page cells.
    expect(find.text('خريطة الحفظ'), findsOneWidget);
    expect(find.text('الجزء 1'), findsOneWidget);
    expect(
      find.descendant(
          of: find.byType(GridView), matching: find.text('1')),
      findsOneWidget,
    );

    // Single-unit page toggles on tap; summary updates.
    await tester.tap(find.descendant(
        of: find.byType(GridView), matching: find.text('1')));
    await tester.pumpAndSettle();
    expect(find.text('1 وحدة'), findsOneWidget);

    await tester.tap(find.text('تم'));
    await tester.pumpAndSettle();
    expect(find.textContaining('1 وحدة (ص1)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Admin assets (E9) renders lists', (tester) async {
    final repos = await _repos();
    await tester.pumpWidget(_wrap(repos, const AdminAssetsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('المتون'), findsOneWidget);
    expect(find.text('الأربعين النووية'), findsOneWidget);
  });

  testWidgets('Admin system (E10) renders groups', (tester) async {
    final repos = await _repos();
    await tester.pumpWidget(_wrap(repos, const AdminSystemScreen()));
    await tester.pumpAndSettle();
    expect(find.text('الأدوات'), findsOneWidget);
    expect(find.text('الإدارة'), findsOneWidget);
  });

  testWidgets('Admin users (E11) renders', (tester) async {
    final repos = await _repos();
    await tester.pumpWidget(_wrap(repos, const AdminUsersScreen()));
    await tester.pumpAndSettle();
    expect(find.text('مدير المسجد'), findsOneWidget);
  });

  testWidgets('Admin change requests (E14) renders', (tester) async {
    final repos = await _repos();
    await tester.pumpWidget(_wrap(repos, const AdminChangeRequestsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('طلبات التغيير'), findsWidgets);
    expect(find.text('اعتماد'), findsWidgets);
  });

  testWidgets('Admin audit (E13) renders', (tester) async {
    final repos = await _repos();
    await tester.pumpWidget(_wrap(repos, const AdminAuditScreen()));
    await tester.pumpAndSettle();
    expect(find.text('التدقيق'), findsWidgets);
  });

  testWidgets('Admin import (E12) renders', (tester) async {
    final repos = await _repos();
    await tester.pumpWidget(_wrap(repos, const AdminImportScreen()));
    await tester.pumpAndSettle();
    expect(find.text('الاستيراد'), findsWidgets);
  });

  testWidgets('Admin tools (E15) renders', (tester) async {
    final repos = await _repos();
    await tester.pumpWidget(_wrap(repos, const AdminToolsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('الأدوات'), findsWidgets);
  });

  testWidgets('Admin sync/kiosk (E16) renders', (tester) async {
    final repos = await _repos();
    await tester.pumpWidget(_wrap(repos, const AdminSyncKioskScreen()));
    await tester.pumpAndSettle();
    expect(find.text('المزامنة والكشك'), findsWidgets);
  });

  testWidgets('Admin settings (E17) renders identity', (tester) async {
    final repos = await _repos();
    await tester.pumpWidget(_wrap(repos, const AdminSettingsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('هوية المسجد'), findsOneWidget);
  });

  testWidgets('Admin account (E18) renders profile', (tester) async {
    final repos = await _repos();
    await tester.pumpWidget(_wrap(repos, const AdminAccountScreen()));
    await tester.pumpAndSettle();
    expect(find.text('مدير المسجد'), findsWidgets);
    expect(find.text('الأمان والحساب'), findsOneWidget);
  });

  mainFlow();
}

class _FlowRepos {
  _FlowRepos(this.admin, this.student);
  final AdminLocalRepository admin;
  final StudentLocalRepository student;
}

Future<_FlowRepos> _flowRepos() async {
  final db = StudentDatabase.forTesting(NativeDatabase.memory());
  await seedDemoDataIfNeeded(db);
  return _FlowRepos(AdminLocalRepository(db), StudentLocalRepository(db));
}

GoRouter _flowRouter(String initialLocation) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminCoursesScreen(),
      ),
      GoRoute(
        path: '/admin/courses/:id',
        builder: (context, state) => AdminCourseDetailScreen(
          courseId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/admin/sessions/:id',
        builder: (context, state) => AdminSessionScreen(
          sessionId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/admin/sessions/:sessionId/attendance',
        builder: (context, state) => SessionAttendanceScreen(
          sessionId: int.parse(state.pathParameters['sessionId']!),
        ),
      ),
      GoRoute(
        path: '/admin/students/:id',
        builder: (context, state) => AdminStudentProfileScreen(
          studentId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/admin/students/:id/courses/:courseId',
        builder: (context, state) => AdminStudentCourseScreen(
          studentId: int.parse(state.pathParameters['id']!),
          courseId: int.parse(state.pathParameters['courseId']!),
        ),
      ),
      GoRoute(
        path: '/admin/teams',
        builder: (context, state) => const AdminTeamsScreen(),
      ),
      // Same contract as the real router: go_router already decodes the
      // path parameter — no second Uri.decodeComponent (regression).
      GoRoute(
        path: '/admin/teachers/:name',
        builder: (context, state) => AdminTeacherScreen(
          teacherName: state.pathParameters['name']!,
        ),
      ),
      GoRoute(
        path: '/admin/notifications',
        builder: (context, state) => const AdminNotificationsScreen(),
      ),
    ],
  );
}

Widget _flowWrap(_FlowRepos repos, String initialLocation) {
  return AdminRepositoryScope(
    repository: repos.admin,
    child: StudentRepositoryScope(
      repository: repos.student,
      child: MaterialApp.router(
        theme: AppTheme.light(),
        routerConfig: _flowRouter(initialLocation),
      ),
    ),
  );
}

void mainFlow() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('E1: creating a course adds it to the list (no setState crash)',
      (tester) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('دورة'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'دورة اختبار التدفق');
    await tester.tap(find.text('إنشاء'));
    await tester.pumpAndSettle();

    expect(find.text('دورة اختبار التدفق'), findsOneWidget);
    // No setState-returned-Future crash.
    expect(tester.takeException(), isNull);
  });

  testWidgets('E2: creating today session opens setup then the session page',
      (tester) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/courses/1'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('إنشاء جلسة اليوم'));
    await tester.pumpAndSettle();

    // Thresholds sheet appears prefilled from the last session (BR-402).
    expect(find.text('إعداد الجلسة الجديدة'), findsOneWidget);
    await tester.ensureVisible(find.text('حفظ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(find.text('الحضور اللحظي'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Unified attendance: search + tap registers, undo removes',
      (tester) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/sessions/100/attendance'));
    await tester.pumpAndSettle();

    // Student 7 (barcode st-537) is absent from session 100 in the seed.
    await tester.enterText(find.byType(TextField).first, 'st-537');
    await tester.pumpAndSettle();
    await tester.tap(find.text('حمزة فؤاد'));
    await tester.pumpAndSettle();

    expect(find.textContaining('سُجّل حضور'), findsWidgets);
    var attendance = await repos.admin.sessionAttendance(100);
    expect(attendance.map((a) => a.studentId), contains(7));
    expect(tester.takeException(), isNull);

    // Undo window on the snackbar removes the record again.
    await tester.tap(find.text('تراجع'));
    await tester.pumpAndSettle();
    attendance = await repos.admin.sessionAttendance(100);
    expect(attendance.map((a) => a.studentId), isNot(contains(7)));
  });

  testWidgets('E5 record sheet: requires a student first', (tester) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/sessions/100'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
        find.text('تسجيل (حفظ · متون · معاملة)'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('تسجيل (حفظ · متون · معاملة)'));
    await tester.pumpAndSettle();
    expect(find.text('اختر الطالب'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('إضافة تسجيل'), 200,
        scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('إضافة تسجيل'));
    await tester.pump();
    expect(find.text('اختر طالبًا'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Admin notifications renders aggregated groups', (tester) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/notifications'));
    await tester.pumpAndSettle();

    expect(find.textContaining('آخرين'), findsWidgets);
    expect(find.textContaining('تسجيل حضور'), findsWidgets);
  });

  testWidgets('E2: exam detail opens submissions entry', (tester) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/courses/1'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('الامتحانات'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('القرآن الكريم'));
    await tester.pumpAndSettle();

    expect(find.textContaining('التقديمات'), findsOneWidget);
    expect(find.text('إضافة تقديم'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Teacher profile opens from the encoded name without exception '
      '(regression: double percent-decoding)', (tester) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/teams'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('أ. محمود عبد الله').first);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('مدرس الحلقة (من الباك)'), findsOneWidget);
    expect(find.text('حلقاته (يمكن إزالته منها)'), findsOneWidget);
  });

  testWidgets('E7: tasmi\' row opens the full memorization log',
      (tester) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/students/1'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('سجل التسميع'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(find.text('سجل التسميع'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('سجل التسميع'));
    await tester.pumpAndSettle();

    // Newest first: page 592 (last memorized in course 1) is at the top.
    expect(find.textContaining('صفحة 592'), findsWidgets);
    expect(find.textContaining('تسجيلة'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('E7: certificates row opens the full certificates sheet',
      (tester) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/students/1'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('شهادات القرآن'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(find.text('شهادات القرآن'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('شهادات القرآن'));
    await tester.pumpAndSettle();

    // Student 1 has a juz-30 certificate in the demo seed.
    expect(find.text('الجزء 30 – 30'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('E7: output show-more opens full exams + matn records',
      (tester) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/students/1'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('عرض المزيد'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(find.text('عرض المزيد'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('عرض المزيد'));
    await tester.pumpAndSettle();

    expect(find.text('النتاج العلمي الكامل'), findsOneWidget);
    expect(find.text('سجلات المتون'), findsOneWidget);
    // All four submissions of student 1 are listed.
    expect(find.textContaining('الحفظ · اختبار نهائي'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('E7: tapping a course record opens the student achievement '
      'in that course (student parity)', (tester) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/students/1'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('سجلات الدورات'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(find.text('دورة الحفظ الصيفية'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('دورة الحفظ الصيفية'));
    await tester.pumpAndSettle();

    // Same content as the student's own course detail (B1x).
    expect(find.textContaining('متاح للشراء'), findsOneWidget);
    expect(find.textContaining('الحضور %'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('الطلاب الأوائل'), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('الطلاب الأوائل'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('E7: tapping a team chip opens the team members manager',
      (tester) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/students/1'));
    await tester.pumpAndSettle();

    // Student 1 is in the first seeded team; the chip itself opens the
    // same manager used by E8 (الطلاب · إضافة طلاب).
    await tester.tap(find.text('حلقة القرآن - أ').first);
    await tester.pumpAndSettle();

    expect(find.text('إضافة طلاب'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Session page: closing the record sheet keeps the content '
      '(no skeleton flash on reload)', (tester) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/sessions/100'));
    await tester.pumpAndSettle();

    expect(find.text('الحضور اللحظي'), findsOneWidget);

    await tester.scrollUntilVisible(
        find.text('تسجيل (حفظ · متون · معاملة)'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(find.text('تسجيل (حفظ · متون · معاملة)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تسجيل (حفظ · متون · معاملة)'));
    await tester.pumpAndSettle();
    expect(find.text('اختر الطالب'), findsOneWidget);

    // Dismiss the sheet (back) — the page reloads silently.
    Navigator.of(tester.element(find.text('اختر الطالب'))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The section we were on is still rendered (no skeleton flash).
    expect(find.text('تسجيل (حفظ · متون · معاملة)'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(find.text('تسجيل (حفظ · متون · معاملة)'), findsOneWidget);
  });
}
