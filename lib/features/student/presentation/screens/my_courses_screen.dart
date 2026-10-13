import 'package:flutter/material.dart';

import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/student_stats.dart';
import '../student_shell.dart';
import '../widgets/course_card.dart';

/// B1 — دوراتي (landing tab). Smart-watch course cards.
class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = StudentRepositoryScope.of(context);
    return Scaffold(
      body: AsyncView<List<CourseOverview>>(
        future: repo.courseOverviews(),
        builder: (context, overviews) {
          if (overviews.isEmpty) {
            return const EmptyState(
              title: 'لم تنضم لدورة بعد',
              icon: Icons.school_outlined,
              message: 'ابدأ رحلتك العلمية في المسجد',
            );
          }
          return RefreshIndicator(
            onRefresh: () async {},
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: overviews.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: SectionHeader(
                      icon: Icons.auto_stories,
                      title: 'متابعة الدورات',
                    ),
                  );
                }
                return CourseCard(overview: overviews[index - 1]);
              },
            ),
          );
        },
      ),
    );
  }
}
