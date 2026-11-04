/// Per-module permission grant for a user (dynamic for مشرفين).
///
/// Modules: students, attendance, points, exams, recitation, books, teams,
/// courses, reports.
class ModulePermission {
  const ModulePermission({
    required this.module,
    this.canView = false,
    this.canEdit = false,
    this.canDelete = false,
    this.canExport = false,
    this.scopeCourseIds = const [],
    this.scopeTeamIds = const [],
  });

  final String module;
  final bool canView;
  final bool canEdit;
  final bool canDelete;
  final bool canExport;

  /// Module scope (`capabilities[module].scope`). Empty = unrestricted.
  final List<int> scopeCourseIds;
  final List<int> scopeTeamIds;

  bool get hasScope => scopeCourseIds.isNotEmpty || scopeTeamIds.isNotEmpty;

  factory ModulePermission.fromJson(Map<String, dynamic> json) {
    bool flag(String camel, String snake) {
      final value = json[camel] ?? json[snake];
      return value is bool ? value : false;
    }

    List<int> ids(Object? raw) {
      if (raw is List) {
        return raw
            .map((e) => e is int ? e : int.tryParse('$e'))
            .whereType<int>()
            .toList();
      }
      return const [];
    }

    final scope = json['scope'] is Map
        ? Map<String, dynamic>.from(json['scope'] as Map)
        : const <String, dynamic>{};

    return ModulePermission(
      module: json['module'] as String? ?? '',
      canView: flag('view', 'can_view'),
      canEdit: flag('update', 'can_edit'),
      canDelete: flag('delete', 'can_delete'),
      canExport: flag('export', 'can_export'),
      scopeCourseIds: ids(scope['courseIds']),
      scopeTeamIds: ids(scope['teamIds']),
    );
  }
}
