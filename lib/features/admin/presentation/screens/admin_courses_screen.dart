import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/responsive_grid.dart';
import '../../../../core/widgets/responsive_scope.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/sparkline.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../shared/permissions.dart';
import '../admin_shell.dart';
import '../../domain/admin_models.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

/// E1 — Admin home: general stats + course cards + last-session shortcut.
class AdminCoursesScreen extends StatefulWidget {
  const AdminCoursesScreen({super.key});

  @override
  State<AdminCoursesScreen> createState() => _AdminCoursesScreenState();
}

class _AdminCoursesScreenState extends State<AdminCoursesScreen> {
  late Future<AdminHomeData> _future;
  Future<AdminHomeData?>? _cached;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<AdminHomeData> _load() async {
    final repo = AdminRepositoryScope.of(context);
    final statsF = repo.generalStats();
    final coursesF = repo.courses();
    final lastF = repo.lastSession();
    return AdminHomeData(
      stats: await statsF,
      courses: await coursesF,
      last: await lastF,
    );
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() {
      _future = _load();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
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
      body: AsyncView<AdminHomeData>(
        future: _future,
        cacheKey: 'admin-home',
        cached: _cached ??= AdminRepositoryScope.of(context).homeCached(),
        builder: (context, data) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                _statsStrip(context, data.stats),
                const SizedBox(height: 16),
                if (data.last != null) _lastSessionCard(context, data.last!),
                const SizedBox(height: 16),
                const SectionHeader(
                  icon: Icons.school_outlined,
                  title: 'الدورات',
                ),
                const SizedBox(height: 8),
                if (data.courses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('لا دورات — أنشئ أول دورة')),
                  )
                else
                  ResponsiveGrid(
                    minItemWidth: 280,
                    maxColumns: 3,
                    children: [
                      for (final c in data.courses) _courseCard(context, c),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
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
      height: 152,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) => SizedBox(
          width: 128,
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

  Widget _lastSessionCard(BuildContext context, AdminSessionRow session) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      color: tokens.brandTint,
      borderColor: tokens.brandBorder,
      onTap: () => context.push('/admin/sessions/${session.id}'),
      child: Row(
        children: [
          Icon(Icons.play_circle_outline, color: tokens.brandText, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'آخر جلسة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: tokens.info,
                  ),
                ),
                Text(
                  'جلسة #${session.index} · حاضر ${session.present}/${session.total}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: tokens.textMuted),
        ],
      ),
    );
  }

  Widget _courseCard(BuildContext context, AdminCourseSummary c) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      // Refresh on return so edits/deletions on the course page are reflected.
      onTap: () async {
        await context.push('/admin/courses/${c.id}');
        if (mounted) _refresh();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
              StatusBadge(
                label: c.isActive ? 'نشطة' : 'منتهية',
                color: c.isActive ? tokens.brand : tokens.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _metric(
                context,
                'حضور آخر جلسة',
                '${c.lastSessionPresent}/${c.lastSessionTotal}',
              ),
              _metric(context, 'طلاب', '${c.studentsCount}'),
              _metric(context, 'جلسات', '${c.sessionsCount}'),
              _metric(context, 'نسبة الحضور', '${c.attendancePercent}%'),
            ],
          ),
          if (c.series.length >= 2) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 34,
              child: Sparkline(
                values: c.series,
                color: tokens.brand,
                height: 34,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metric(BuildContext context, String label, String value) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: tokens.textPrimary,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
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
    await _refresh();
  }
}
