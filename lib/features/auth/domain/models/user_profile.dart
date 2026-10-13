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
    this.username,
    this.email,
    this.mosqueName,
    this.role = AppRole.student,
    this.sections = const [],
    this.permissions = const {},
    this.scopes,
    this.specialAbilities = const [],
    this.usesDefaultPassword = false,
    this.isDemo = false,
  });

  final int id;
  final String name;
  final String? username;
  final String? email;
  final String? mosqueName;
  final AppRole role;

  /// Ordered nav sections, e.g. [myCourses, quran, achievement, teams, profile].
  final List<AppSection> sections;

  /// Module → permission grant map.
  final Map<String, ModulePermission> permissions;

  /// Object-level scopes, e.g. teacher → list of owned course IDs.
  final List<int>? scopes;

  /// Kiosk abilities etc.
  final List<String> specialAbilities;

  /// True while the account still uses the seeded default password
  /// (`admin`/`admin1234`). Drives the non-blocking change-password banner.
  final bool usesDefaultPassword;

  /// True when this profile is the local demo fallback (server `/me` was
  /// unavailable). UI shows an "وضع تجريبي" badge.
  final bool isDemo;

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

  /// Local demo profile used when the backend `/me` is not available yet.
  /// Drives the full student experience against local seeded data.
  factory UserProfile.demo({String? username}) {
    return UserProfile(
      id: 1,
      name: 'عبد الرحمن',
      username: username,
      email: null,
      mosqueName: 'جامع الفرقان',
      role: AppRole.student,
      sections: const [
        AppSection.myCourses,
        AppSection.quran,
        AppSection.achievement,
        AppSection.teams,
        AppSection.profile,
      ],
      isDemo: true,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final sectionsJson = json['sections'] as List<dynamic>? ?? const [];
    final permsJson = json['permissions'] as Map<String, dynamic>? ?? const {};
    final scopesJson = json['scopes'] as List<dynamic>?;
    final abilitiesJson = json['special_abilities'] as List<dynamic>? ?? const [];

    return UserProfile(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      username: json['username'] as String?,
      email: json['email'] as String?,
      mosqueName: (json['mosque'] as Map<String, dynamic>?)?['name'] as String?,
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
      usesDefaultPassword:
          json['uses_default_password'] as bool? ??
              json['usesDefaultPassword'] as bool? ??
              false,
    );
  }
}