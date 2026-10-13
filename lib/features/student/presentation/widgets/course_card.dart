import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/student_stats.dart';
import 'attendance_ring.dart';

/// B1 "smart watch" course card.
///
/// Layout: course name on one line, a compact meta line (sessions count +
/// short dates) below it, then a divider and a row with the attendance ring
/// (with an explicit "حضور" caption) and the points block (المحصلة + الترتيب)
/// on a subtle tinted surface. Tap → course detail (Hero-free push).
class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.overview});

  final CourseOverview overview;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final course = overview.course;
    final isActive = course.isActive;
    final points = overview.totalPoints;

    return InkWell(
      borderRadius: BorderRadius.circular(tokens.radiusMedium),
      onTap: () => context.push('/my-progress/courses/${course.id}'),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    course.name,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: tokens.info,
                        ),
                  ),
                ),
                const SizedBox(width: 10),
                StatusBadge(
                  label: isActive ? 'نشطة' : 'منتهية',
                  color: isActive ? tokens.brand : tokens.textMuted,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${overview.attendance.totalSessions} جلسة · '
              '${formatShortDate(course.startDate)} – ${formatShortDate(course.endDate)}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: tokens.textMuted),
            ),
            const SizedBox(height: 12),
            Divider(color: tokens.borderStructural, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                // Attendance ring (open arc; the gap = absence).
                AttendanceRing(
                  early: overview.attendance.early,
                  onTime: overview.attendance.onTime,
                  late: overview.attendance.late,
                  totalSessions: overview.attendance.totalSessions,
                  radius: 30,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: tokens.brandTint,
                      borderRadius:
                          BorderRadius.circular(tokens.radiusSmall),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.emoji_events,
                                size: 14, color: tokens.rewardText),
                            const SizedBox(width: 4),
                            Text(
                              'المحصلة',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: tokens.rewardText),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$points',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                    color: points < 0
                                        ? tokens.danger
                                        : tokens.rewardText,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                'نقطة',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: tokens.rewardText),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.leaderboard_outlined,
                                size: 14, color: tokens.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              overview.rank == null
                                  ? 'بلا ترتيب'
                                  : 'الترتيب #${overview.rank}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: tokens.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}