import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/section_loader.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/numeral_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/icon_tile.dart';
import '../../../../core/widgets/responsive_grid.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../shared/permissions.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';
import '../widgets/course_metrics_panel.dart';

/// Matn + subject counts shown inside the «المحتوى» tab.
typedef _AssetsData = ({
  List<AdminContentItem> matns,
  List<AdminContentItem> subjects,
});

/// The three people groups shown inside the «الأشخاص» tab.
enum _PeopleTab { students, teams, teachers }

/// E6 — Content tab, split into two primary tabs:
///
/// * «الأشخاص» — students / teams / teachers behind a compact three-way
///   switcher, because those three lists are the ones that get browsed most.
/// * «المحتوى» — matn and subject counts plus the tools/library destinations.
///
/// The page shell and both top tabs paint immediately; every independent data
/// set loads in its own [AsyncSection] with its own cache key and a small
/// skeleton shaped like the final card.
class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({super.key});

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen> {
  /// Bumped after returning from a pushed destination so counts revalidate.
  int _revision = 0;

  _PeopleTab _peopleTab = _PeopleTab.students;

  Future<void> _openRoute(String path) async {
    await context.push(path);
    if (mounted) setState(() => _revision++);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final canStudents = canViewModule(context, 'students');
    final canTeams = canViewModule(context, 'teams');
    final canContent = canViewModule(context, 'matn');
    final canImport = canViewModule(context, 'imports');

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              labelColor: tokens.brandText,
              unselectedLabelColor: tokens.textMuted,
              indicatorColor: tokens.brand,
              dividerColor: tokens.borderStructural,
              tabs: const [
                Tab(
                  height: 44,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.groups_outlined, size: 18),
                      SizedBox(width: 6),
                      Text('الأشخاص'),
                    ],
                  ),
                ),
                Tab(
                  height: 44,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.library_books_outlined, size: 18),
                      SizedBox(width: 6),
                      Text('المحتوى'),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _peopleBody(
                    context,
                    canStudents: canStudents,
                    canTeams: canTeams,
                  ),
                  _ContentPane(
                    revision: _revision,
                    openRoute: _openRoute,
                    canViewContent: canContent,
                    canImport: canImport,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── People ───────────────────────────────────────────────────────────────

  Widget _peopleBody(
    BuildContext context, {
    required bool canStudents,
    required bool canTeams,
  }) {
    final kinds = <_PeopleTab>[
      if (canStudents) _PeopleTab.students,
      if (canTeams) _PeopleTab.teams,
      if (canTeams) _PeopleTab.teachers,
    ];
    if (kinds.isEmpty) {
      return const _EmptyState(
        icon: Icons.lock_outline,
        message: 'لا صلاحية لعرض الطلاب والحلقات والمدرسين',
      );
    }
    final selected = kinds.contains(_peopleTab) ? _peopleTab : kinds.first;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: _PeopleSwitcher(
            kinds: kinds,
            selected: selected,
            onChanged: (tab) => setState(() => _peopleTab = tab),
          ),
        ),
        _countsStrip(context, kinds),
        Expanded(
          child: switch (selected) {
            _PeopleTab.students => _StudentsPane(
              revision: _revision,
              openRoute: _openRoute,
            ),
            _PeopleTab.teams => _TeamsPane(
              revision: _revision,
              openRoute: _openRoute,
            ),
            _PeopleTab.teachers => _TeachersPane(
              revision: _revision,
              openRoute: _openRoute,
            ),
          },
        ),
      ],
    );
  }

  /// Icon-only totals for the three people groups (no repeated captions).
  Widget _countsStrip(BuildContext context, List<_PeopleTab> kinds) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final repo = AdminRepositoryScope.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      child: AsyncSection<GeneralStats>(
        cacheKey: 'admin-content-counts',
        revision: _revision,
        load: repo.generalStats,
        skeleton: const Wrap(
          spacing: 16,
          children: [
            Skeleton(width: 44, height: 12),
            Skeleton(width: 44, height: 12),
            Skeleton(width: 44, height: 12),
          ],
        ),
        builder: (context, stats) => Wrap(
          spacing: 16,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (kinds.contains(_PeopleTab.students))
              IconCount(
                icon: Icons.groups_outlined,
                value: stats.students,
                tooltip: 'الطلاب',
                color: tokens.info,
              ),
            if (kinds.contains(_PeopleTab.teams))
              IconCount(
                icon: Icons.hub_outlined,
                value: stats.teams,
                tooltip: 'الحلقات',
                color: tokens.brand,
              ),
            if (kinds.contains(_PeopleTab.teachers))
              IconCount(
                icon: Icons.school_outlined,
                value: stats.teachers,
                tooltip: 'المدرسون',
                color: tokens.accentMatn,
              ),
          ],
        ),
      ),
    );
  }
}

/// Compact three-way switcher (segmented chips, one row).
class _PeopleSwitcher extends StatelessWidget {
  const _PeopleSwitcher({
    required this.kinds,
    required this.selected,
    required this.onChanged,
  });

  final List<_PeopleTab> kinds;
  final _PeopleTab selected;
  final ValueChanged<_PeopleTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < kinds.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: _SegmentButton(
              icon: _peopleIcon(kinds[i]),
              label: _peopleLabel(kinds[i]),
              selected: kinds[i] == selected,
              onTap: () => onChanged(kinds[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final foreground = selected ? tokens.brandText : tokens.textSecondary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radiusSmall),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? tokens.brandTint : tokens.surfaceCard,
            borderRadius: BorderRadius.circular(tokens.radiusSmall),
            border: Border.all(
              color: selected ? tokens.brandBorder : tokens.borderStructural,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: foreground),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _peopleIcon(_PeopleTab tab) => switch (tab) {
  _PeopleTab.students => Icons.groups_outlined,
  _PeopleTab.teams => Icons.hub_outlined,
  _PeopleTab.teachers => Icons.school_outlined,
};

String _peopleLabel(_PeopleTab tab) => switch (tab) {
  _PeopleTab.students => 'الطلاب',
  _PeopleTab.teams => 'الحلقات',
  _PeopleTab.teachers => 'المدرسون',
};

// ── Students ───────────────────────────────────────────────────────────────

/// Searchable, server-paginated student list. Page 1 loads through
/// [AsyncSection] (named after the current query), further pages append to
/// the same list so scrolling never rebuilds a section per row.
class _StudentsPane extends StatefulWidget {
  const _StudentsPane({required this.revision, required this.openRoute});

  final int revision;
  final Future<void> Function(String path) openRoute;

  @override
  State<_StudentsPane> createState() => _StudentsPaneState();
}

class _StudentsPaneState extends State<_StudentsPane>
    with AutomaticKeepAliveClientMixin {
  static const int _pageSize = 20;

  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';

  final _more = <AdminStudentRow>[];
  int _nextPage = 2;
  bool _moreHasMore = false;
  bool _loadingMore = false;
  Object? _moreError;

  @override
  bool get wantKeepAlive => true;

  /// A parent refresh (after returning from a profile) reloads page 1, so the
  /// appended pages must go too or rows could repeat.
  @override
  void didUpdateWidget(covariant _StudentsPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.revision != widget.revision) _resetPaging();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final query = value.trim();
      if (query == _query) return;
      setState(() {
        _query = query;
        _resetPaging();
      });
    });
  }

  void _resetPaging() {
    _more.clear();
    _nextPage = 2;
    _moreHasMore = false;
    _moreError = null;
    _loadingMore = false;
  }

  void _clearSearch() {
    _debounce?.cancel();
    _search.clear();
    if (_query.isEmpty) return;
    setState(() {
      _query = '';
      _resetPaging();
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    setState(() {
      _loadingMore = true;
      _moreError = null;
    });
    final repo = AdminRepositoryScope.of(context);
    final page = _nextPage;
    try {
      final result = await repo.studentsPage(
        query: _query,
        page: page,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _more.addAll(result.items);
        _nextPage = result.page + 1;
        _moreHasMore = result.hasMore;
        _loadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _moreError = error;
        _loadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final repo = AdminRepositoryScope.of(context);
    return Column(
      children: [
        _searchRow(context),
        Expanded(
          child: AsyncSection<PagedResult<AdminStudentRow>>(
            cacheKey: 'admin-content-students-$_query-1',
            revision: widget.revision,
            load: () =>
                repo.studentsPage(query: _query, page: 1, pageSize: _pageSize),
            skeleton: const _ListSkeleton(),
            builder: (context, page) => _list(page),
          ),
        ),
      ],
    );
  }

  Widget _searchRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _search,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'ابحث بالاسم أو الحلقة',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'مسح البحث',
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: _clearSearch,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => widget.openRoute('/admin/students'),
            style: TextButton.styleFrom(
              minimumSize: const Size(44, 44),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            icon: const Icon(Icons.people_outline, size: 18),
            label: const Text('كل الطلاب'),
          ),
        ],
      ),
    );
  }

  Widget _list(PagedResult<AdminStudentRow> page) {
    final students = <AdminStudentRow>[...page.items, ..._more];
    if (students.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: _EmptyState(
              icon: _query.isEmpty ? Icons.groups_outlined : Icons.search_off,
              message: _query.isEmpty ? 'لا طلاب بعد' : 'لا نتائج مطابقة',
            ),
          ),
        ],
      );
    }

    final hasMore = _more.isEmpty ? page.hasMore : _moreHasMore;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        for (final student in students)
          _StudentTile(
            student: student,
            onTap: () => widget.openRoute('/admin/students/${student.id}'),
          ),
        if (_moreError != null)
          _LoadMoreError(onRetry: _loadMore)
        else if (hasMore)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: TextButton.icon(
                onPressed: _loadingMore ? null : _loadMore,
                icon: const Icon(Icons.expand_more, size: 18),
                label: Text(_loadingMore ? 'جارٍ التحميل…' : 'المزيد'),
              ),
            ),
          ),
      ],
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({required this.student, required this.onTap});

  final AdminStudentRow student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final name = student.name.trim();
    final initial = name.isEmpty ? '؟' : name.characters.first;
    final teams = student.teamNames.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        onTap: onTap,
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: tokens.brandTint,
              child: Text(
                initial,
                style: TextStyle(
                  color: tokens.brandText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? 'طالب بدون اسم' : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    teams.isEmpty ? 'بلا حلقة' : teams,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                  ),
                ],
              ),
            ),
            if (!student.active) ...[
              const SizedBox(width: 6),
              Icon(Icons.block, size: 16, color: tokens.dangerText),
            ],
            const SizedBox(width: 6),
            Icon(Icons.chevron_left, color: tokens.borderStructural),
          ],
        ),
      ),
    );
  }
}

// ── Teams ──────────────────────────────────────────────────────────────────

/// Teams with the horizontal team-type filter kept at the very top, so a type
/// is always one tap away instead of being buried under the list.
class _TeamsPane extends StatefulWidget {
  const _TeamsPane({required this.revision, required this.openRoute});

  final int revision;
  final Future<void> Function(String path) openRoute;

  @override
  State<_TeamsPane> createState() => _TeamsPaneState();
}

class _TeamsPaneState extends State<_TeamsPane>
    with AutomaticKeepAliveClientMixin {
  /// Selected team-type id, `null` means «الكل».
  int? _typeId;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final repo = AdminRepositoryScope.of(context);
    return Column(
      children: [
        AsyncSection<List<AdminContentItem>>(
          cacheKey: 'admin-content-types',
          revision: widget.revision,
          delay: const Duration(milliseconds: 40),
          load: repo.teamTypes,
          skeleton: const _ChipsSkeleton(),
          builder: (context, types) => _typeFilter(types),
        ),
        Expanded(
          child: AsyncSection<List<AdminTeamRow>>(
            cacheKey: 'admin-content-teams',
            revision: widget.revision,
            load: repo.teams,
            skeleton: const _ListSkeleton(),
            builder: (context, teams) => _list(teams),
          ),
        ),
      ],
    );
  }

  /// Horizontal «الكل» + team types selector (scrolls sideways, never wraps
  /// into a tall block).
  Widget _typeFilter(List<AdminContentItem> types) {
    if (types.isEmpty) return const SizedBox(height: 4);
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: types.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _TypeChip(
              icon: Icons.apps_outlined,
              label: 'الكل',
              selected: _typeId == null,
              onTap: () => setState(() => _typeId = null),
            );
          }
          final type = types[index - 1];
          final selected = _typeId == type.id;
          return _TypeChip(
            icon: _typeIcon(type.teamTypeKind, type.teamTypePermissions),
            label: type.name,
            selected: selected,
            onTap: () => setState(() => _typeId = selected ? null : type.id),
          );
        },
      ),
    );
  }

  Widget _list(List<AdminTeamRow> teams) {
    final filtered = _typeId == null
        ? teams
        : [
            for (final team in teams)
              if (team.typeId == _typeId) team,
          ];
    if (filtered.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: _EmptyState(
              icon: Icons.hub_outlined,
              message: teams.isEmpty ? 'لا حلقات بعد' : 'لا حلقات في هذا النوع',
              actionLabel: teams.isEmpty ? 'إدارة الحلقات' : 'عرض الكل',
              onAction: teams.isEmpty
                  ? () => widget.openRoute('/admin/teams')
                  : () => setState(() => _typeId = null),
            ),
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        ResponsiveGrid(
          minItemWidth: 320,
          maxColumns: 2,
          children: [
            for (final team in filtered)
              _TeamTile(
                team: team,
                onTap: () => widget.openRoute('/admin/teams/${team.id}'),
              ),
          ],
        ),
      ],
    );
  }
}

/// Icon mapping for a team type. The server `kind` is free-form, so unknown
/// kinds fall back to the type's write switches before the generic hub icon.
IconData _typeIcon(String? kind, TeamTypePermissions permissions) {
  return switch ((kind ?? '').trim().toLowerCase()) {
    'quran' ||
    'qurantasmi' ||
    'memorization' ||
    'hifz' => Icons.menu_book_outlined,
    'matn' => Icons.auto_stories_outlined,
    'tajweed' || 'recitation' => Icons.record_voice_over_outlined,
    'points' || 'rewards' => Icons.stars_outlined,
    'attendance' => Icons.how_to_reg_outlined,
    _ when permissions.quranTasmi => Icons.menu_book_outlined,
    _ when permissions.matn => Icons.auto_stories_outlined,
    _ when permissions.attendance => Icons.how_to_reg_outlined,
    _ when permissions.points => Icons.stars_outlined,
    _ => Icons.hub_outlined,
  };
}

/// Horizontal team-type filter chip.
class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final foreground = selected ? tokens.brandText : tokens.textSecondary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radiusSmall),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44, maxWidth: 220),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? tokens.brandTint : tokens.surfaceCard,
            borderRadius: BorderRadius.circular(tokens.radiusSmall),
            border: Border.all(
              color: selected ? tokens.brandBorder : tokens.borderStructural,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: foreground),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamTile extends StatelessWidget {
  const _TeamTile({required this.team, required this.onTap});

  final AdminTeamRow team;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final teacher = team.teacherName.trim().isEmpty
        ? 'بلا معلم'
        : team.teacherName;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: tokens.brandTint,
            child: Icon(
              _typeIcon(team.typeKind, team.typePermissions),
              size: 18,
              color: tokens.brandText,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${team.typeName} · $teacher',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    IconCount(
                      icon: Icons.groups_outlined,
                      value: team.studentsCount,
                      tooltip: 'الطلاب',
                      color: tokens.infoLight,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_left, color: tokens.borderStructural),
        ],
      ),
    );
  }
}

// ── Teachers ───────────────────────────────────────────────────────────────

class _TeachersPane extends StatelessWidget {
  const _TeachersPane({required this.revision, required this.openRoute});

  final int revision;
  final Future<void> Function(String path) openRoute;

  @override
  Widget build(BuildContext context) {
    final repo = AdminRepositoryScope.of(context);
    return AsyncSection<List<AdminTeacherRow>>(
      cacheKey: 'admin-content-teachers',
      revision: revision,
      load: repo.teachers,
      skeleton: const _ListSkeleton(),
      builder: (context, teachers) {
        if (teachers.isEmpty) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: const [
              Padding(
                padding: EdgeInsets.only(top: 40),
                child: _EmptyState(
                  icon: Icons.school_outlined,
                  message: 'لا مدرسون بعد',
                ),
              ),
            ],
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            ResponsiveGrid(
              minItemWidth: 320,
              maxColumns: 2,
              children: [
                for (final teacher in teachers)
                  _TeacherTile(
                    teacher: teacher,
                    onTap: () => openRoute(
                      '/admin/teachers/${Uri.encodeComponent(teacher.name)}',
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _TeacherTile extends StatelessWidget {
  const _TeacherTile({required this.teacher, required this.onTap});

  final AdminTeacherRow teacher;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final name = teacher.name.trim();
    final initial = name.isEmpty ? '؟' : name.characters.first;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: tokens.accentMatn.withValues(alpha: 0.15),
            child: Text(
              initial,
              style: TextStyle(
                color: tokens.accentMatn,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name.isEmpty ? 'مدرس بدون اسم' : name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              IconCount(
                icon: Icons.hub_outlined,
                value: teacher.teamsCount,
                tooltip: 'الحلقات',
                color: tokens.brandText,
              ),
            ],
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_left, color: tokens.borderStructural),
        ],
      ),
    );
  }
}

// ── Content ────────────────────────────────────────────────────────────────

/// «المحتوى»: matn/subject counts and the destinations that edit them.
class _ContentPane extends StatelessWidget {
  const _ContentPane({
    required this.revision,
    required this.openRoute,
    required this.canViewContent,
    required this.canImport,
  });

  final int revision;
  final Future<void> Function(String path) openRoute;
  final bool canViewContent;
  final bool canImport;

  @override
  Widget build(BuildContext context) {
    if (!canViewContent) {
      return const _EmptyState(
        icon: Icons.lock_outline,
        message: 'لا صلاحية لعرض المتون والمواد',
      );
    }
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final repo = AdminRepositoryScope.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        const SectionHeader(
          icon: Icons.auto_stories_outlined,
          title: 'المتون والمواد',
        ),
        const SizedBox(height: 10),
        AsyncSection<_AssetsData>(
          cacheKey: 'admin-content-assets',
          revision: revision,
          load: () async {
            final matns = await repo.matns();
            final subjects = await repo.subjects();
            return (matns: matns, subjects: subjects);
          },
          skeleton: const ResponsiveGrid(
            minItemWidth: 200,
            maxColumns: 2,
            children: [
              SectionSkeleton(height: 8, lines: 1),
              SectionSkeleton(height: 8, lines: 1),
            ],
          ),
          builder: (context, assets) => ResponsiveGrid(
            minItemWidth: 200,
            maxColumns: 2,
            children: [
              _ContentCountCard(
                icon: Icons.menu_book_outlined,
                title: 'المتون',
                value: assets.matns.length,
                color: tokens.brand,
                onTap: () => openRoute('/admin/assets'),
              ),
              _ContentCountCard(
                icon: Icons.book_outlined,
                title: 'المواد',
                value: assets.subjects.length,
                color: tokens.accentMatn,
                onTap: () => openRoute('/admin/assets'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ActionRow(
          icon: Icons.library_books_outlined,
          title: 'مكتبة المحتوى',
          subtitle: 'إضافة وتعديل المتون والمواد',
          onTap: () => openRoute('/admin/assets'),
        ),
        if (canImport) ...[
          const SizedBox(height: 8),
          _ActionRow(
            icon: Icons.upload_file_outlined,
            title: 'أدوات المحتوى',
            subtitle: 'استيراد المتون والمواد دفعة واحدة',
            onTap: () => openRoute('/admin/import'),
          ),
        ],
      ],
    );
  }
}

/// Icon + title + count card; tapping opens the content assets screen.
class _ContentCountCard extends StatelessWidget {
  const _ContentCountCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final int value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          IconTile(icon: icon, color: color, size: 34, iconSize: 17),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatNumber(value),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: tokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width destination row (library · import tools).
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          IconTile(icon: icon, size: 34, iconSize: 17),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_left, color: tokens.borderStructural),
        ],
      ),
    );
  }
}

// ── Shared bits ────────────────────────────────────────────────────────────

/// Row list placeholder shaped like a compact person/team card.
class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        for (var i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const Skeleton(width: 36, height: 36, radius: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Skeleton(height: 14),
                        const SizedBox(height: 8),
                        const Skeleton(height: 11, width: 120),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Skeleton(width: 18, height: 18, radius: 4),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Placeholder for the horizontal team-type strip.
class _ChipsSkeleton extends StatelessWidget {
  const _ChipsSkeleton();

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          for (var i = 0; i < 4; i++)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Skeleton(
                width: 88,
                height: 44,
                radius: tokens.radiusSmall,
              ),
            ),
        ],
      ),
    );
  }
}

/// Compact inline retry for a failed pagination request.
class _LoadMoreError extends StatelessWidget {
  const _LoadMoreError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          const Text('تعذّر تحميل المزيد'),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

/// Compact empty state: one icon, one line, and an optional single action.
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final action = actionLabel;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: tokens.borderStructural),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
            ),
            if (action != null && onAction != null) ...[
              const SizedBox(height: 4),
              TextButton(onPressed: onAction, child: Text(action)),
            ],
          ],
        ),
      ),
    );
  }
}
