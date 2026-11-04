import 'app_role.dart';
import 'module_permission.dart';

/// Result of `GET /me` — the user's profile, role, permissions, and scopes.
///
/// Drives dynamic menu building and permission-aware rendering. Never a
/// security boundary — the server enforces.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    this.username,
    this.email,
    this.phone,
    this.mosqueName,
    this.mosqueCode,
    this.mosqueStatus,
    this.role = AppRole.student,
    this.sections = const [],
    this.permissions = const {},
    this.teacherCapabilities = const {},
    this.supervisorCapabilities = const {},
    this.scopes,
    this.scopesByModule = const {},
    this.specialAbilities = const [],
    this.usesDefaultPassword = false,
    this.studentId,
    this.teacherId,
    this.accountState,
    this.landing,
    this.canRequestChanges = false,
    this.isDemo = false,
  });

  final int id;
  final String name;
  final String? username;
  final String? email;
  final String? phone;
  final String? mosqueName;
  final String? mosqueCode;
  final String? mosqueStatus;
  final AppRole role;

  /// Ordered nav sections returned by the backend (`student`, `teacher`, ...).
  final List<AppSection> sections;

  /// Module → permission grant map (effective union).
  final Map<String, ModulePermission> permissions;

  /// Teacher-mode capabilities only (`/me.teacherCapabilities`).
  final Map<String, ModulePermission> teacherCapabilities;

  /// Supervisor-mode capabilities only (`/me.supervisorCapabilities`).
  final Map<String, ModulePermission> supervisorCapabilities;

  /// Object-level scopes (legacy list shape).
  final List<int>? scopes;

  /// Module → `{courseIds, teamIds}` scopes returned by the API.
  final Map<String, dynamic> scopesByModule;

  /// Kiosk abilities etc.
  final List<String> specialAbilities;

  /// True while the account still uses the seeded default password.
  final bool usesDefaultPassword;

  /// Linked student row (`student.id`) when the account is a student.
  final int? studentId;

  /// Linked teacher row (`teacher.id`) when the account is a teacher.
  final int? teacherId;

  final String? accountState;

  /// Backend-selected landing section (`student`, `admin`, ...).
  final String? landing;

  /// Whether the account may submit student data change requests.
  final bool canRequestChanges;

  /// True when this profile is the local demo fallback.
  final bool isDemo;

  bool get isAdmin => role == AppRole.admin;
  bool get isSupervisor => role == AppRole.supervisor;
  bool get isTeacher => role == AppRole.teacher;
  bool get isStudent => role == AppRole.student;

  bool get hasKioskAbility => specialAbilities.contains('kiosk');

  bool get hasStudentSection =>
      studentId != null || sections.contains(AppSection.student);
  bool get hasAdminSection =>
      isAdmin ||
      isSupervisor ||
      sections.contains(AppSection.admin) ||
      sections.contains(AppSection.supervisor);
  bool get hasTeacherSection =>
      teacherId != null || sections.contains(AppSection.teacher);

  /// Permission guard helpers (pure, UI-only).
  bool canView(String module) => permissions[module]?.canView ?? false;

  bool canEdit(String module) => permissions[module]?.canEdit ?? false;

  bool canDelete(String module) => permissions[module]?.canDelete ?? false;

  bool canExport(String module) => permissions[module]?.canExport ?? false;

  /// Capability map for the selected surface. Teacher mode must never read
  /// supervisor grants (and vice versa) — the two UIs are separate.
  Map<String, ModulePermission> capabilitiesForMode({required bool teacher}) {
    if (teacher) {
      if (teacherCapabilities.isNotEmpty) return teacherCapabilities;
      // Legacy /me (before teacherCapabilities) may only expose the union.
      // Never leak supervisor grants into teacher mode on a dual account.
      if (isSupervisor || isAdmin) return const {};
      return permissions;
    }
    if (supervisorCapabilities.isNotEmpty) return supervisorCapabilities;
    return permissions;
  }

  bool teacherCanView(String module) =>
      capabilitiesForMode(teacher: true)[module]?.canView ?? false;

  bool teacherCanEdit(String module) =>
      capabilitiesForMode(teacher: true)[module]?.canEdit ?? false;

  bool teacherCanDelete(String module) =>
      capabilitiesForMode(teacher: true)[module]?.canDelete ?? false;

  /// Local demo profile used by tests / offline fallback.
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
    final userJson = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : const <String, dynamic>{};
    final links = json['links'] is Map
        ? Map<String, dynamic>.from(json['links'] as Map)
        : const <String, dynamic>{};
    final mosque = json['mosque'] is Map
        ? Map<String, dynamic>.from(json['mosque'] as Map)
        : const <String, dynamic>{};
    final student = json['student'] is Map
        ? Map<String, dynamic>.from(json['student'] as Map)
        : null;
    final teacher = json['teacher'] is Map
        ? Map<String, dynamic>.from(json['teacher'] as Map)
        : null;
    final self = json['self'] is Map
        ? Map<String, dynamic>.from(json['self'] as Map)
        : const <String, dynamic>{};

    final sectionsJson = json['sections'] as List<dynamic>? ?? const [];
    final capsRaw = json['capabilities'] ?? json['permissions'];
    final permsJson = capsRaw is Map
        ? Map<String, dynamic>.from(capsRaw)
        : const <String, dynamic>{};
    final scopesRaw = json['scopes'];
    final scopesJson = scopesRaw is List ? scopesRaw : null;
    final scopesByModule = scopesRaw is Map
        ? Map<String, dynamic>.from(scopesRaw)
        : {
            for (final entry in permsJson.entries)
              if (entry.value is Map && entry.value['scope'] is Map)
                entry.key: Map<String, dynamic>.from(
                  entry.value['scope'] as Map,
                ),
          };
    final abilitiesJson =
        (json['specialAbilities'] ?? json['special_abilities'])
            as List<dynamic>? ??
        const [];

    Map<String, ModulePermission> parseCaps(Object? raw) {
      if (raw is! Map) return const {};
      return {
        for (final entry in raw.entries)
          if (entry.value is Map)
            '${entry.key}': ModulePermission.fromJson(
              Map<String, dynamic>.from(entry.value as Map),
            ),
      };
    }

    final id = json['id'] is int
        ? json['id'] as int
        : int.tryParse('${json['id']}') ?? 0;
    final studentIdRaw = student?['id'] ?? links['studentId'];
    final teacherIdRaw = teacher?['id'] ?? links['teacherId'];

    return UserProfile(
      id: id,
      name: (json['name'] ?? userJson['name'] ?? json['username'] ?? '')
          .toString(),
      username: (json['username'] ?? userJson['username']) as String?,
      email: (json['email'] ?? userJson['email']) as String?,
      phone: (json['phone'] ?? userJson['phone']) as String?,
      mosqueName: mosque['name'] as String?,
      mosqueCode: mosque['code'] as String?,
      mosqueStatus: mosque['status'] as String?,
      role: AppRole.fromValue(json['role'] as String?),
      sections: sectionsJson
          .map((s) => AppSection.fromValue(s as String?))
          .toList(),
      permissions: {
        for (final entry in permsJson.entries)
          if (entry.value is Map)
            entry.key: ModulePermission.fromJson(
              Map<String, dynamic>.from(entry.value as Map),
            ),
      },
      teacherCapabilities: parseCaps(json['teacherCapabilities']),
      supervisorCapabilities: parseCaps(json['supervisorCapabilities']),
      scopes: scopesJson?.cast<int>(),
      scopesByModule: scopesByModule,
      specialAbilities: abilitiesJson.map((e) => '$e').toList(),
      usesDefaultPassword:
          json['uses_default_password'] as bool? ??
          json['usesDefaultPassword'] as bool? ??
          false,
      studentId: studentIdRaw is int
          ? studentIdRaw
          : int.tryParse('$studentIdRaw'),
      teacherId: teacherIdRaw is int
          ? teacherIdRaw
          : int.tryParse('$teacherIdRaw'),
      accountState: json['accountState'] as String?,
      landing: json['landing'] as String?,
      canRequestChanges: self['canRequestChanges'] as bool? ?? false,
    );
  }
}
