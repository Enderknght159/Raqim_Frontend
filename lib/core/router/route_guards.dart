import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/models/app_role.dart';
import '../../features/auth/domain/models/user_profile.dart';
import '../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../features/auth/presentation/cubits/auth_state.dart';

/// Top-level auth redirect: unauthenticated users are sent to `/login`.
FutureOr<String?> authRedirect(BuildContext context, GoRouterState state) {
  final auth = context.read<AuthCubit>().state;
  final isLoginRoute = state.uri.path == '/login';
  if (auth is AuthAuthenticated) {
    return isLoginRoute ? '/' : null;
  }
  if (auth is AuthUnauthenticated || auth is AuthSessionExpired) {
    return isLoginRoute ? null : '/login';
  }
  // Restoring / loading — keep the splash visible.
  return null;
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