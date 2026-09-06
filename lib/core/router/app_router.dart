import 'package:go_router/go_router.dart';

import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/courses/presentation/screens/courses_screen.dart';
import '../../features/students/presentation/screens/students_screen.dart';
import '../../shared/coming_soon_screen.dart';
import '../../shared/role_shell.dart';
import '../../shared/splash_screen.dart';
import 'route_guards.dart';

/// Central go_router configuration with auth + section guards.
class AppRouter {
  AppRouter();

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: authRedirect,
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/not-allowed',
        name: 'notAllowed',
        builder: (context, state) =>
            const ComingSoonScreen(title: 'غير مسموح'),
      ),
      ShellRoute(
        builder: (context, state, child) => RoleShell(child: child),
        routes: [
          GoRoute(
            path: '/courses',
            name: 'courses',
            redirect: (context, state) =>
                sectionRedirect(context, state, section: 'courses'),
            builder: (context, state) => const CoursesScreen(),
          ),
          GoRoute(
            path: '/courses/:id',
            name: 'courseDetail',
            redirect: (context, state) =>
                sectionRedirect(context, state, section: 'courses'),
            builder: (context, state) => const ComingSoonScreen(title: 'الدورة'),
          ),
          GoRoute(
            path: '/courses/:id/sessions/:sessionId',
            name: 'sessionDetail',
            redirect: (context, state) =>
                sectionRedirect(context, state, section: 'courses'),
            builder: (context, state) =>
                const ComingSoonScreen(title: 'الجلسة'),
          ),
          GoRoute(
            path: '/students',
            name: 'students',
            redirect: (context, state) =>
                sectionRedirect(context, state, section: 'students'),
            builder: (context, state) => const StudentsScreen(),
          ),
          GoRoute(
            path: '/students/:id',
            name: 'studentDetail',
            redirect: (context, state) =>
                sectionRedirect(context, state, section: 'students'),
            builder: (context, state) =>
                const ComingSoonScreen(title: 'الطالب'),
          ),
          GoRoute(
            path: '/scan/:sessionId',
            name: 'scan',
            redirect: (context, state) =>
                sectionRedirect(context, state, section: 'courses'),
            builder: (context, state) => const AttendanceScreen(),
          ),
          GoRoute(
            path: '/my-progress',
            name: 'myProgress',
            redirect: (context, state) =>
                sectionRedirect(context, state, section: 'my_progress'),
            builder: (context, state) =>
                const ComingSoonScreen(title: 'تقدّمي'),
          ),
          GoRoute(
            path: '/more',
            name: 'more',
            builder: (context, state) => const ComingSoonScreen(title: 'المزيد'),
          ),
          GoRoute(
            path: '/imports',
            name: 'imports',
            redirect: (context, state) =>
                sectionRedirect(context, state, section: 'imports'),
            builder: (context, state) => const ComingSoonScreen(title: 'الاستيراد'),
          ),
          GoRoute(
            path: '/messages',
            name: 'messages',
            redirect: (context, state) =>
                sectionRedirect(context, state, section: 'messages'),
            builder: (context, state) => const ComingSoonScreen(title: 'الرسائل'),
          ),
          GoRoute(
            path: '/sync',
            name: 'sync',
            redirect: (context, state) =>
                sectionRedirect(context, state, section: 'sync'),
            builder: (context, state) => const ComingSoonScreen(title: 'المزامنة'),
          ),
          GoRoute(
            path: '/admin/users',
            name: 'adminUsers',
            redirect: (context, state) =>
                sectionRedirect(context, state, section: 'admin'),
            builder: (context, state) => const ComingSoonScreen(title: 'المستخدمون'),
          ),
          GoRoute(
            path: '/admin/audit',
            name: 'adminAudit',
            redirect: (context, state) =>
                sectionRedirect(context, state, section: 'admin'),
            builder: (context, state) => const ComingSoonScreen(title: 'سجل التدقيق'),
          ),
          GoRoute(
            path: '/admin/permissions/:userId',
            name: 'adminPermissions',
            redirect: (context, state) =>
                sectionRedirect(context, state, section: 'admin'),
            builder: (context, state) =>
                const ComingSoonScreen(title: 'الصلاحيات'),
          ),
        ],
      ),
    ],
  );
}

/// Central go_router configuration with auth + section guards.
GoRouter createAppRouter() => AppRouter().router;