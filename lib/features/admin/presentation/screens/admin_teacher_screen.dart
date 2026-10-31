import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';

/// Teacher profile (from E8): their teams with assign/remove actions.
class AdminTeacherScreen extends StatefulWidget {
  const AdminTeacherScreen({super.key, required this.teacherName});

  final String teacherName;

  @override
  State<AdminTeacherScreen> createState() => _AdminTeacherScreenState();
}

class _AdminTeacherScreenState extends State<AdminTeacherScreen> {
  late Future<_Data> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_Data> _load() async {
    final repo = AdminRepositoryScope.of(context);
    final teams = await repo.teams();
    return _Data(
      mine: teams.where((t) => t.teacherName == widget.teacherName).toList(),
      others: teams.where((t) => t.teacherName != widget.teacherName).toList(),
    );
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AsyncView<_Data>(
      future: _future,
      cacheKey: 'admin-teacher-${widget.teacherName}',
      builder: (context, data) => Scaffold(
        appBar: AppBar(title: Text(widget.teacherName)),
        body: ResponsivePage(
          maxWidth: 900,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: tokens.accentMatn.withValues(
                        alpha: 0.15,
                      ),
                      child: Text(
                        widget.teacherName.characters.first,
                        style: TextStyle(
                          color: tokens.accentMatn,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.teacherName,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          StatusBadge(
                            label: 'مدرس الحلقة (من الباك)',
                            color: tokens.accentMatn,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${data.mine.length} حلقة',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: tokens.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const SectionHeader(
                icon: Icons.hub_outlined,
                title: 'حلقاته (يمكن إزالته منها)',
              ),
              const SizedBox(height: 8),
              if (data.mine.isEmpty)
                Text('لا حلقات', style: Theme.of(context).textTheme.bodyMedium)
              else
                for (final t in data.mine) ...[
                  _teamRow(context, t, assigned: true),
                  const SizedBox(height: 8),
                ],
              const SizedBox(height: 16),
              const SectionHeader(
                icon: Icons.add_home_work_outlined,
                title: 'حلقات أخرى (يمكن تعيينه عليها)',
              ),
              const SizedBox(height: 8),
              if (data.others.isEmpty)
                Text(
                  'لا حلقات أخرى',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                for (final t in data.others) ...[
                  _teamRow(context, t, assigned: false),
                  const SizedBox(height: 8),
                ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamRow(
    BuildContext context,
    AdminTeamRow t, {
    required bool assigned,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: tokens.brandTint,
            child: Icon(Icons.hub, size: 18, color: tokens.brandText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${t.typeName} · ${t.teacherName.isEmpty ? 'بلا معلم' : t.teacherName} · ${t.studentsCount} طالب',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
          if (assigned)
            TextButton(
              onPressed: () => _unassign(t),
              style: TextButton.styleFrom(foregroundColor: tokens.dangerText),
              child: const Text('إزالة'),
            )
          else
            TextButton(onPressed: () => _assign(t), child: const Text('تعيين')),
        ],
      ),
    );
  }

  Future<void> _assign(AdminTeamRow t) async {
    if (t.teacherName.isNotEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تعيين المعلم'),
          content: Text(
            'الحلقة عليها معلم حاليًا (${t.teacherName}). استبداله بـ ${widget.teacherName}؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('استبدال'),
            ),
          ],
        ),
      );
      if (confirm != true || !mounted) return;
    }
    try {
      await AdminRepositoryScope.of(
        context,
      ).setTeamTeacher(t.id, widget.teacherName);
      if (!mounted) return;
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذّر تعيين المعلم: $e')));
    }
  }

  Future<void> _unassign(AdminTeamRow t) async {
    try {
      await AdminRepositoryScope.of(context).removeTeamTeacher(t.id);
      if (!mounted) return;
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذّر إزالة المعلم: $e')));
    }
  }
}

class _Data {
  const _Data({required this.mine, required this.others});

  final List<AdminTeamRow> mine;
  final List<AdminTeamRow> others;
}
