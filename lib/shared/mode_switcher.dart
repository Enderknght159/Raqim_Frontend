import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/router/route_guards.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/domain/models/user_profile.dart';
import '../features/auth/presentation/cubits/auth_cubit.dart';
import '../features/auth/presentation/cubits/auth_state.dart';

enum _Mode { student, supervisor, teacher }

class _ModeDef {
  const _ModeDef({
    required this.mode,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.color,
  });

  final _Mode mode;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Color color;
}

/// One-tap mode switcher: a compact colored pill with 2–3 icons + the label of
/// the selected mode. No dropdown, no extra tap.
class ModeSwitcher extends StatelessWidget {
  const ModeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    AuthState? auth;
    try {
      auth = context.watch<AuthCubit>().state;
    } catch (_) {
      return const SizedBox.shrink();
    }
    final profile = auth is AuthAuthenticated ? auth.profile : null;
    if (profile == null) return const SizedBox.shrink();

    final tokens = Theme.of(context).extension<AppTokens>()!;
    final modes = <_ModeDef>[
      if (profile.hasStudentSection || profile.isStudent || profile.isDemo)
        _ModeDef(
          mode: _Mode.student,
          icon: Icons.auto_stories_outlined,
          selectedIcon: Icons.auto_stories,
          label: 'المتابعة',
          color: tokens.brand,
        ),
      if (profile.hasAdminSection)
        _ModeDef(
          mode: _Mode.supervisor,
          icon: Icons.admin_panel_settings_outlined,
          selectedIcon: Icons.admin_panel_settings,
          label: 'الإشراف',
          color: tokens.info,
        ),
      if (profile.hasTeacherSection)
        _ModeDef(
          mode: _Mode.teacher,
          icon: Icons.school_outlined,
          selectedIcon: Icons.school,
          label: 'التدريس',
          color: tokens.accentMatn,
        ),
    ];
    if (modes.length <= 1) return const SizedBox.shrink();

    final path = GoRouterState.of(context).uri.path;
    final selected = path.startsWith('/admin')
        ? _Mode.supervisor
        : path.startsWith('/teacher')
        ? _Mode.teacher
        : _Mode.student;
    final current =
        modes.where((m) => m.mode == selected).firstOrNull ?? modes.first;

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 2, end: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: tokens.surfaceSubtle,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: tokens.borderStructural),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final mode in modes)
                  _ModeButton(
                    def: mode,
                    selected: mode.mode == selected,
                    onTap: mode.mode == selected
                        ? null
                        : () => _go(context, profile, mode.mode),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            current.label,
            style: TextStyle(
              color: current.color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  void _go(BuildContext context, UserProfile profile, _Mode mode) {
    switch (mode) {
      case _Mode.student:
        context.go('/my-progress');
      case _Mode.supervisor:
        context.go(adminLandingPath(profile));
      case _Mode.teacher:
        context.go('/teacher-soon');
    }
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.def,
    required this.selected,
    required this.onTap,
  });

  final _ModeDef def;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Tooltip(
      message: def.label,
      child: Material(
        color: selected ? def.color : Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 30,
            height: 30,
            child: Icon(
              selected ? def.selectedIcon : def.icon,
              size: 17,
              color: selected ? Colors.white : tokens.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
