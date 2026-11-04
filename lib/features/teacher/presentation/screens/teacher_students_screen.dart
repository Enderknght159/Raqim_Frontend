import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../admin/data/admin_repository.dart';
import '../../../admin/presentation/admin_shell.dart';
import '../../data/teacher_roster_service.dart';
import '../../domain/teacher_models.dart';

/// Teacher student directory: search + team filter + read-only profile.
class TeacherStudentsScreen extends StatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  State<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  List<TeacherRosterEntry> _roster = const [];
  final _search = TextEditingController();
  int? _teamFilter;
  bool _loading = true;
  String? _error;

  AdminRepository get _repo => AdminRepositoryScope.of(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final roster = await TeacherRosterService(_repo).load();
      if (!mounted) return;
      setState(() {
        _roster = roster;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$error';
      });
    }
  }

  List<TeacherRosterEntry> get _visible {
    return _roster
        .where((entry) => entry.matchesTeam(_teamFilter))
        .where((entry) => entry.matchesQuery(_search.text))
        .toList();
  }

  List<({int id, String name})> get _teams {
    final byId = <int, String>{};
    for (final entry in _roster) {
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
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final teams = _teams;
    final visible = _visible;

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
          const SizedBox(height: 10),
          if (teams.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  AppChip(
                    label: 'الكل',
                    color: _teamFilter == null
                        ? tokens.brand
                        : tokens.textMuted,
                    onTap: () => setState(() => _teamFilter = null),
                  ),
                  const SizedBox(width: 6),
                  for (final team in teams) ...[
                    AppChip(
                      label: team.name,
                      color: _teamFilter == team.id
                          ? tokens.brand
                          : tokens.textMuted,
                      onTap: () => setState(() => _teamFilter = team.id),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _load,
                            icon: const Icon(Icons.refresh),
                            label: const Text('إعادة'),
                          ),
                        ],
                      ),
                    )
                  : _roster.isEmpty
                  ? const EmptyState(
                      title: 'لا حلقات مرتبطة بك',
                      message: 'تواصل مع إدارة المسجد لتعيين حلقاتك.',
                      icon: Icons.groups_outlined,
                    )
                  : visible.isEmpty
                  ? const EmptyState(
                      title: 'لا نتائج',
                      message: 'جرّب اسمًا آخر أو غيّر فلتر الحلقة.',
                      icon: Icons.search_off,
                    )
                  : ListView.separated(
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
          ),
        ],
      ),
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
              entry.student.name.isEmpty
                  ? '?'
                  : entry.student.name.characters.first,
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
            Text(
              'قراءة فقط',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: tokens.textMuted),
            ),
          const Icon(Icons.chevron_left),
        ],
      ),
    );
  }
}
