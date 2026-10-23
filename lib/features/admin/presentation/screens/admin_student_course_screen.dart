import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/async_view.dart';
import '../../../student/domain/models/student_models.dart';
import '../../../student/domain/student_stats.dart';
import '../../../student/presentation/widgets/course_achievement_view.dart';
import '../admin_shell.dart';

/// E7x — One student's achievement inside a course: exactly what the student
/// sees in their own course detail (points + attendance + tasmi' + matn +
/// leaderboard), opened from the admin student profile's course records.
class AdminStudentCourseScreen extends StatefulWidget {
  const AdminStudentCourseScreen({
    super.key,
    required this.studentId,
    required this.courseId,
  });

  final int studentId;
  final int courseId;

  @override
  State<AdminStudentCourseScreen> createState() =>
      _AdminStudentCourseScreenState();
}

class _AdminStudentCourseScreenState extends State<AdminStudentCourseScreen> {
  late Future<_Data> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_Data> _load() async {
    final repo = AdminRepositoryScope.of(context);
    final bundle =
        await repo.studentCourseBundle(widget.courseId, widget.studentId);
    final leaderboard = (await repo.leaderboard(widget.courseId)).entries;
    return _Data(bundle: bundle, leaderboard: leaderboard);
  }

  @override
  Widget build(BuildContext context) {
    return AsyncView<_Data>(
      future: _future,
      builder: (context, data) => Scaffold(
        appBar: AppBar(title: Text(data.bundle.course.name)),
        body: CourseAchievementView(
          bundle: data.bundle,
          leaderboard: data.leaderboard,
          onPointsTap: () => context.push(
              '/admin/students/${widget.studentId}/courses/${widget.courseId}/points'),
        ),
      ),
    );
  }
}

class _Data {
  const _Data({required this.bundle, required this.leaderboard});

  final StudentCourseBundle bundle;
  final List<StudentLeaderboardEntry> leaderboard;
}
