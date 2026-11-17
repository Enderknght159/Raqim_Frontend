import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/section_loader.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../domain/models/student_models.dart';
import '../../domain/student_stats.dart';
import '../student_shell.dart';
import '../widgets/course_achievement_view.dart';

/// B1x — Course detail (student view): points + attendance + tasmi' + matn +
/// peers, with expandable bottom sheets.
///
/// The page shell (AppBar + scroll view) paints immediately. The achievement
/// bundle and the leaderboard load in separate [AsyncSection]s, so a slow
/// leaderboard never hides the points/attendance cards.
class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key, required this.courseId});

  final int courseId;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  /// Bumped by pull-to-refresh so every section refetches.
  int _revision = 0;

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() => _revision++);
  }

  @override
  Widget build(BuildContext context) {
    final repo = StudentRepositoryScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الدورة')),
      body: ResponsivePage(
        maxWidth: 1100,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              AsyncSection<StudentCourseBundle>(
                cacheKey: 'student-course-${widget.courseId}',
                revision: _revision,
                load: () => repo.courseBundle(widget.courseId),
                skeleton: const _BundleSkeleton(),
                builder: (context, bundle) => CourseAchievementView(
                  bundle: bundle,
                  leaderboard: const [],
                  showLeaderboard: false,
                  scrollable: false,
                  onPointsTap: () => context.push(
                    '/my-progress/courses/${widget.courseId}/points',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AsyncSection<List<StudentLeaderboardEntry>>(
                cacheKey: 'student-course-lb-${widget.courseId}',
                revision: _revision,
                delay: const Duration(milliseconds: 60),
                load: () => repo.leaderboard(widget.courseId),
                skeleton: const SectionSkeleton(height: 84, lines: 2),
                builder: (context, entries) =>
                    StudentLeaderboardCard(entries: entries),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _BundleSkeleton extends StatelessWidget {
  const _BundleSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Skeleton(height: 22, width: 180),
        SizedBox(height: 8),
        Skeleton(height: 12, width: 150),
        SizedBox(height: 16),
        SectionSkeleton(height: 52, lines: 1),
        SizedBox(height: 12),
        SectionSkeleton(height: 76, lines: 2),
        SizedBox(height: 12),
        SectionSkeleton(height: 44, lines: 1),
        SizedBox(height: 12),
        SectionSkeleton(height: 64, lines: 2),
      ],
    );
  }
}
