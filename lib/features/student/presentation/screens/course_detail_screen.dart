import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/async_view.dart';
import '../../domain/models/student_models.dart';
import '../../domain/student_stats.dart';
import '../student_shell.dart';
import '../widgets/course_achievement_view.dart';

/// B1x — Course detail (student view): points + attendance + tasmi' + matn +
/// peers, with expandable bottom sheets.
class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key, required this.courseId});

  final int courseId;

  @override
  Widget build(BuildContext context) {
    final repo = StudentRepositoryScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الدورة')),
      body: AsyncView<StudentCourseBundle>(
        future: repo.courseBundle(courseId),
        builder: (context, bundle) {
          final leaderboard = repo.leaderboard(courseId);
          return FutureBuilder<List<StudentLeaderboardEntry>>(
            future: leaderboard,
            builder: (context, lbSnap) {
              return CourseAchievementView(
                bundle: bundle,
                leaderboard: lbSnap.data ?? const [],
                onPointsTap: () =>
                    context.push('/my-progress/courses/$courseId/points'),
              );
            },
          );
        },
      ),
    );
  }
}
