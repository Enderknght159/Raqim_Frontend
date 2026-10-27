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
  });

  final String module;
  final bool canView;
  final bool canEdit;
  final bool canDelete;
  final bool canExport;

  factory ModulePermission.fromJson(Map<String, dynamic> json) {
    bool flag(String camel, String snake) {
      final value = json[camel] ?? json[snake];
      return value is bool ? value : false;
    }

    return ModulePermission(
      module: json['module'] as String? ?? '',
      canView: flag('view', 'can_view'),
      canEdit: flag('update', 'can_edit'),
      canDelete: flag('delete', 'can_delete'),
      canExport: flag('export', 'can_export'),
    );
  }
}
