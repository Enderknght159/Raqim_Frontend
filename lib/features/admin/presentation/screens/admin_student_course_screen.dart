import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/section_loader.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../student/domain/models/student_models.dart';
import '../../../student/domain/student_stats.dart';
import '../../../student/presentation/widgets/course_achievement_view.dart';
import '../admin_shell.dart';

/// E7x — One student's achievement inside a course: exactly what the student
/// sees in their own course detail (points + attendance + tasmi' + matn +
/// leaderboard), opened from the admin student profile's course records.
///
/// The achievement bundle names the page (AppBar), so it stays the identity
/// request; the leaderboard loads on its own [AsyncSection] instead of
/// delaying every card behind a second round-trip.
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
  late Future<StudentCourseBundle> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<StudentCourseBundle> _load() => AdminRepositoryScope.of(
    context,
  ).studentCourseBundle(widget.courseId, widget.studentId);

  @override
  Widget build(BuildContext context) {
    return AsyncView<StudentCourseBundle>(
      future: _future,
      cacheKey: 'admin-student-course-${widget.studentId}-${widget.courseId}',
      frame: (context, child) => Scaffold(
        appBar: AppBar(title: const Text('إنجاز الطالب')),
        body: child,
      ),
      builder: (context, bundle) => Scaffold(
        appBar: AppBar(title: Text(bundle.course.name)),
        body: ResponsivePage(
          maxWidth: 1100,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CourseAchievementView(
                bundle: bundle,
                leaderboard: const [],
                showLeaderboard: false,
                scrollable: false,
                onPointsTap: () => context.push(
                  '/admin/students/${widget.studentId}/courses/'
                  '${widget.courseId}/points',
                ),
              ),
              const SizedBox(height: 12),
              AsyncSection<List<StudentLeaderboardEntry>>(
                cacheKey:
                    'admin-student-course-lb-${widget.studentId}-'
                    '${widget.courseId}',
                skeleton: const SectionSkeleton(height: 84, lines: 2),
                errorBuilder: (context, retry) => SectionError(
                  onRetry: retry,
                  message: 'تعذر تحميل المتصدرين',
                ),
                load: () => AdminRepositoryScope.of(
                  context,
                ).leaderboard(widget.courseId).then((result) => result.entries),
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
