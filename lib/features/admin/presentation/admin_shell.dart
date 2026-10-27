import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_breakpoints.dart';
import '../../../core/widgets/responsive_scope.dart';
import '../../../core/widgets/responsive_shell.dart';
import '../../../shared/notifications_bell.dart';
import '../../../shared/role_switch_button.dart';
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

/// Admin/supervision shell: 4 tabs (الدورات · المحتوى · النظام · حسابي).
///
/// On compact windows it uses the bottom navigation. On landscape/tablet/web
/// it uses a RTL-aware rail that remains visible while a detail page is open.
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
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
        final isDetail = !_tabs.any((t) => path == t.path);
        final index = isDetail ? null : _indexFor(path);

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
              title: Text(_titleFor(path)),
              actions: const [
                RoleSwitchButton(toAdmin: false),
                NotificationsBell(adminMode: true),
              ],
            ),
            banner: const _AdminDemoBanner(),
            body: child,
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
    for (var i = 0; i < _tabs.length; i++) {
      if (path == _tabs[i].path) return i;
    }
    return 0;
  }

  String _titleFor(String path) {
    if (path == '/admin/content') return 'المحتوى';
    if (path == '/admin/system') return 'النظام';
    if (path == '/admin/account') return 'حسابي';
    return 'الدورات';
  }
}

class _AdminDemoBanner extends StatelessWidget {
  const _AdminDemoBanner();

  static const _color = Color(0xFF004C69);

  @override
  Widget build(BuildContext context) {
    final dense = AppBreakpoints.denseFor(MediaQuery.sizeOf(context));
    return Container(
      width: double.infinity,
      color: const Color(0xFFE5F1F6),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: dense ? 3 : 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.admin_panel_settings_outlined,
            size: 16,
            color: _color,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'وضع الإشراف — بيانات المسجد المباشرة',
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
