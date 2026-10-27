import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:go_router/go_router.dart';

import 'package:raqim/core/theme/app_theme.dart';
import 'package:raqim/core/widgets/search_picker_field.dart';
import 'package:raqim/features/admin/data/admin_local_repository.dart';
import 'package:raqim/features/admin/domain/admin_models.dart';
import 'package:raqim/features/admin/presentation/admin_shell.dart';
import 'package:raqim/features/admin/presentation/screens/admin_account_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_assets_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_audit_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_change_requests_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_content_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_course_detail_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_courses_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_exam_screen.dart';
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
import 'package:raqim/features/admin/presentation/widgets/absence_notice_sheet.dart';
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

  testWidgets('Admin students list search finds a student by name', (
    tester,
  ) async {
    final repos = await _repos();
    await tester.pumpWidget(_wrap(repos, const AdminStudentsScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'عبد الرحمن');
    await tester.pumpAndSettle();
    expect(find.textContaining('عبد الرحمن'), findsWidgets);
  });

  testWidgets('Admin students list search finds a student by barcode', (
    tester,
  ) async {
    final repos = await _repos();
    await tester.pumpWidget(_wrap(repos, const AdminStudentsScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'frq-5');
    await tester.pumpAndSettle();
    expect(find.text('زياد طارق'), findsOneWidget);
  });

  testWidgets('Admin student profile (E7) renders overview', (tester) async {
    final repos = await _repos();
    await tester.pumpWidget(
      _wrap(repos, const AdminStudentProfileScreen(studentId: 1)),
    );
    await tester.pumpAndSettle();
    expect(find.text('نظرة عامة'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('سجلات الدورات'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('سجلات الدورات'), findsOneWidget);
  });

  testWidgets('Admin course detail (E2) renders tabs', (tester) async {
    final repos = await _repos();
    await tester.pumpWidget(
      _wrap(repos, const AdminCourseDetailScreen(courseId: 1)),
    );
    await tester.pumpAndSettle();
    expect(find.text('الجلسات'), findsWidgets);
    expect(find.text('الطلاب الأوائل'), findsOneWidget);
  });

  testWidgets('Admin session (E3) renders attendance + scan button', (
    tester,
  ) async {
    final repos = await _repos();
    await tester.pumpWidget(
      _wrap(repos, const AdminSessionScreen(sessionId: 100)),
    );
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

  testWidgets('E8: add-team picks the teacher from the mosque teachers', (
    tester,
  ) async {
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

    await tester.tap(
      find.descendant(
        of: find.byType(DraggableScrollableSheet),
        matching: find.text('أ. محمود عبد الله'),
      ),
    );
    await tester.pumpAndSettle();
    // The picked teacher is shown on the field (2: field + teacher tile).
    expect(find.text('أ. محمود عبد الله'), findsWidgets);
    expect(find.text('اختر المعلم'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('E5: quran unit picker sheet mirrors the student map', (
    tester,
  ) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/sessions/100'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('تسجيل (حفظ · متون · معاملة)'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
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
      find.descendant(of: find.byType(GridView), matching: find.text('1')),
      findsOneWidget,
    );

    // Single-unit page toggles on tap; summary updates.
    await tester.tap(
      find.descendant(of: find.byType(GridView), matching: find.text('1')),
    );
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
        path: '/admin/courses/:courseId/exams/:examId',
        builder: (context, state) => AdminExamScreen(
          courseId: int.parse(state.pathParameters['courseId']!),
          examId: int.parse(state.pathParameters['examId']!),
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
        builder: (context, state) =>
            AdminTeacherScreen(teacherName: state.pathParameters['name']!),
      ),
      GoRoute(
        path: '/admin/notifications',
        builder: (context, state) => const AdminNotificationsScreen(),
      ),
      GoRoute(
        path: '/admin/content',
        builder: (context, state) => const AdminContentScreen(),
      ),
      GoRoute(
        path: '/admin/system',
        builder: (context, state) => const AdminSystemScreen(),
      ),
      GoRoute(
        path: '/admin/account',
        builder: (context, state) => const AdminAccountScreen(),
      ),
      GoRoute(
        path: '/admin/students',
        builder: (context, state) => const AdminStudentsScreen(),
      ),
      GoRoute(
        path: '/admin/assets',
        builder: (context, state) => const AdminAssetsScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: '/admin/import',
        builder: (context, state) => const AdminImportScreen(),
      ),
      GoRoute(
        path: '/admin/audit',
        builder: (context, state) => const AdminAuditScreen(),
      ),
      GoRoute(
        path: '/admin/change-requests',
        builder: (context, state) => const AdminChangeRequestsScreen(),
      ),
      GoRoute(
        path: '/admin/tools',
        builder: (context, state) => const AdminToolsScreen(),
      ),
      GoRoute(
        path: '/admin/sync-kiosk',
        builder: (context, state) => const AdminSyncKioskScreen(),
      ),
      GoRoute(
        path: '/admin/settings',
        builder: (context, state) => const AdminSettingsScreen(),
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

  testWidgets('E1: creating a course adds it to the list (no setState crash)', (
    tester,
  ) async {
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

  testWidgets('E2: creating today session opens setup then the session page', (
    tester,
  ) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/courses/1'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('إنشاء جلسة اليوم'));
    await tester.pumpAndSettle();

    // Thresholds sheet appears prefilled from the last session (BR-402).
    expect(find.text('إعداد الجلسة الجديدة'), findsOneWidget);
    // New UX: time pickers + steppers (no hyper-sensitive sliders).
    expect(find.byType(Slider), findsNothing);
    expect(find.text('وقت الحضور'), findsOneWidget);
    expect(find.text('نقاط الحضور'), findsOneWidget);
    expect(find.text('الحضور المبكر حتى'), findsOneWidget);
    expect(find.text('التأخير من الساعة'), findsOneWidget);
    await tester.ensureVisible(find.text('حفظ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(find.text('الحضور اللحظي'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Unified attendance: search + tap registers, undo removes', (
    tester,
  ) async {
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
      find.text('تسجيل (حفظ · متون · معاملة)'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('تسجيل (حفظ · متون · معاملة)'));
    await tester.pumpAndSettle();
    expect(find.text('اختر الطالب'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('إضافة تسجيل'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
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

  testWidgets('E2: exam opens the full exam page with stats + submissions', (
    tester,
  ) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/courses/1'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('الامتحانات'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('القرآن الكريم'));
    await tester.pumpAndSettle();

    expect(find.text('إحصاءات الامتحان'), findsOneWidget);
    expect(find.text('عدد التقديمات'), findsOneWidget);
    expect(find.text('إضافة تقديم'), findsOneWidget);
    expect(find.textContaining('التقديمات'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Teacher profile opens from the encoded name without exception '
      '(regression: double percent-decoding)', (tester) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/teams'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('أ. محمود عبد الله').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('أ. محمود عبد الله').first);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('مدرس الحلقة (من الباك)'), findsOneWidget);
    expect(find.text('حلقاته (يمكن إزالته منها)'), findsOneWidget);
  });

  testWidgets('E7: tasmi\' row opens the full memorization log', (
    tester,
  ) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/students/1'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('سجل التسميع'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('سجل التسميع'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('سجل التسميع'));
    await tester.pumpAndSettle();

    // Newest first: page 592 (last memorized in course 1) is at the top.
    expect(find.textContaining('صفحة 592'), findsWidgets);
    expect(find.textContaining('تسجيلة'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('E7: certificates row opens the full certificates sheet', (
    tester,
  ) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/students/1'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('شهادات القرآن'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('شهادات القرآن'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('شهادات القرآن'));
    await tester.pumpAndSettle();

    // Student 1 has a juz-30 certificate in the demo seed.
    expect(find.text('الجزء 30 – 30'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('E7: output show-more opens full exams + matn records', (
    tester,
  ) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/students/1'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('عرض المزيد'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
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

    await tester.scrollUntilVisible(
      find.text('سجلات الدورات'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('دورة الحفظ الصيفية'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('دورة الحفظ الصيفية'));
    await tester.pumpAndSettle();

    // Same content as the student's own course detail (B1x).
    expect(find.textContaining('متاح للشراء'), findsOneWidget);
    expect(find.textContaining('الحضور %'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('الطلاب الأوائل'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('الطلاب الأوائل'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('E7: tapping a team chip opens the team members manager', (
    tester,
  ) async {
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
      find.text('تسجيل (حفظ · متون · معاملة)'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
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

  testWidgets('E2: sessions can be multi-selected, deleted and undone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/courses/1'));
    await tester.pumpAndSettle();

    expect(find.textContaining('جلسة #14'), findsOneWidget);
    await tester.tap(find.text('تحديد'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('جلسة #14'));
    await tester.pumpAndSettle();
    expect(find.text('حذف المحدد (1)'), findsOneWidget);

    await tester.tap(find.text('حذف المحدد (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'حذف'));
    await tester.pumpAndSettle();

    expect(find.textContaining('جلسة #14'), findsNothing);
    expect(find.textContaining('حُذفت 1 جلسة'), findsOneWidget);

    // Undo restores the session (and its records).
    await tester.tap(find.text('تراجع'));
    await tester.pumpAndSettle();
    expect(find.textContaining('جلسة #14'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('E2: adding a certificate uses a juz range from the grid', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/courses/1'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('الشهادات'));
    await tester.pumpAndSettle();

    // Seeded certificates (students 1 and 2) for juz 30.
    expect(find.textContaining('الجزء 30 – 30'), findsWidgets);

    await tester.tap(find.text('إضافة شهادة قرآن'));
    await tester.pumpAndSettle();
    expect(find.text('شهادة قرآن جديدة'), findsOneWidget);

    // Pick the student.
    await tester.tap(find.text('اختر الطالب'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'عبد الرحمن');
    await tester.pumpAndSettle();
    await tester.tap(find.text('عبد الرحمن محمود').last);
    await tester.pumpAndSettle();

    // Pick a contiguous juz range (5 → 7) from the grid.
    final grid = find.byType(GridView);
    await tester.tap(find.descendant(of: grid, matching: find.text('5')));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: grid, matching: find.text('7')));
    await tester.pumpAndSettle();
    expect(find.textContaining('الجزء 5 – 7'), findsOneWidget);

    // Mark + save.
    await tester.enterText(find.byType(TextField).last, '90');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('إضافة الشهادة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إضافة الشهادة'));
    await tester.pumpAndSettle();

    expect(find.textContaining('الجزء 5 – 7'), findsOneWidget);
    final certs = await repos.admin.courseCertificates(1);
    expect(certs.where((c) => c.startJuz == 5 && c.endJuz == 7).length, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('E3: session records preview + show all', (tester) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/sessions/100'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('سجلات الجلسة'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('سجلات الجلسة'), findsOneWidget);

    await tester.ensureVisible(find.text('سجلات الجلسة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('عرض الكل').last);
    await tester.pumpAndSettle();
    expect(find.text('سجلات الجلسة'), findsWidgets);
    expect(find.text('الحفظ'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('E3: quick attendance actions from the day list', (tester) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/sessions/100'));
    await tester.pumpAndSettle();

    // Open the full day list and find a seeded absentee (student 7).
    await tester.tap(find.text('عرض الكل').first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('session-member-7')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const ValueKey('session-member-7')));
    await tester.pumpAndSettle();
    expect(find.text('تسجيل الحضور الآن'), findsOneWidget);

    await tester.tap(find.text('تسجيل الحضور الآن'));
    await tester.pumpAndSettle();

    final attendance = await repos.admin.sessionAttendance(100);
    expect(attendance.map((a) => a.studentId), contains(7));
    expect(tester.takeException(), isNull);
  });

  testWidgets('E3: absence notices reach the student feed', (tester) async {
    final repos = await _repos();
    await tester.pumpWidget(
      _wrap(
        repos,
        Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showAbsenceNoticeSheet(
                  context,
                  sessionId: 100,
                  absentees: const [
                    AdminSessionMember(studentId: 1, name: 'عبد الرحمن محمود'),
                  ],
                  repository: repos.admin,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('إشعارات الغياب'), findsOneWidget);

    await tester.tap(find.textContaining('إرسال الإشعارات'));
    await tester.pumpAndSettle();

    final items = await repos.student.notifications();
    expect(items.where((n) => n.title == 'غياب عن الجلسة').length, 1);
  });

  testWidgets('E2: exam page offers the add-submission form', (tester) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/courses/1'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('الامتحانات'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('القرآن الكريم'));
    await tester.pumpAndSettle();

    expect(find.text('المتوسط'), findsOneWidget);
    expect(find.text('44/50'), findsWidgets);

    await tester.tap(find.text('إضافة تقديم'));
    await tester.pumpAndSettle();
    expect(find.text('حفظ التقديم'), findsOneWidget);
    expect(find.text('اختر الطالب'), findsOneWidget);
    Navigator.of(tester.element(find.text('حفظ التقديم'))).pop();
    await tester.pumpAndSettle();

    // Subject is picked from the subjects list (not free text).
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    final subjectPicker = find.byType(SearchPickerField<String>);
    expect(subjectPicker, findsOneWidget);
    await tester.tap(subjectPicker);
    await tester.pumpAndSettle();
    expect(find.text('بحث في اختر المادة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('E2: course name + criteria can be edited from the course page', (
    tester,
  ) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('دورة الحفظ الصيفية'));
    await tester.pumpAndSettle();
    expect(find.text('تعديل الدورة'), findsNothing);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.text('تعديل الدورة'), findsOneWidget);
    expect(find.text('معايير النقاط'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'دورة الحفظ المعدلة');
    await tester.ensureVisible(find.text('حفظ التعديلات'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ التعديلات'));
    await tester.pumpAndSettle();

    expect(find.text('دورة الحفظ المعدلة'), findsWidgets);
    final courses = await repos.admin.courses();
    expect(courses.any((c) => c.name == 'دورة الحفظ المعدلة'), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('E2: deleting a course removes it from the landing page', (
    tester,
  ) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('دورة الحفظ الصيفية'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('حذف الدورة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف الدورة'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'حذف'));
    await tester.pumpAndSettle();

    // Back on the landing page, refreshed.
    expect(find.text('دورة الحفظ الصيفية'), findsNothing);
    expect(find.text('دورة رمضانية'), findsOneWidget);
    final courses = await repos.admin.courses();
    expect(courses.any((c) => c.name == 'دورة الحفظ الصيفية'), isFalse);
    expect(await repos.admin.courseSessions(1), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('E7: teams card opens the team manager', (tester) async {
    final repos = await _flowRepos();
    await tester.pumpWidget(_flowWrap(repos, '/admin/students/1'));
    await tester.pumpAndSettle();

    expect(find.text('الحلقات'), findsOneWidget);
    await tester.tap(find.text('حلقة القرآن - أ').first);
    await tester.pumpAndSettle();
    expect(find.text('إضافة طلاب'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Student shell: welcome identity on top, page title below', (
    tester,
  ) async {
    final repos = await _flowRepos();
    final router = GoRouter(
      initialLocation: '/my-progress',
      routes: [
        ShellRoute(
          builder: (context, state, child) => StudentShell(child: child),
          routes: [
            GoRoute(
              path: '/my-progress',
              builder: (context, state) => const SizedBox.expand(),
            ),
            GoRoute(
              path: '/my-progress/profile',
              builder: (context, state) => const SizedBox.expand(),
            ),
          ],
        ),
      ],
    );
    await tester.pumpWidget(
      AdminRepositoryScope(
        repository: repos.admin,
        child: StudentRepositoryScope(
          repository: repos.student,
          child: MaterialApp.router(
            theme: AppTheme.light(),
            routerConfig: router,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('عبد الرحمن'), findsWidgets);
    expect(find.text('أهلاً بك'), findsNothing);
    // The current tab title is rendered below the AppBar (plus the nav label).
    expect(find.text('دوراتي'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('responsive smoke: admin screens have no overflow', (
    tester,
  ) async {
    final repos = await _flowRepos();
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const paths = [
      '/admin',
      '/admin/courses/1',
      '/admin/courses/1/exams/500',
      '/admin/sessions/100',
      '/admin/sessions/100/attendance',
      '/admin/students',
      '/admin/students/1',
      '/admin/students/1/courses/1',
      '/admin/teams',
      '/admin/notifications',
      '/admin/content',
      '/admin/system',
      '/admin/account',
      '/admin/assets',
      '/admin/users',
      '/admin/import',
      '/admin/audit',
      '/admin/change-requests',
      '/admin/tools',
      '/admin/sync-kiosk',
      '/admin/settings',
    ];
    const sizes = [
      Size(390, 844),
      Size(844, 390),
      Size(768, 1024),
      Size(1280, 800),
    ];

    for (final path in paths) {
      for (final size in sizes) {
        tester.view.physicalSize = size;
        await tester.pumpWidget(_flowWrap(repos, path));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '$path @ ${size.width}x${size.height}',
        );
      }
    }
  });
}
