import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_scope.dart';
import '../../../core/widgets/responsive_shell.dart';
import '../../../shared/notifications_bell.dart';
import '../../../shared/role_switch_button.dart';
import '../data/student_repository.dart';
import 'widgets/student_welcome_title.dart';

/// Provides the [StudentRepository] to all student screens.
class StudentRepositoryScope extends InheritedWidget {
  const StudentRepositoryScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final StudentRepository repository;

  static StudentRepository of(BuildContext context) {
    final scope = context
        .getInheritedWidgetOfExactType<StudentRepositoryScope>();
    assert(scope != null, 'StudentRepositoryScope is missing in the tree');
    return scope!.repository;
  }

  @override
  bool updateShouldNotify(StudentRepositoryScope old) =>
      old.repository != repository;
}

/// Student shell: 5 tabs (دوراتي · القرآن · التحصيل · حلقاتي · الملف) +
/// a "وضع تجريبي" banner while backed by local data.
///
/// Responsive contract:
/// - compact: bottom navigation (current behaviour);
/// - rail/expanded: a RTL-aware [NavigationRail] that stays visible on
///   detail pages too, with the content centred at 1200.
class StudentShell extends StatelessWidget {
  const StudentShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    (
      icon: Icons.auto_stories_outlined,
      selectedIcon: Icons.auto_stories,
      label: 'دوراتي',
      path: '/my-progress',
    ),
    (
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
      label: 'القرآن',
      path: '/my-progress/quran',
    ),
    (
      icon: Icons.emoji_events_outlined,
      selectedIcon: Icons.emoji_events,
      label: 'التحصيل',
      path: '/my-progress/achievement',
    ),
    (
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups,
      label: 'حلقاتي',
      path: '/my-progress/teams',
    ),
    (
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'الملف',
      path: '/my-progress/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width,
          constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : MediaQuery.sizeOf(context).height,
        );
        final data = ResponsiveData.fromSize(size);

        final path = GoRouterState.of(context).uri.path;
        final index = _indexFor(path);
        final isDetail =
            path.startsWith('/my-progress/courses/') ||
            path.startsWith('/my-progress/notifications');

        // Detail pages own their AppBar/Scaffold. Keep them untouched on
        // compact (full-screen push) and only add the rail on wide windows.
        if (isDetail && data.isCompact) {
          return ResponsiveScope(data: data, child: child);
        }

        if (isDetail) {
          return ResponsiveScope(
            data: data,
            child: ResponsiveShell(
              destinations: _destinations,
              selectedIndex: index,
              onDestinationSelected: (i) => context.go(_tabs[i].path),
              body: child,
            ),
          );
        }

        return ResponsiveScope(
          data: data,
          child: ResponsiveShell(
            destinations: _destinations,
            selectedIndex: index,
            onDestinationSelected: (i) => context.go(_tabs[i].path),
            appBar: AppBar(
              title: const StudentWelcomeTitle(),
              actions: const [
                RoleSwitchButton(toAdmin: true),
                NotificationsBell(),
              ],
            ),
            banner: const _DemoBanner(),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      _titleFor(path),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Theme.of(
                              context,
                            ).extension<AppTokens>()!.info,
                          ),
                    ),
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        );
      },
    );
  }

  static List<ResponsiveDestination> get _destinations => [
    for (final t in _tabs)
      ResponsiveDestination(
        icon: t.icon,
        selectedIcon: t.selectedIcon,
        label: t.label,
        path: t.path,
      ),
  ];

  int _indexFor(String path) {
    if (path.startsWith('/my-progress/quran')) return 1;
    if (path.startsWith('/my-progress/achievement')) return 2;
    if (path.startsWith('/my-progress/teams')) return 3;
    if (path.startsWith('/my-progress/profile')) return 4;
    return 0;
  }

  String _titleFor(String path) {
    if (path.startsWith('/my-progress/quran')) return 'القرآن';
    if (path.startsWith('/my-progress/achievement')) return 'التحصيل';
    if (path.startsWith('/my-progress/teams')) return 'حلقاتي';
    if (path.startsWith('/my-progress/profile')) return 'الملف';
    return 'دوراتي';
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  static const _color = Color(0xFF007A55);

  @override
  Widget build(BuildContext context) {
    final dense = AppBreakpoints.denseFor(MediaQuery.sizeOf(context));
    return Container(
      width: double.infinity,
      color: const Color(0xFFE6F6F1),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: dense ? 3 : 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.science_outlined, size: 16, color: _color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'متصل بالخادم — بيانات المسجد المباشرة',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: _color),
            ),
          ),
        ],
      ),
    );
  }
}
