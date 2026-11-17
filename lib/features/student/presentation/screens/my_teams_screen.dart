import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/list_row.dart';
import '../../../../core/widgets/responsive_grid.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/student_repository.dart';
import '../../domain/models/student_models.dart';
import '../student_shell.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

/// B4 — حلقاتي: team cards → details (teacher + peers).
///
/// The team list is a single request (page-level `AsyncView`), while each
/// card's peers row loads on its own: it shows a slim skeleton instead of
/// flashing «لا أصدقاء» before the peers arrive.
class MyTeamsScreen extends StatelessWidget {
  const MyTeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = StudentRepositoryScope.of(context);
    return Scaffold(
      body: AsyncView<List<Team>>(
        future: repo.teams(),
        cacheKey: 'student-teams',
        cached: repo.cachedTeams(),
        builder: (context, teams) {
          if (teams.isEmpty) {
            return const EmptyState(
              title: 'لم تُسجّل في حلقة بعد',
              icon: Icons.groups_outlined,
              message: 'تواصل مع إدارة المسجد',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ResponsiveGrid(
                minItemWidth: 280,
                maxColumns: 3,
                children: [
                  for (final team in teams) _TeamCard(repo: repo, team: team),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TeamCard extends StatefulWidget {
  const _TeamCard({required this.repo, required this.team});

  final StudentRepository repo;
  final Team team;

  @override
  State<_TeamCard> createState() => _TeamCardState();
}

class _TeamCardState extends State<_TeamCard> {
  late Future<List<StudentBrief>> _peers;

  @override
  void initState() {
    super.initState();
    _peers = widget.repo.peersOfTeam(widget.team.id);
  }

  @override
  void didUpdateWidget(covariant _TeamCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.team.id != widget.team.id ||
        oldWidget.repo != widget.repo) {
      _peers = widget.repo.peersOfTeam(widget.team.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final team = widget.team;
    return FutureBuilder<List<StudentBrief>>(
      future: _peers,
      builder: (context, snapshot) {
        final peers = snapshot.data ?? const <StudentBrief>[];
        final loading = snapshot.connectionState != ConnectionState.done;
        return AppCard(
          onTap: loading ? null : () => _showDetail(context, peers),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _typeColor(tokens).withValues(alpha: 0.15),
                    child: Icon(_typeIcon(), color: _typeColor(tokens)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: tokens.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        // Type name is shown as text (not icon-only): mosques
                        // add their own team types (BR-601).
                        StatusBadge(
                          label: team.typeName,
                          color: _typeColor(tokens),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_left, color: tokens.borderStructural),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 18,
                    color: Color(0xFF004C69),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      team.teacherDisplayName.isEmpty
                          ? 'لا معلم بعد'
                          : team.teacherDisplayName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (loading) ...[
                    const Skeleton(width: 64, height: 24, radius: 12),
                    const SizedBox(width: 10),
                    const Skeleton(width: 56, height: 12),
                  ] else ...[
                    _avatarStack(tokens, peers),
                    const SizedBox(width: 10),
                    Text(
                      peers.isEmpty ? 'لا أصدقاء' : '${peers.length} أصدقاء',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _avatarStack(AppTokens tokens, List<StudentBrief> peers) {
    const size = 24.0;
    const overlap = 14.0;
    final shown = peers.take(3).length;
    return SizedBox(
      height: size,
      width: (size * shown) - (shown == 0 ? 0 : overlap * (shown - 1)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < shown; i++)
            Positioned(
              left: i * overlap,
              child: CircleAvatar(
                radius: size / 2,
                backgroundColor: AppColorsForPeer.color(i, tokens),
                child: Text(
                  peers[i].name.characters.first,
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _typeIcon() => widget.team.typeName == 'قرآن'
      ? Icons.menu_book
      : widget.team.typeName == 'عام'
      ? Icons.groups_outlined
      : Icons.school_outlined;

  Color _typeColor(AppTokens tokens) => widget.team.typeName == 'قرآن'
      ? tokens.brand
      : widget.team.typeName == 'عام'
      ? tokens.infoLight
      : tokens.accentMatn;

  void _showDetail(BuildContext context, List<StudentBrief> peers) {
    final team = widget.team;
    final tokens = Theme.of(context).extension<AppTokens>()!;
    showAppSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text(team.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ListRow(
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: tokens.surfaceSubtle,
                child: Icon(Icons.person, color: tokens.textMuted),
              ),
              title: team.teacherDisplayName.isEmpty
                  ? 'المعلم غير محدد'
                  : team.teacherDisplayName,
              subtitle: 'معلم الحلقة',
            ),
            const SizedBox(height: 8),
            Text(
              'الأصدقاء (${peers.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            for (var i = 0; i < peers.length; i++)
              ListRow(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColorsForPeer.color(
                    i,
                    tokens,
                  ).withValues(alpha: 0.25),
                  child: Text(
                    peers[i].name.characters.first,
                    style: TextStyle(
                      color: AppColorsForPeer.color(i, tokens),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                title: peers[i].name,
              ),
          ],
        ),
      ),
    );
  }
}

/// Small helper for deterministic peer avatar colors (no extra dep).
class AppColorsForPeer {
  static const _palette = [
    Color(0xFF00A572),
    Color(0xFF2AA5D6),
    Color(0xFF7C3AED),
    Color(0xFFF59E0B),
    Color(0xFFBE123C),
  ];

  static Color color(int index, AppTokens tokens) =>
      _palette[index % _palette.length];
}
