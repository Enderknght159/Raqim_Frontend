import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../core/widgets/info_banner.dart';
import '../features/auth/domain/models/app_role.dart';
import '../features/auth/domain/models/user_profile.dart';
import '../features/auth/presentation/cubits/auth_cubit.dart';
import '../features/auth/presentation/cubits/auth_state.dart';

/// Role-aware shell: builds the bottom nav (mobile) / sidebar (web) from the
/// sections returned by `/me/`.
class RoleShell extends StatelessWidget {
  const RoleShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    final profile = auth is AuthAuthenticated ? auth.profile : null;
    final sections = _buildSections(profile);
    final showDefaultPasswordBanner =
        profile != null && profile.isAdmin && profile.usesDefaultPassword;

    return Scaffold(
      body: Column(
        children: [
          if (showDefaultPasswordBanner)
            InfoBanner(
              key: ValueKey('default-pw-${profile.id}'),
              icon: Icons.key,
              color: Theme.of(context).extension<AppTokens>()!.reward,
              message:
                  'أنت تستخدم كلمة المرور الافتراضية (admin/admin1234) — '
                  'يُنصح بتغييرها من الإعدادات.',
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex(context, sections),
        onDestinationSelected: (index) {
          final section = sections[index];
          context.go(section.path);
        },
        destinations: [
          for (final section in sections)
            NavigationDestination(
              icon: Icon(section.icon),
              label: section.label,
            ),
        ],
      ),
    );
  }

  int _selectedIndex(BuildContext context, List<RoleSection> sections) {
    final path = GoRouterState.of(context).uri.path;
    for (var i = 0; i < sections.length; i++) {
      if (path.startsWith(sections[i].path)) return i;
    }
    return 0;
  }

  List<RoleSection> _buildSections(UserProfile? profile) {
    if (profile == null) return const [];
    final sections = <RoleSection>[];
    for (final section in profile.sections) {
      sections.add(RoleSection.fromAppSection(section));
    }
    if (sections.isEmpty) {
      // Fallback based on role.
      switch (profile.role) {
        case AppRole.admin:
        case AppRole.supervisor:
          return const [
            RoleSection.courses(),
            RoleSection.students(),
            RoleSection.more(),
          ];
        case AppRole.teacher:
          return const [RoleSection.courses(), RoleSection.students()];
        case AppRole.student:
        case AppRole.parent:
          return const [RoleSection.myProgress()];
      }
    }
    return sections;
  }
}

class RoleSection {
  const RoleSection(this.label, this.icon, this.path);

  const RoleSection.courses()
    : label = 'الدورات',
      icon = Icons.menu_book_outlined,
      path = '/courses';
  const RoleSection.students()
    : label = 'الطلاب',
      icon = Icons.groups_outlined,
      path = '/students';
  const RoleSection.more()
    : label = 'المزيد',
      icon = Icons.more_horiz,
      path = '/more';
  const RoleSection.myProgress()
    : label = 'تقدّمي',
      icon = Icons.insights_outlined,
      path = '/my-progress';

  final String label;
  final IconData icon;
  final String path;

  static RoleSection fromAppSection(AppSection section) {
    switch (section) {
      case AppSection.myProgress:
        return const RoleSection.myProgress();
      case AppSection.courses:
        return const RoleSection.courses();
      case AppSection.students:
        return const RoleSection.students();
      case AppSection.more:
      case AppSection.admin:
        return const RoleSection.more();
      default:
        return const RoleSection.more();
    }
  }
}
