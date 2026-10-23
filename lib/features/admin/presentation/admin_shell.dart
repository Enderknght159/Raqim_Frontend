import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/notifications_bell.dart';
import '../../../shared/role_switch_button.dart';
import '../data/admin_local_repository.dart';

/// Provides the [AdminLocalRepository] to all admin screens.
class AdminRepositoryScope extends InheritedWidget {
  const AdminRepositoryScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final AdminLocalRepository repository;

  static AdminLocalRepository of(BuildContext context) {
    final scope =
        context.getInheritedWidgetOfExactType<AdminRepositoryScope>();
    assert(scope != null, 'AdminRepositoryScope is missing in the tree');
    return scope!.repository;
  }

  @override
  bool updateShouldNotify(AdminRepositoryScope old) =>
      old.repository != repository;
}

/// Admin/supervision shell: 4 tabs (الدورات · المحتوى · النظام · حسابي).
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    (icon: Icons.grid_view_outlined, label: 'الدورات', path: '/admin/courses'),
    (icon: Icons.folder_outlined, label: 'المحتوى', path: '/admin/content'),
    (icon: Icons.settings_outlined, label: 'النظام', path: '/admin/system'),
    (icon: Icons.person_outline, label: 'حسابي', path: '/admin/account'),
  ];

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final index = _indexFor(path);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleFor(path)),
        actions: const [
          RoleSwitchButton(toAdmin: false),
          NotificationsBell(adminMode: true),
        ],
      ),
      body: Column(
        children: [
          const _AdminDemoBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(icon: Icon(t.icon), label: t.label),
        ],
      ),
    );
  }

  int _indexFor(String path) {
    if (path.startsWith('/admin/content')) return 1;
    if (path.startsWith('/admin/system')) return 2;
    if (path.startsWith('/admin/account')) return 3;
    return 0;
  }

  String _titleFor(String path) {
    if (path.startsWith('/admin/content')) return 'المحتوى';
    if (path.startsWith('/admin/system')) return 'النظام';
    if (path.startsWith('/admin/account')) return 'حسابي';
    return 'الدورات';
  }
}

class _AdminDemoBanner extends StatelessWidget {
  const _AdminDemoBanner();

  static const _color = Color(0xFF004C69);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFE5F1F6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.admin_panel_settings_outlined,
              size: 16, color: _color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'وضع الإشراف (تجريبي) — بيانات محلية',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: _color),
            ),
          ),
        ],
      ),
    );
  }
}
