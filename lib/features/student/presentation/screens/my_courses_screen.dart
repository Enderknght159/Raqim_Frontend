import 'package:flutter/material.dart';

import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/responsive_grid.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/student_stats.dart';
import '../student_shell.dart';
import '../widgets/course_card.dart';

/// B1 — دوراتي (landing tab). Smart-watch course cards.
class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  late Future<List<CourseOverview>> _future;

  @override
  void initState() {
    super.initState();
    _future = StudentRepositoryScope.of(context).courseOverviews();
  }

  Future<void> _refresh() async {
    final future = StudentRepositoryScope.of(context).courseOverviews();
    if (!mounted) return;
    setState(() {
      _future = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AsyncView<List<CourseOverview>>(
        future: _future,
        builder: (context, overviews) {
          if (overviews.isEmpty) {
            return const EmptyState(
              title: 'لم تنضم لدورة بعد',
              icon: Icons.school_outlined,
              message: 'ابدأ رحلتك العلمية في المسجد',
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                const SectionHeader(
                  icon: Icons.auto_stories,
                  title: 'متابعة الدورات',
                ),
                const SizedBox(height: 12),
                ResponsiveGrid(
                  minItemWidth: 280,
                  maxColumns: 3,
                  children: [
                    for (final overview in overviews)
                      CourseCard(overview: overview),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
