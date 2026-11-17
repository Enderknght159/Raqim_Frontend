import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/section_loader.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../admin/data/admin_repository.dart';
import '../../../admin/presentation/admin_shell.dart';
import '../../data/teacher_roster_service.dart';
import '../../domain/teacher_models.dart';

/// Teacher student directory: search + team filter + read-only profile.
///
/// The page has a single data source (the teacher roster), so it is exactly one
/// [AsyncSection] (`teacher-students-roster`) that owns the team chips, the
/// result count and the list: search, filtering and scrolling stay one unit and
/// no section is created per row. The search field is outside the section, so
/// it is interactive from the first frame and keeps its text while the roster
/// revalidates.
class TeacherStudentsScreen extends StatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  State<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  final _search = TextEditingController();
  int? _teamFilter;

  /// Bumped by pull-to-refresh; the section keeps painting its cached roster.
  int _revision = 0;

  AdminRepository get _repo => AdminRepositoryScope.of(context);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() => _revision++);
  }

  List<TeacherRosterEntry> _visible(List<TeacherRosterEntry> roster) {
    return roster
        .where((entry) => entry.matchesTeam(_teamFilter))
        .where((entry) => entry.matchesQuery(_search.text))
        .toList();
  }

  List<({int id, String name})> _teams(List<TeacherRosterEntry> roster) {
    final byId = <int, String>{};
    for (final entry in roster) {
      for (final team in entry.teams) {
        byId[team.id] = team.name;
      }
    }
    final items = byId.entries.map((e) => (id: e.key, name: e.value)).toList();
    items.sort((a, b) => a.name.compareTo(b.name));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePage(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'ابحث بالاسم أو المعرّف أو الباركود',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'مسح',
                      onPressed: () {
                        _search.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: AsyncSection<List<TeacherRosterEntry>>(
                cacheKey: 'teacher-students-roster',
                revision: _revision,
                skeleton: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    Skeleton(width: 180, height: 24, radius: 999),
                    SizedBox(height: 12),
                    SectionSkeleton(height: 56, lines: 2),
                    SizedBox(height: 8),
                    SectionSkeleton(height: 56, lines: 2),
                    SizedBox(height: 8),
                    SectionSkeleton(height: 56, lines: 2),
                  ],
                ),
                load: () => TeacherRosterService(_repo).load(),
                builder: _body,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, List<TeacherRosterEntry> roster) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final teams = _teams(roster);
    final visible = _visible(roster);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (teams.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              AppChip(
                label: 'الكل',
                color: _teamFilter == null ? tokens.brand : tokens.textMuted,
                onTap: () => setState(() => _teamFilter = null),
              ),
              for (final team in teams)
                AppChip(
                  label: team.name,
                  color: _teamFilter == team.id
                      ? tokens.brand
                      : tokens.textMuted,
                  onTap: () => setState(() => _teamFilter = team.id),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        Expanded(
          child: roster.isEmpty
              ? const _ScrollableEmpty(
                  title: 'لا حلقات مرتبطة بك',
                  message: 'تواصل مع إدارة المسجد لتعيين حلقاتك.',
                  icon: Icons.groups_outlined,
                )
              : visible.isEmpty
              ? const _ScrollableEmpty(
                  title: 'لا نتائج',
                  message: 'جرّب اسمًا آخر أو غيّر فلتر الحلقة.',
                  icon: Icons.search_off,
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = visible[index];
                    return _StudentCard(
                      entry: entry,
                      onTap: () => context.push(
                        '/teacher/students/${entry.student.id}',
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Empty state that still scrolls, so pull-to-refresh keeps working (and a
/// short viewport never overflows).
class _ScrollableEmpty extends StatelessWidget {
  const _ScrollableEmpty({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 40),
        EmptyState(title: title, message: message, icon: icon),
      ],
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.entry, required this.onTap});

  final TeacherRosterEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: tokens.brandTint,
            child: Text(
              entry.student.name.trim().isEmpty
                  ? '?'
                  : entry.student.name.trim().characters.first,
              style: TextStyle(
                color: tokens.brandText,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.student.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    entry.typeNames,
                    entry.teamNames,
                  ].where((s) => s.trim().isNotEmpty).join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!entry.canWriteAnything)
            Tooltip(
              message: 'قراءة فقط',
              child: Icon(Icons.lock_outline, size: 16, color: tokens.textMuted),
            ),
          const Icon(Icons.chevron_left),
        ],
      ),
    );
  }
}
