import 'package:flutter/material.dart';

import '../../../../core/widgets/async_view.dart';
import '../../domain/student_stats.dart';
import '../student_shell.dart';
import '../widgets/points_breakdown_view.dart';

/// Full-page «محصلة النقاط» for the student (B1x → points card).
class StudentPointsScreen extends StatefulWidget {
  const StudentPointsScreen({super.key, required this.courseId});

  final int courseId;

  @override
  State<StudentPointsScreen> createState() => _StudentPointsScreenState();
}

class _StudentPointsScreenState extends State<StudentPointsScreen> {
  Future<StudentCourseBundle>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= StudentRepositoryScope.of(context).courseBundle(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('محصلة النقاط')),
      body: AsyncView<StudentCourseBundle>(
        future: _future!,
        builder: (context, bundle) => PointsBreakdownView(bundle: bundle),
      ),
    );
  }
}
