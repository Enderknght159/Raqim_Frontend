import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/notifications_bell.dart';
import '../../../shared/role_switch_button.dart';
import '../data/student_local_repository.dart';

/// Provides the local [StudentLocalRepository] to all student screens.
class StudentRepositoryScope extends InheritedWidget {
  const StudentRepositoryScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final StudentLocalRepository repository;

  static StudentLocalRepository of(BuildContext context) {
    final scope =
        context.getInheritedWidgetOfExactType<StudentRepositoryScope>();
    assert(scope != null, 'StudentRepositoryScope is missing in the tree');
    return scope!.repository;
  }

  @override
  bool updateShouldNotify(StudentRepositoryScope old) =>
      old.repository != repository;
}

/// Student shell: 5 tabs (دوراتي · القرآن · التحصيل · حلقاتي · الملف) +
/// a "وضع تجريبي" banner while backed by local data.
class StudentShell extends StatelessWidget {
  const StudentShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    (icon: Icons.auto_stories_outlined, label: 'دوراتي', path: '/my-progress'),
    (icon: Icons.menu_book_outlined, label: 'القرآن', path: '/my-progress/quran'),
    (icon: Icons.emoji_events_outlined, label: 'التحصيل', path: '/my-progress/achievement'),
    (icon: Icons.groups_outlined, label: 'حلقاتي', path: '/my-progress/teams'),
    (icon: Icons.person_outline, label: 'الملف', path: '/my-progress/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final index = _indexFor(path);
    final isDetail = path.startsWith('/my-progress/courses/');

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleFor(path)),
        actions: const [RoleSwitchButton(toAdmin: true), NotificationsBell()],
      ),
      body: Column(
        children: [
          const _DemoBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: isDetail
          ? null
          : NavigationBar(
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
    return Container(
      width: double.infinity,
      color: const Color(0xFFE6F6F1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.science_outlined, size: 16, color: _color),
          const SizedBox(width: 6),
          Text(
            'وضع تجريبي — بيانات محلية على جهازك',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: _color),
          ),
        ],
      ),
    );
  }
}