import 'app_role.dart';
import 'module_permission.dart';

/// Result of `GET /me/` — the user's profile, role, permissions, and scopes.
///
/// Drives dynamic menu building and permission-aware rendering. Never a
/// security boundary — the server enforces.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.role = AppRole.student,
    this.sections = const [],
    this.permissions = const {},
    this.scopes,
    this.specialAbilities = const [],
  });

  final int id;
  final String name;
  final String? email;
  final AppRole role;

  /// Ordered nav sections, e.g. [myProgress, courses, students, more].
  final List<AppSection> sections;

  /// Module → permission grant map.
  final Map<String, ModulePermission> permissions;

  /// Object-level scopes, e.g. teacher → list of owned course IDs.
  final List<int>? scopes;

  /// Kiosk abilities etc.
  final List<String> specialAbilities;

  bool get isAdmin => role == AppRole.admin;
  bool get isSupervisor => role == AppRole.supervisor;
  bool get isTeacher => role == AppRole.teacher;
  bool get isStudent => role == AppRole.student;

  bool get hasKioskAbility => specialAbilities.contains('kiosk');

  /// Permission guard helpers (pure, UI-only).
  bool canView(String module) => permissions[module]?.canView ?? false;

  bool canEdit(String module) => permissions[module]?.canEdit ?? false;

  bool canDelete(String module) => permissions[module]?.canDelete ?? false;

  bool canExport(String module) => permissions[module]?.canExport ?? false;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final sectionsJson = json['sections'] as List<dynamic>? ?? const [];
    final permsJson = json['permissions'] as Map<String, dynamic>? ?? const {};
    final scopesJson = json['scopes'] as List<dynamic>?;
    final abilitiesJson = json['special_abilities'] as List<dynamic>? ?? const [];

    return UserProfile(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      role: AppRole.fromValue(json['role'] as String?),
      sections: sectionsJson
          .map((s) => AppSection.fromValue(s as String?))
          .toList(),
      permissions: {
        for (final entry in permsJson.entries)
          entry.key: ModulePermission.fromJson(
            entry.value as Map<String, dynamic>,
          ),
      },
      scopes: scopesJson?.cast<int>(),
      specialAbilities: abilitiesJson.cast<String>(),
    );
  }
}