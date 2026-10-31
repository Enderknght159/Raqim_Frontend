import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/models/app_role.dart';
import '../../features/auth/domain/models/user_profile.dart';
import '../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../features/auth/presentation/cubits/auth_state.dart';

/// Top-level auth redirect: keeps the splash while the session is restoring;
/// unauthenticated users are sent to `/welcome`; authenticated users who land
/// on the splash (`/`) go to their first available section.
FutureOr<String?> authRedirect(BuildContext context, GoRouterState state) {
  final auth = context.read<AuthCubit>().state;
  final path = state.uri.path;
  final isPublic = path == '/welcome' || path == '/login';

  if (auth is AuthRestoring) {
    // Session restore in progress — leave the splash visible.
    return null;
  }

  if (auth is AuthAuthenticated) {
    if (path == '/') return firstSectionPath(auth.profile);
    return isPublic ? '/' : null;
  }
  if (auth is AuthUnauthenticated || auth is AuthLoggedOut) {
    return isPublic ? null : '/welcome';
  }
  // Unknown state — keep the splash.
  return null;
}

/// Path of the user's first section (their landing screen).
String adminLandingPath(UserProfile profile) {
  if (profile.isAdmin || profile.canView('courses')) {
    return '/admin/courses';
  }
  if (profile.canView('students') ||
      profile.canView('teams') ||
      profile.canView('matn')) {
    return '/admin/content';
  }
  return '/admin/account';
}

String firstSectionPath(UserProfile profile) {
  // A full admin lands on the admin surface; a dual-role student/supervisor
  // lands on their student surface first and can switch via the role button.
  if (profile.isAdmin) return '/admin/courses';
  if (profile.hasStudentSection) return '/my-progress';
  if (profile.isSupervisor) return adminLandingPath(profile);
  if (profile.isTeacher) return '/teacher-soon';
  if (profile.isStudent || profile.isDemo) return '/my-progress';
  return '/my-progress';
}

/// Role-section redirect used per-route-group. Returns a redirect location or
/// null to allow the route.
FutureOr<String?> sectionRedirect(
  BuildContext context,
  GoRouterState state, {
  String? section,
}) {
  final auth = context.read<AuthCubit>().state;
  if (auth is! AuthAuthenticated) return null;
  final profile = auth.profile;

  if (profile.isAdmin) return null;

  final sectionName = section ?? sectionOf(state.uri.path);
  final ownsSection = profile.sections.any((s) => s.value == sectionName);
  final defaultAccess = _defaultRoleAccess(profile.role, state.uri.path);
  return (ownsSection || defaultAccess) ? null : '/not-allowed';
}

/// Route-level guard for screens that the plan reserves to the mosque admin
/// (mosque identity/settings, full export). UI-only; the server enforces.
FutureOr<String?> adminOnlyRedirect(BuildContext context, GoRouterState state) {
  final auth = context.read<AuthCubit>().state;
  if (auth is AuthAuthenticated && !auth.profile.isAdmin) {
    return '/not-allowed';
  }
  return null;
}

/// Path → section name (e.g. `/courses/3` → `courses`).
String sectionOf(String path) {
  final parts = path.split('/').where((p) => p.isNotEmpty).toList();
  return parts.isEmpty ? 'more' : parts.first;
}

bool _defaultRoleAccess(AppRole role, String path) {
  switch (role) {
    case AppRole.teacher:
      return path.startsWith('/courses') || path.startsWith('/students');
    case AppRole.student:
    case AppRole.parent:
      return path.startsWith('/my-progress') || path == '/';
    default:
      return false;
  }
}

/// Pure permission helpers on a profile (UI-only; server enforces).
bool canView(UserProfile profile, String module) =>
    profile.isAdmin || profile.canView(module);

bool canEdit(UserProfile profile, String module) =>
    profile.isAdmin || profile.canEdit(module);

bool canDelete(UserProfile profile, String module) =>
    profile.isAdmin || profile.canDelete(module);

bool canExport(UserProfile profile, String module) =>
    profile.isAdmin || profile.canExport(module);
