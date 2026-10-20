import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/sparkline.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../../core/widgets/status_badge.dart';
import '../admin_shell.dart';
import '../../domain/admin_models.dart';

/// E1 — Admin home: general stats + course cards + last-session shortcut.
class AdminCoursesScreen extends StatefulWidget {
  const AdminCoursesScreen({super.key});

  @override
  State<AdminCoursesScreen> createState() => _AdminCoursesScreenState();
}

class _AdminCoursesScreenState extends State<AdminCoursesScreen> {
  late Future<({GeneralStats stats, List<AdminCourseSummary> courses, AdminSessionRow? last})>
      _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<({GeneralStats stats, List<AdminCourseSummary> courses, AdminSessionRow? last})>
      _load() async {
    final repo = AdminRepositoryScope.of(context);
    return (
      stats: await repo.generalStats(),
      courses: await repo.courses(),
      last: await repo.lastSession(),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCourse,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSmall),
        ),
        backgroundColor: tokens.brand,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('دورة',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ),
      body: AsyncView(
        future: _future,
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
                const SectionHeader(icon: Icons.school_outlined, title: 'الدورات'),
                const SizedBox(height: 8),
                if (data.courses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('لا دورات — أنشئ أول دورة')),
                  )
                else
                  for (final c in data.courses) ...[
                    _courseCard(context, c),
                    const SizedBox(height: 12),
                  ],
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
      (label: 'طلاب', value: s.students, icon: Icons.groups_outlined, color: tokens.info),
      (label: 'حلقات', value: s.teams, icon: Icons.hub_outlined, color: tokens.brand),
      (label: 'معلمون', value: s.teachers, icon: Icons.school_outlined, color: tokens.accentMatn),
      (label: 'دورات', value: s.courses, icon: Icons.menu_book_outlined, color: tokens.infoLight),
      (label: 'طلبات معلّقة', value: s.pendingRequests, icon: Icons.inbox_outlined, color: tokens.reward),
      (label: 'صفحات مسمّعة', value: s.memorizedPages, icon: Icons.auto_stories_outlined, color: tokens.brandText),
    ];
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
                Text('آخر جلسة',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: tokens.info,
                        )),
                Text(
                  'جلسة #${session.index} · حاضر ${session.present}/${session.total}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: tokens.textMuted),
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
      onTap: () => context.push('/admin/courses/${c.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(c.name,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: tokens.info,
                        )),
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
              _metric(context, 'حضور اليوم', '${c.todayPresent}/${c.todayTotal}'),
              _metric(context, 'طلاب', '${c.studentsCount}'),
              _metric(context, 'جلسات', '${c.sessionsCount}'),
              _metric(context, 'نسبة الحضور', '${c.attendancePercent}%'),
            ],
          ),
          if (c.series.length >= 2) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 34,
              child: Sparkline(values: c.series, color: tokens.brand, height: 34),
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
          Text(value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: tokens.textPrimary,
                  )),
          Text(label,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: tokens.textMuted)),
        ],
      ),
    );
  }

  Future<void> _addCourse() async {
    final repo = AdminRepositoryScope.of(context);
    final nameController = TextEditingController();
    await showModalBottomSheet<void>(
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
                    name, now, now.add(const Duration(days: 60)));
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
