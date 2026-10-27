import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/responsive_grid.dart';
import '../admin_shell.dart';

/// E6 — Content tab: vertical summary cards (students · teams/teachers ·
/// content assets).
class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({super.key});

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen> {
  late Future<_Counts> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_Counts> _load() async {
    final repo = AdminRepositoryScope.of(context);
    final statsF = repo.generalStats();
    final teamsF = repo.teams();
    final teachersF = repo.teachers();
    final matnsF = repo.matns();
    final subjectsF = repo.subjects();
    final stats = await statsF;
    final teams = await teamsF;
    final teachers = await teachersF;
    final matns = await matnsF;
    final subjects = await subjectsF;
    return _Counts(
      students: stats.students,
      teams: teams.length,
      teachers: teachers.length,
      matns: matns.length,
      subjects: subjects.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AsyncView<_Counts>(
        future: _future,
        builder: (context, c) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ResponsiveGrid(
              minItemWidth: 280,
              maxColumns: 3,
              children: [
                _SectionCard(
                  icon: Icons.groups_outlined,
                  title: 'الطلاب',
                  subtitle: '${c.students} طالب',
                  onTap: () => context.push('/admin/students'),
                ),
                _SectionCard(
                  icon: Icons.hub_outlined,
                  title: 'الحلقات والمعلمون',
                  subtitle: '${c.teams} حلقة · ${c.teachers} معلم',
                  onTap: () => context.push('/admin/teams'),
                ),
                _SectionCard(
                  icon: Icons.library_books_outlined,
                  title: 'المحتوى',
                  subtitle: '${c.matns} متن · ${c.subjects} مادة',
                  onTap: () => context.push('/admin/assets'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Counts {
  const _Counts({
    required this.students,
    required this.teams,
    required this.teachers,
    required this.matns,
    required this.subjects,
  });

  final int students;
  final int teams;
  final int teachers;
  final int matns;
  final int subjects;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
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
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tokens.brandTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: tokens.brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: tokens.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_left, color: tokens.borderStructural),
        ],
      ),
    );
  }
}
