import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/connectivity_banner.dart';
import '../../../core/widgets/responsive_scope.dart';
import '../../../core/widgets/responsive_shell.dart';
import '../../../shared/mode_switcher.dart';

/// Teacher shell: 3 flat tabs — اليوم · طلابي · حسابي.
class TeacherShell extends StatelessWidget {
  const TeacherShell({super.key, required this.child});

  final Widget child;

  static const List<ResponsiveDestination> _destinations = [
    ResponsiveDestination(
      icon: Icons.today_outlined,
      selectedIcon: Icons.today,
      label: 'اليوم',
      path: '/teacher/today',
    ),
    ResponsiveDestination(
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups,
      label: 'طلابي',
      path: '/teacher/students',
    ),
    ResponsiveDestination(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'حسابي',
      path: '/teacher/account',
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
        var path = '/teacher/today';
        try {
          path = GoRouterState.of(context).uri.path;
        } catch (_) {
          // Standalone widget tests may mount the shell without a router.
        }
        final index = _indexFor(path);
        final isDetail = path.startsWith('/teacher/students/');

        if (isDetail && data.isCompact) {
          return ResponsiveScope(data: data, child: child);
        }

        return ResponsiveScope(
          data: data,
          child: ResponsiveShell(
            destinations: _destinations,
            selectedIndex: index,
            onDestinationSelected: (i) => context.go(_destinations[i].path),
            appBar: isDetail
                ? null
                : AppBar(
                    title: Text(_titleFor(path)),
                    actions: const [ModeSwitcher()],
                  ),
            banner: isDetail ? null : const ConnectivityBanner(),
            body: child,
          ),
        );
      },
    );
  }

  int _indexFor(String path) {
    if (path.startsWith('/teacher/students')) return 1;
    if (path.startsWith('/teacher/account')) return 2;
    return 0;
  }

  String _titleFor(String path) {
    if (path.startsWith('/teacher/students/')) return 'ملف الطالب';
    if (path.startsWith('/teacher/students')) return 'طلابي';
    if (path.startsWith('/teacher/account')) return 'حسابي';
    return 'اليوم';
  }
}
