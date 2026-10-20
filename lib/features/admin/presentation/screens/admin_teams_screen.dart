import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/search_picker_field.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';
import '../widgets/team_manager_sheet.dart';

/// E8 — Teams & teachers (unified card): teams · teachers · team types.
/// Tapping a team opens its student preview with bulk add/remove
/// (multi-select like messaging apps, or search/barcode).
class AdminTeamsScreen extends StatefulWidget {
  const AdminTeamsScreen({super.key});

  @override
  State<AdminTeamsScreen> createState() => _AdminTeamsScreenState();
}

class _AdminTeamsScreenState extends State<AdminTeamsScreen> {
  late Future<_Data> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_Data> _load() async {
    final repo = AdminRepositoryScope.of(context);
    return _Data(
      teams: await repo.teams(),
      teachers: await repo.teachers(),
      types: await repo.teamTypes(),
    );
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AsyncView<_Data>(
      future: _future,
      builder: (context, data) => Scaffold(
        appBar: AppBar(
          title: const Text('الحلقات والمعلمون'),
          actions: [
            IconButton(
              tooltip: 'إضافة حلقة',
              icon: const Icon(Icons.add_home_outlined),
              onPressed: _addTeam,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(icon: Icons.hub_outlined, title: 'الحلقات'),
            const SizedBox(height: 8),
            for (final t in data.teams) ...[
              _teamTile(context, t),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 16),
            const SectionHeader(icon: Icons.school_outlined, title: 'المعلمون'),
            const SizedBox(height: 8),
            if (data.teachers.isEmpty)
              Text('لا معلمون', style: Theme.of(context).textTheme.bodyMedium)
            else
              for (final t in data.teachers) ...[
                _teacherTile(context, t),
                const SizedBox(height: 8),
              ],
            const SizedBox(height: 16),
            SectionHeader(
              icon: Icons.category_outlined,
              title: 'أنواع الحلقات',
              trailing: TextButton.icon(
                onPressed: _addType,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة'),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final ty in data.types)
                  _typeChip(context, ty, data),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Deletable team-type chip (BR-601: types are mosque-managed).
  Widget _typeChip(BuildContext context, AdminContentItem ty, _Data data) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return InkWell(
      borderRadius: BorderRadius.circular(tokens.radiusSmall),
      onTap: () => _deleteType(ty, data),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tokens.radiusSmall),
          border: Border.all(color: tokens.infoLight),
          color: tokens.infoTint,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(ty.name,
                style: TextStyle(
                    color: tokens.info, fontWeight: FontWeight.w700)),
            const SizedBox(width: 6),
            Icon(Icons.close, size: 14, color: tokens.info),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteType(AdminContentItem ty, _Data data) async {
    final inUse = data.teams.where((t) => t.typeName == ty.name).length;
    if (inUse > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('النوع «${ty.name}» مستخدم في $inUse حلقة — انقله أولًا')));
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف نوع الحلقة'),
        content: Text('حذف النوع «${ty.name}»؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حذف')),
        ],
      ),
    );
    if (confirm != true) return;
    if (!mounted) return;
    await AdminRepositoryScope.of(context).deleteTeamType(ty.id);
    if (!mounted) return;
    _reload();
  }

  Widget _teacherTile(BuildContext context, AdminTeacherRow t) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () =>
          context.push('/admin/teachers/${Uri.encodeComponent(t.name)}'),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: tokens.accentMatn.withValues(alpha: 0.15),
            child: Text(t.name.characters.first,
                style: TextStyle(
                    color: tokens.accentMatn, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(t.name,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ),
          Text('${t.teamsCount} حلقة',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: tokens.textMuted)),
          const SizedBox(width: 6),
          Icon(Icons.chevron_left, color: tokens.borderStructural),
        ],
      ),
    );
  }

  Widget _teamTile(BuildContext context, AdminTeamRow t) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => _openTeam(context, t),
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
                Text(t.name,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text(
                  '${t.typeName} · ${t.teacherName.isEmpty ? 'بلا معلم' : t.teacherName}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
          StatusBadge(label: '${t.studentsCount} طالب', color: tokens.infoLight),
          const SizedBox(width: 6),
          Icon(Icons.chevron_left, color: tokens.borderStructural),
        ],
      ),
    );
  }

  /// Team preview + bulk add/remove (E8).
  Future<void> _openTeam(BuildContext context, AdminTeamRow team) async {
    final repo = AdminRepositoryScope.of(context);
    await showTeamManagerSheet(context, team, repository: repo);
    if (!mounted) return;
    _reload();
  }

  Future<void> _addTeam() async {
    final repo = AdminRepositoryScope.of(context);
    final name = TextEditingController();
    final types = await repo.teamTypes();
    final teacherNames = (await repo.teachers()).map((t) => t.name).toList();
    var type = types.isEmpty ? 'عام' : types.first.name;
    var teacherName = '';
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 0,
            bottom: 28 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('حلقة جديدة',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'اسم الحلقة')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'النوع'),
                  items: [
                    for (final t in types)
                      DropdownMenuItem(value: t.name, child: Text(t.name)),
                  ],
                  onChanged: (v) => setState(() => type = v ?? type),
                ),
                const SizedBox(height: 12),
                // Teacher: pick from the mosque teachers (never a free field).
                SearchPickerField<String>(
                  label: 'اختر المعلم',
                  items: ['', ...teacherNames],
                  titleBuilder: (n) => n.isEmpty ? 'بلا معلم' : n,
                  subtitleBuilder: null,
                  value: teacherName.isEmpty ? null : teacherName,
                  onChanged: (n) => setState(() => teacherName = n),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'إضافة',
                  onPressed: () async {
                    if (name.text.trim().isEmpty) return;
                    await repo.addTeam(
                      name: name.text.trim(),
                      typeName: type,
                      teacherName: teacherName,
                    );
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted) return;
    _reload();
  }

  Future<void> _addType() async {
    final repo = AdminRepositoryScope.of(context);
    final name = TextEditingController();
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
            Text('نوع حلقة جديد',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'الاسم')),
            const SizedBox(height: 16),
            AppButton(
              label: 'إضافة',
              onPressed: () async {
                if (name.text.trim().isEmpty) return;
                await repo.addTeamType(name.text.trim());
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    _reload();
  }
}

class _Data {
  const _Data({required this.teams, required this.teachers, required this.types});

  final List<AdminTeamRow> teams;
  final List<AdminTeacherRow> teachers;
  final List<AdminContentItem> types;
}
