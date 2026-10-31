import 'package:flutter/material.dart';

import 'admin_teacher_management_screen.dart';

/// Teacher profile route (from E8). Kept as a thin wrapper around the unified
/// teacher page so teachers without an account can use the same screen.
class AdminTeacherScreen extends StatelessWidget {
  const AdminTeacherScreen({super.key, required this.teacherName});

  final String teacherName;

  @override
  Widget build(BuildContext context) {
    return AdminTeacherManagementScreen(teacherName: teacherName);
  }
}
