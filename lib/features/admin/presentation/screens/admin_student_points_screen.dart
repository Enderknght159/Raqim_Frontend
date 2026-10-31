import 'package:flutter/material.dart';

import '../../../../core/widgets/async_view.dart';
import '../../../student/domain/student_stats.dart';
import '../../../student/presentation/widgets/points_breakdown_view.dart';
import '../admin_shell.dart';

/// Full-page points breakdown for one student (E7x → points card).
class AdminStudentPointsScreen extends StatefulWidget {
  const AdminStudentPointsScreen({
    super.key,
    required this.studentId,
    required this.courseId,
  });

  final int studentId;
  final int courseId;

  @override
  State<AdminStudentPointsScreen> createState() =>
      _AdminStudentPointsScreenState();
}

class _AdminStudentPointsScreenState extends State<AdminStudentPointsScreen> {
  Future<StudentCourseBundle>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= AdminRepositoryScope.of(
      context,
    ).studentCourseBundle(widget.courseId, widget.studentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('محصلة النقاط')),
      body: AsyncView<StudentCourseBundle>(
        future: _future!,
        cacheKey: 'admin-student-points-${widget.studentId}-${widget.courseId}',
        builder: (context, bundle) => PointsBreakdownView(bundle: bundle),
      ),
    );
  }
}
