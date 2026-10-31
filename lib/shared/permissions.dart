import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/domain/models/user_profile.dart';
import '../features/auth/presentation/cubits/auth_cubit.dart';
import '../features/auth/presentation/cubits/auth_state.dart';

/// Current profile, or null in standalone tests without an AuthCubit.
UserProfile? currentProfile(BuildContext context) {
  try {
    final auth = context.read<AuthCubit>().state;
    return auth is AuthAuthenticated ? auth.profile : null;
  } catch (_) {
    return null;
  }
}

/// UI-only guards; the server remains the security boundary.
bool canViewModule(BuildContext context, String module) {
  final profile = currentProfile(context);
  return profile == null || profile.isAdmin || profile.canView(module);
}

bool canEditModule(BuildContext context, String module) {
  final profile = currentProfile(context);
  return profile == null || profile.isAdmin || profile.canEdit(module);
}

bool canDeleteModule(BuildContext context, String module) {
  final profile = currentProfile(context);
  return profile == null || profile.isAdmin || profile.canDelete(module);
}

bool canExportModule(BuildContext context, String module) {
  final profile = currentProfile(context);
  return profile == null || profile.isAdmin || profile.canExport(module);
}

bool isAdminProfile(BuildContext context) =>
    currentProfile(context)?.isAdmin ?? false;

bool hasAnyAbility(BuildContext context, Iterable<String> abilities) {
  final profile = currentProfile(context);
  if (profile == null || profile.isAdmin) return true;
  return abilities.any(profile.specialAbilities.contains);
}
