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
    return ModulePermission(
      module: json['module'] as String? ?? '',
      canView: json['can_view'] as bool? ?? false,
      canEdit: json['can_edit'] as bool? ?? false,
      canDelete: json['can_delete'] as bool? ?? false,
      canExport: json['can_export'] as bool? ?? false,
    );
  }
}