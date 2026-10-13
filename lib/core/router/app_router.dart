import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/courses/presentation/screens/courses_screen.dart';
import '../../features/student/presentation/screens/achievement_screen.dart';
import '../../features/student/presentation/screens/course_detail_screen.dart';
import '../../features/student/presentation/screens/my_courses_screen.dart';
import '../../features/student/presentation/screens/my_teams_screen.dart';
import '../../features/student/presentation/screens/notifications_screen.dart';
import '../../features/student/presentation/screens/profile_screen.dart';
import '../../features/student/presentation/screens/quran_screen.dart';
import '../../features/student/presentation/student_shell.dart';
import '../../features/students/presentation/screens/students_screen.dart';
import '../../shared/coming_soon_screen.dart';
import '../../shared/role_shell.dart';
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
        builder: (context, state) =>
            const ComingSoonScreen(title: 'غير مسموح'),
      ),
      // Full-screen pushed pages (no tabs).
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
      ShellRoute(
        builder: (context, state, child) {
          if (state.uri.path.startsWith('/my-progress')) {
            return StudentShell(child: child);
          }
          return RoleShell(child: child);
        },
        routes: [
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
          GoRoute(
            path: '/courses',
            name: 'courses',
            redirect: (context, state) =>
                sectionRedirect(context, state, section: 'courses'),
            builder: (context, state) => const CoursesScreen(),
          ),
          GoRoute(
            path: '/students',
            name: 'students',
            redirect: (context, state) =>
                sectionRedirect(context, state, section: 'students'),
            builder: (context, state) => const StudentsScreen(),
          ),
          GoRoute(
            path: '/mosaics',
            name: 'more',
            builder: (context, state) => const ComingSoonScreen(title: 'المزيد'),
          ),
        ],
      ),
    ],
  );
}

/// Central go_router configuration with auth + section guards.
GoRouter createAppRouter({Listenable? refreshListenable}) =>
    AppRouter(refreshListenable: refreshListenable).router;