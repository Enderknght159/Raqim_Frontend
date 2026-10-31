import 'package:flutter/material.dart';

import 'admin_teacher_management_screen.dart';

/// E11 — «صلاحيات التدريس» for one account. Kept as a thin route wrapper
/// around the unified teacher page.
class AdminUserTeachingScreen extends StatelessWidget {
  const AdminUserTeachingScreen({
    super.key,
    required this.userId,
    this.initialName,
    this.initialUsername,
    this.initialTeacherId,
  });

  /// Account id (not the teacher/student row id).
  final int userId;
  final String? initialName;
  final String? initialUsername;
  final int? initialTeacherId;

  @override
  Widget build(BuildContext context) {
    return AdminTeacherManagementScreen(
      userId: userId,
      initialName: initialName,
      initialUsername: initialUsername,
      initialTeacherId: initialTeacherId,
    );
  }
}
