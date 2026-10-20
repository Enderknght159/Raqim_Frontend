import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/admin_shell.dart';
import '../../features/admin/presentation/screens/admin_account_screen.dart';
import '../../features/admin/presentation/screens/admin_assets_screen.dart';
import '../../features/admin/presentation/screens/admin_audit_screen.dart';
import '../../features/admin/presentation/screens/admin_change_requests_screen.dart';
import '../../features/admin/presentation/screens/admin_content_screen.dart';
import '../../features/admin/presentation/screens/admin_course_detail_screen.dart';
import '../../features/admin/presentation/screens/admin_courses_screen.dart';
import '../../features/admin/presentation/screens/admin_import_screen.dart';
import '../../features/admin/presentation/screens/admin_notifications_screen.dart';
import '../../features/admin/presentation/screens/admin_session_screen.dart';
import '../../features/admin/presentation/screens/admin_settings_screen.dart';
import '../../features/admin/presentation/screens/admin_student_course_screen.dart';
import '../../features/admin/presentation/screens/admin_student_profile_screen.dart';
import '../../features/admin/presentation/screens/admin_students_screen.dart';
import '../../features/admin/presentation/screens/admin_sync_kiosk_screen.dart';
import '../../features/admin/presentation/screens/admin_system_screen.dart';
import '../../features/admin/presentation/screens/admin_teacher_screen.dart';
import '../../features/admin/presentation/screens/admin_teams_screen.dart';
import '../../features/admin/presentation/screens/admin_tools_screen.dart';
import '../../features/admin/presentation/screens/admin_users_screen.dart';
import '../../features/admin/presentation/screens/student_barcode_scan_screen.dart';
import '../../features/attendance/presentation/screens/session_attendance_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/student/presentation/screens/achievement_screen.dart';
import '../../features/student/presentation/screens/course_detail_screen.dart';
import '../../features/student/presentation/screens/my_courses_screen.dart';
import '../../features/student/presentation/screens/my_teams_screen.dart';
import '../../features/student/presentation/screens/notifications_screen.dart';
import '../../features/student/presentation/screens/profile_screen.dart';
import '../../features/student/presentation/screens/quran_screen.dart';
import '../../features/student/presentation/student_shell.dart';
import '../../shared/coming_soon_screen.dart';
import '../../shared/splash_screen.dart';
import 'route_guards.dart';

/// Central go_router configuration with auth + section guards.
class AppRouter {
  AppRouter({Listenable? refreshListenable})
      : _refreshListenable = refreshListenable;

  final Listenable? _refreshListenable;

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: authRedirect,
    refreshListenable: _refreshListenable,
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginScreen(
          username: state.uri.queryParameters['username'] ?? '',
        ),
      ),
      GoRoute(
        path: '/not-allowed',
        name: 'notAllowed',
        builder: (context, state) => const ComingSoonScreen(title: 'غير مسموح'),
      ),
      // ── Student full-screen pushed pages ──
      GoRoute(
        path: '/my-progress/courses/:id',
        name: 'studentCourseDetail',
        builder: (context, state) => CourseDetailScreen(
          courseId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/my-progress/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/admin/notifications',
        name: 'adminNotifications',
        builder: (context, state) => const AdminNotificationsScreen(),
      ),
      // ── Admin full-screen pushed pages ──
      GoRoute(
        path: '/admin/courses/:id',
        name: 'adminCourseDetail',
        builder: (context, state) => AdminCourseDetailScreen(
          courseId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/admin/sessions/:id',
        name: 'adminSession',
        builder: (context, state) => AdminSessionScreen(
          sessionId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/admin/sessions/:sessionId/attendance',
        name: 'adminSessionAttendance',
        builder: (context, state) => SessionAttendanceScreen(
          sessionId: int.parse(state.pathParameters['sessionId']!),
        ),
      ),
      GoRoute(
        path: '/admin/scan-student',
        name: 'adminScanStudent',
        builder: (context, state) => const StudentBarcodeScanScreen(),
      ),
      GoRoute(
        path: '/admin/students',
        name: 'adminStudents',
        builder: (context, state) => const AdminStudentsScreen(),
      ),
      GoRoute(
        path: '/admin/students/:id',
        name: 'adminStudentProfile',
        builder: (context, state) => AdminStudentProfileScreen(
          studentId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/admin/teams',
        name: 'adminTeams',
        builder: (context, state) => const AdminTeamsScreen(),
      ),
      GoRoute(
        path: '/admin/teachers/:name',
        name: 'adminTeacher',
        // go_router already percent-decodes path parameters — do not decode
        // again (double-decoding non-ASCII names throws).
        builder: (context, state) => AdminTeacherScreen(
          teacherName: state.pathParameters['name']!,
        ),
      ),
      GoRoute(
        path: '/admin/students/:id/courses/:courseId',
        name: 'adminStudentCourse',
        builder: (context, state) => AdminStudentCourseScreen(
          studentId: int.parse(state.pathParameters['id']!),
          courseId: int.parse(state.pathParameters['courseId']!),
        ),
      ),
      GoRoute(
        path: '/admin/assets',
        name: 'adminAssets',
        builder: (context, state) => const AdminAssetsScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'adminUsers',
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: '/admin/import',
        name: 'adminImport',
        builder: (context, state) => const AdminImportScreen(),
      ),
      GoRoute(
        path: '/admin/audit',
        name: 'adminAudit',
        builder: (context, state) => const AdminAuditScreen(),
      ),
      GoRoute(
        path: '/admin/change-requests',
        name: 'adminChangeRequests',
        builder: (context, state) => const AdminChangeRequestsScreen(),
      ),
      GoRoute(
        path: '/admin/tools',
        name: 'adminTools',
        builder: (context, state) => const AdminToolsScreen(),
      ),
      GoRoute(
        path: '/admin/sync-kiosk',
        name: 'adminSyncKiosk',
        builder: (context, state) => const AdminSyncKioskScreen(),
      ),
      GoRoute(
        path: '/admin/settings',
        name: 'adminSettings',
        builder: (context, state) => const AdminSettingsScreen(),
      ),
      // ── Role shells (tab groups) ──
      ShellRoute(
        builder: (context, state, child) {
          if (state.uri.path.startsWith('/my-progress')) {
            return StudentShell(child: child);
          }
          if (state.uri.path.startsWith('/admin')) {
            return AdminShell(child: child);
          }
          return child;
        },
        routes: [
          // Student tabs.
          GoRoute(
            path: '/my-progress',
            name: 'myProgress',
            builder: (context, state) => const MyCoursesScreen(),
          ),
          GoRoute(
            path: '/my-progress/quran',
            name: 'quran',
            builder: (context, state) => const QuranScreen(),
          ),
          GoRoute(
            path: '/my-progress/achievement',
            name: 'achievement',
            builder: (context, state) => const AchievementScreen(),
          ),
          GoRoute(
            path: '/my-progress/teams',
            name: 'myTeams',
            builder: (context, state) => const MyTeamsScreen(),
          ),
          GoRoute(
            path: '/my-progress/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          // Admin tabs.
          GoRoute(
            path: '/admin/courses',
            name: 'adminCourses',
            builder: (context, state) => const AdminCoursesScreen(),
          ),
          GoRoute(
            path: '/admin/content',
            name: 'adminContent',
            builder: (context, state) => const AdminContentScreen(),
          ),
          GoRoute(
            path: '/admin/system',
            name: 'adminSystem',
            builder: (context, state) => const AdminSystemScreen(),
          ),
          GoRoute(
            path: '/admin/account',
            name: 'adminAccount',
            builder: (context, state) => const AdminAccountScreen(),
          ),
        ],
      ),
    ],
  );
}

/// Central go_router configuration with auth + section guards.
GoRouter createAppRouter({Listenable? refreshListenable}) =>
    AppRouter(refreshListenable: refreshListenable).router;
