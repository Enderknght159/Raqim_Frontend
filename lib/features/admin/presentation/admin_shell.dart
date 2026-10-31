import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/connectivity_banner.dart';
import '../../../core/widgets/responsive_scope.dart';
import '../../../core/widgets/responsive_shell.dart';
import '../../../shared/notifications_bell.dart';
import '../../../shared/mode_switcher.dart';
import '../../auth/domain/models/user_profile.dart';
import '../../auth/presentation/cubits/auth_cubit.dart';
import '../../auth/presentation/cubits/auth_state.dart';
import '../data/admin_repository.dart';

/// Provides the [AdminRepository] to all admin screens.
class AdminRepositoryScope extends InheritedWidget {
  const AdminRepositoryScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final AdminRepository repository;

  static AdminRepository of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AdminRepositoryScope>();
    assert(scope != null, 'AdminRepositoryScope is missing in the tree');
    return scope!.repository;
  }

  @override
  bool updateShouldNotify(AdminRepositoryScope old) =>
      old.repository != repository;
}

typedef _AdminTab = ({
  IconData icon,
  IconData selectedIcon,
  String label,
  String path,
});

/// Admin/supervision shell: tabs filtered by the account's server capabilities
/// (a scoped supervisor sees only the sections they may access).
///
/// On compact windows it uses the bottom navigation. On landscape/tablet/web
/// it uses a RTL-aware rail that remains visible while a detail page is open.
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  static const List<_AdminTab> _tabs = [
    (
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view,
      label: 'الدورات',
      path: '/admin/courses',
    ),
    (
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder,
      label: 'المحتوى',
      path: '/admin/content',
    ),
    (
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'النظام',
      path: '/admin/system',
    ),
    (
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'حسابي',
      path: '/admin/account',
    ),
  ];

  List<_AdminTab> _visibleTabs(UserProfile? profile) {
    if (profile == null) return _tabs;
    return _tabs.where((tab) {
      switch (tab.path) {
        case '/admin/courses':
          return profile.isAdmin || profile.canView('courses');
        case '/admin/content':
          return profile.isAdmin ||
              profile.canView('students') ||
              profile.canView('teams') ||
              profile.canView('matn') ||
              profile.canView('courses');
        case '/admin/system':
          return profile.isAdmin ||
              profile.specialAbilities.any(
                (ability) => const {
                  'auditView',
                  'userManagement',
                  'permissionManagement',
                  'messagesExport',
                  'barcodeExport',
                  'phoneSearch',
                  'dataChangeApproval',
                }.contains(ability),
              );
        default:
          return true; // account
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    AuthState? auth;
    try {
      auth = context.watch<AuthCubit>().state;
    } catch (_) {
      // Standalone widget tests may mount the shell without an AuthCubit.
      auth = null;
    }
    final profile = auth is AuthAuthenticated ? auth.profile : null;
    final tabs = _visibleTabs(profile);
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
        final isDetail = !tabs.any((t) => path == t.path);
        final index = isDetail ? null : _indexFor(path, tabs);

        if (isDetail && data.isCompact) {
          return ResponsiveScope(data: data, child: child);
        }

        if (isDetail) {
          return ResponsiveScope(
            data: data,
            child: ResponsiveShell(
              destinations: _destinations(tabs),
              selectedIndex: index,
              onDestinationSelected: (i) => context.go(tabs[i].path),
              body: child,
            ),
          );
        }

        return ResponsiveScope(
          data: data,
          child: ResponsiveShell(
            destinations: _destinations(tabs),
            selectedIndex: index,
            onDestinationSelected: (i) => context.go(tabs[i].path),
            appBar: AppBar(
              title: Text(_titleFor(path, tabs)),
              actions: const [
                ModeSwitcher(),
                NotificationsBell(adminMode: true),
              ],
            ),
            banner: const ConnectivityBanner(),
            body: child,
          ),
        );
      },
    );
  }

  static List<ResponsiveDestination> _destinations(List<_AdminTab> tabs) => [
    for (final t in tabs)
      ResponsiveDestination(
        icon: t.icon,
        selectedIcon: t.selectedIcon,
        label: t.label,
        path: t.path,
      ),
  ];

  int _indexFor(String path, List<_AdminTab> tabs) {
    for (var i = 0; i < tabs.length; i++) {
      if (path == tabs[i].path) return i;
    }
    return 0;
  }

  String _titleFor(String path, List<_AdminTab> tabs) {
    for (final tab in tabs) {
      if (tab.path == path) return tab.label;
    }
    return tabs.isEmpty ? '' : tabs.first.label;
  }
}
