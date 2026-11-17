import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/section_loader.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/responsive_grid.dart';
import '../../../../core/widgets/responsive_scope.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../shared/permissions.dart';
import '../../data/admin_repository.dart';
import '../admin_shell.dart';
import '../../domain/admin_models.dart';
import '../widgets/course_metrics_panel.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

/// Last session + a brief course list (to resolve the course name).
typedef _LastSessionData = ({
  AdminSessionRow? session,
  List<AdminCourseSummary> courses,
});

/// E1 — Admin home: general stats + course cards + last-session shortcut.
///
/// The page shell (Scaffold/RefreshIndicator/ListView) paints immediately and
/// every block loads on its own [AsyncSection]: a slow stats query never hides
/// the course list, and each course card fetches its metrics independently.
class AdminCoursesScreen extends StatefulWidget {
  const AdminCoursesScreen({super.key});

  @override
  State<AdminCoursesScreen> createState() => _AdminCoursesScreenState();
}

class _AdminCoursesScreenState extends State<AdminCoursesScreen> {
  /// Bumped by pull-to-refresh and after writes so every section reloads.
  int _revision = 0;

  /// One `/courses` request shared by the last-session card and the grid.
  Future<List<AdminCourseSummary>>? _briefs;

  Future<void> _refresh() async {
    if (!mounted) return;
    _bump();
  }

  void _bump() {
    _briefs = null;
    setState(() => _revision++);
  }

  Future<List<AdminCourseSummary>> _loadBriefs(AdminRepository repo) =>
      _briefs ??= repo.courseBriefs();

  Future<_LastSessionData> _loadLastSession(AdminRepository repo) async {
    final results = await Future.wait<Object?>([
      repo.lastSession(),
      _loadBriefs(repo),
    ]);
    return (
      session: results[0] as AdminSessionRow?,
      courses: results[1] as List<AdminCourseSummary>,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final repo = AdminRepositoryScope.of(context);
    return Scaffold(
      floatingActionButton: canEditModule(context, 'courses')
          ? FloatingActionButton.extended(
              onPressed: _addCourse,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.radiusSmall),
              ),
              backgroundColor: tokens.brand,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text(
                'دورة',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            AsyncSection<GeneralStats>(
              cacheKey: 'admin-home-stats',
              revision: _revision,
              load: repo.generalStats,
              skeleton: _statsSkeleton(context),
              builder: (context, stats) => _statsStrip(context, stats),
            ),
            const SizedBox(height: 16),
            AsyncSection<_LastSessionData>(
              cacheKey: 'admin-home-last',
              revision: _revision,
              delay: const Duration(milliseconds: 40),
              load: () => _loadLastSession(repo),
              skeleton: _lastSessionSkeleton(context),
              builder: (context, data) {
                final session = data.session;
                if (session == null) return const SizedBox.shrink();
                return _lastSessionCard(context, session, data.courses);
              },
            ),
            const SizedBox(height: 16),
            const SectionHeader(icon: Icons.school_outlined, title: 'الدورات'),
            const SizedBox(height: 8),
            AsyncSection<List<AdminCourseSummary>>(
              cacheKey: 'admin-course-briefs',
              revision: _revision,
              delay: const Duration(milliseconds: 40),
              load: () => _loadBriefs(repo),
              skeleton: _courseGridSkeleton(),
              builder: (context, courses) {
                if (courses.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('لا دورات — أنشئ أول دورة')),
                  );
                }
                return ResponsiveGrid(
                  minItemWidth: 280,
                  maxColumns: 3,
                  children: [
                    for (var i = 0; i < courses.length; i++)
                      _courseCardSection(context, repo, courses[i], i),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// One independently-loading course card: the name/status header paints as
  /// soon as the brief list arrives, the metrics fill in when they are ready.
  Widget _courseCardSection(
    BuildContext context,
    AdminRepository repo,
    AdminCourseSummary brief,
    int index,
  ) {
    final staggerMs = 60 * index;
    return AsyncSection<AdminCourseSummary>(
      key: ValueKey('course-${brief.id}'),
      cacheKey: 'admin-course-${brief.id}',
      revision: _revision,
      delay: Duration(milliseconds: staggerMs > 300 ? 300 : staggerMs),
      load: () async {
        final summary = await repo.courseSummary(brief.id);
        if (summary == null) throw StateError('course');
        return summary;
      },
      skeleton: _courseCardSkeleton(context, brief),
      builder: (context, summary) => _courseCard(context, summary),
    );
  }

  Widget _statsStrip(BuildContext context, GeneralStats s) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final items = <({String label, int value, IconData icon, Color color})>[
      (
        label: 'طلاب',
        value: s.students,
        icon: Icons.groups_outlined,
        color: tokens.info,
      ),
      (
        label: 'حلقات',
        value: s.teams,
        icon: Icons.hub_outlined,
        color: tokens.brand,
      ),
      (
        label: 'معلمون',
        value: s.teachers,
        icon: Icons.school_outlined,
        color: tokens.accentMatn,
      ),
      (
        label: 'دورات',
        value: s.courses,
        icon: Icons.menu_book_outlined,
        color: tokens.infoLight,
      ),
      (
        label: 'طلبات معلّقة',
        value: s.pendingRequests,
        icon: Icons.inbox_outlined,
        color: tokens.reward,
      ),
      (
        label: 'صفحات مسمّعة',
        value: s.memorizedPages,
        icon: Icons.auto_stories_outlined,
        color: tokens.brandText,
      ),
    ];
    if (!ResponsiveScope.of(context).isCompact) {
      return ResponsiveGrid(
        minItemWidth: 160,
        maxColumns: 6,
        spacing: 10,
        children: [
          for (final item in items)
            StatTile(
              label: item.label,
              value: item.value,
              icon: item.icon,
              color: item.color,
            ),
        ],
      );
    }
    return SizedBox(
      height: 136,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) => SizedBox(
          width: 132,
          child: StatTile(
            label: items[i].label,
            value: items[i].value,
            icon: items[i].icon,
            color: items[i].color,
          ),
        ),
      ),
    );
  }

  /// Shape-matched placeholder for the stats strip so nothing jumps when the
  /// numbers land.
  Widget _statsSkeleton(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final radius = tokens.radiusMedium;
    if (!ResponsiveScope.of(context).isCompact) {
      return ResponsiveGrid(
        minItemWidth: 160,
        maxColumns: 6,
        spacing: 10,
        children: [
          for (var i = 0; i < 6; i++) Skeleton(height: 120, radius: radius),
        ],
      );
    }
    return SizedBox(
      height: 136,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Skeleton(width: 132, height: 136, radius: radius),
            ],
          ],
        ),
      ),
    );
  }

  Widget _lastSessionSkeleton(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      color: tokens.brandTint,
      borderColor: tokens.brandBorder,
      child: Row(
        children: [
          const Skeleton(width: 40, height: 40, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Skeleton(height: 15, width: 160),
                const SizedBox(height: 8),
                const Skeleton(height: 12, width: 110),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _lastSessionCard(
    BuildContext context,
    AdminSessionRow session,
    List<AdminCourseSummary> courses,
  ) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final course = courses.where((c) => c.id == session.courseId).firstOrNull;
    final courseName =
        (session.courseName.isNotEmpty ? session.courseName : course?.name) ??
        'الدورة';
    return AppCard(
      color: tokens.brandTint,
      borderColor: tokens.brandBorder,
      onTap: () => context.push('/admin/sessions/${session.id}'),
      child: Row(
        children: [
          Tooltip(
            message: 'آخر جلسة',
            triggerMode: TooltipTriggerMode.longPress,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tokens.brand.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.play_circle_outline,
                color: tokens.brandText,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.brand,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${session.index}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 14,
                      color: tokens.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        formatDate(session.date),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_left, color: tokens.brandText),
        ],
      ),
    );
  }

  /// Placeholder grid with the same column count as the real course list.
  Widget _courseGridSkeleton() {
    return ResponsiveGrid(
      minItemWidth: 280,
      maxColumns: 3,
      children: [
        for (var i = 0; i < 3; i++) const SectionSkeleton(height: 60, lines: 2),
      ],
    );
  }

  Widget _courseHeader(BuildContext context, AdminCourseSummary c) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Row(
      children: [
        Expanded(
          child: Text(
            c.name,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: tokens.info,
            ),
          ),
        ),
        const SizedBox(width: 8),
        StatusBadge(
          label: c.isActive ? 'نشطة' : 'منتهية',
          color: c.isActive ? tokens.brand : tokens.textMuted,
        ),
      ],
    );
  }

  /// Header + a metrics-shaped placeholder, so the grid keeps its final size.
  Widget _courseCardSkeleton(BuildContext context, AdminCourseSummary brief) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _courseHeader(context, brief),
          const SizedBox(height: 14),
          const SectionSkeleton(showCard: false, height: 60),
        ],
      ),
    );
  }

  Widget _courseCard(BuildContext context, AdminCourseSummary c) {
    return AppCard(
      // Refresh on return so edits/deletions on the course page are reflected.
      onTap: () async {
        await context.push('/admin/courses/${c.id}');
        if (mounted) _bump();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _courseHeader(context, c),
          const SizedBox(height: 14),
          CourseMetricsPanel(
            attendancePercent: c.attendancePercent,
            series: c.series,
            studentsCount: c.studentsCount,
            sessionsCount: c.sessionsCount,
            lastPresent: c.lastSessionPresent,
            lastTotal: c.lastSessionTotal,
          ),
        ],
      ),
    );
  }

  Future<void> _addCourse() async {
    final repo = AdminRepositoryScope.of(context);
    final nameController = TextEditingController();
    await showAppSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 0,
          bottom: 28 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('دورة جديدة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'اسم الدورة'),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'إنشاء',
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final now = DateTime.now();
                await repo.addCourse(
                  name,
                  now,
                  now.add(const Duration(days: 60)),
                );
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
    if (mounted) _bump();
  }
}
