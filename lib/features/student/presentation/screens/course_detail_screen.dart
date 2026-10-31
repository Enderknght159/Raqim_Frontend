import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/async_view.dart';
import '../../domain/models/student_models.dart';
import '../../domain/student_stats.dart';
import '../student_shell.dart';
import '../widgets/course_achievement_view.dart';

/// B1x — Course detail (student view): points + attendance + tasmi' + matn +
/// peers, with expandable bottom sheets. Renders the cached bundle instantly
/// while refreshing from the server.
class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key, required this.courseId});

  final int courseId;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  Future<StudentCourseBundle>? _future;
  Future<StudentCourseBundle?>? _cached;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repo = StudentRepositoryScope.of(context);
    _future ??= repo.courseBundle(widget.courseId);
    _cached ??= repo.cachedCourseBundle(widget.courseId);
  }

  void _reload() {
    final repo = StudentRepositoryScope.of(context);
    setState(() {
      _future = repo.courseBundle(widget.courseId);
      _cached = repo.cachedCourseBundle(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = StudentRepositoryScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الدورة')),
      body: AsyncView<StudentCourseBundle>(
        future: _future!,
        cacheKey: 'student-course-${widget.courseId}',
        cached: _cached,
        onRetry: _reload,
        builder: (context, bundle) {
          return FutureBuilder<List<StudentLeaderboardEntry>>(
            future: repo.leaderboard(widget.courseId),
            builder: (context, lbSnap) {
              return CourseAchievementView(
                bundle: bundle,
                leaderboard: lbSnap.data ?? const [],
                leaderboardLoading:
                    lbSnap.connectionState != ConnectionState.done,
                leaderboardFailed: lbSnap.hasError,
                onPointsTap: () => context.push(
                  '/my-progress/courses/${widget.courseId}/points',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
