import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/section_loader.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/responsive_grid.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/section_header.dart';
import '../../data/admin_refresh.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';
import '../widgets/course_metrics_panel.dart';
import '../widgets/team_manager_sheet.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

/// E8 — Teams & teachers (unified card): teams · teachers · team types.
/// Tapping a team opens its student preview with bulk add/remove
/// (multi-select like messaging apps, or search/barcode).
class AdminTeamsScreen extends StatefulWidget {
  const AdminTeamsScreen({super.key});

  @override
  State<AdminTeamsScreen> createState() => _AdminTeamsScreenState();
}

class _AdminTeamsScreenState extends State<AdminTeamsScreen> {
  /// Bumped after every write and by [AdminRefresh] so all sections reload.
  int _revision = 0;
  bool _addingTeam = false;

  @override
  void initState() {
    super.initState();
    AdminRefresh.instance.addListener(_onOrgChanged);
  }

  @override
  void dispose() {
    AdminRefresh.instance.removeListener(_onOrgChanged);
    super.dispose();
  }

  void _onOrgChanged() {
    if (!mounted) return;
    _reload();
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _revision++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الحلقات والمعلمون'),
        actions: [
          IconButton(
            tooltip: _addingTeam ? 'جارٍ تجهيز النموذج…' : 'إضافة حلقة',
            icon: const Icon(Icons.add_home_outlined),
            onPressed: _addingTeam ? null : _addTeam,
          ),
        ],
      ),
      body: ResponsivePage(
        maxWidth: 1100,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(icon: Icons.hub_outlined, title: 'الحلقات'),
            const SizedBox(height: 8),
            AsyncSection<List<AdminTeamRow>>(
              cacheKey: 'admin-teams',
              revision: _revision,
              skeleton: const SectionSkeleton(height: 44, lines: 1),
              errorBuilder: (context, retry) => SectionError(
                onRetry: retry,
                message: 'تعذر تحميل الحلقات',
              ),
              load: () => AdminRepositoryScope.of(context).teams(),
              builder: (context, teams) => ResponsiveGrid(
                minItemWidth: 340,
                maxColumns: 2,
                children: [for (final t in teams) _teamTile(context, t)],
              ),
            ),
            const SizedBox(height: 16),
            const SectionHeader(icon: Icons.school_outlined, title: 'المعلمون'),
            const SizedBox(height: 8),
            AsyncSection<List<AdminTeacherRow>>(
              cacheKey: 'admin-teams-teachers',
              revision: _revision,
              delay: const Duration(milliseconds: 60),
              skeleton: const SectionSkeleton(height: 44, lines: 1),
              errorBuilder: (context, retry) => SectionError(
                onRetry: retry,
                message: 'تعذر تحميل المعلمين',
              ),
              load: () => AdminRepositoryScope.of(context).teachers(),
              builder: (context, teachers) => teachers.isEmpty
                  ? Text(
                      'لا معلمون',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  : ResponsiveGrid(
                      minItemWidth: 340,
                      maxColumns: 2,
                      children: [
                        for (final t in teachers) _teacherTile(context, t),
                      ],
                    ),
            ),
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
            AsyncSection<List<AdminContentItem>>(
              cacheKey: 'admin-teams-types',
              revision: _revision,
              delay: const Duration(milliseconds: 120),
              skeleton: const SectionSkeleton(height: 40, lines: 1),
              errorBuilder: (context, retry) => SectionError(
                onRetry: retry,
                message: 'تعذر تحميل أنواع الحلقات',
              ),
              load: () => AdminRepositoryScope.of(context).teamTypes(),
              builder: (context, types) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [for (final ty in types) _typeChip(context, ty)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Deletable team-type chip (BR-601: types are mosque-managed).
  Widget _typeChip(BuildContext context, AdminContentItem ty) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Tooltip(
      message: 'حذف نوع الحلقة',
      triggerMode: TooltipTriggerMode.longPress,
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radiusSmall),
        onTap: () => _deleteType(ty),
        child: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(tokens.radiusSmall),
            border: Border.all(color: tokens.infoLight),
            color: tokens.infoTint,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ty.name,
                style: TextStyle(
                  color: tokens.info,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.close, size: 14, color: tokens.info),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteType(AdminContentItem ty) async {
    final repo = AdminRepositoryScope.of(context);
    // The teams list loads in its own section; re-read it to know whether the
    // type is still in use before deleting.
    final List<AdminTeamRow> teams;
    try {
      teams = await repo.teams();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('تعذّر التحقق من استخدام النوع: $error')),
        );
      return;
    }
    if (!mounted) return;
    final inUse = teams.where((t) => t.typeName == ty.name).length;
    if (inUse > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'النوع «${ty.name}» مستخدم في $inUse حلقة — انقله أولًا',
          ),
        ),
      );
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
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
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
            child: Text(
              t.name.characters.first,
              style: TextStyle(
                color: tokens.accentMatn,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              t.name,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          IconCount(
            icon: Icons.hub_outlined,
            value: t.teamsCount,
            tooltip: 'عدد الحلقات',
          ),
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
                Text(
                  t.name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${t.typeName} · ${t.teacherName.isEmpty ? 'بلا معلم' : t.teacherName}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
          IconCount(
            icon: Icons.groups_outlined,
            value: t.studentsCount,
            tooltip: 'عدد الطلاب',
            color: tokens.infoLight,
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_left, color: tokens.borderStructural),
        ],
      ),
    );
  }

  /// Team page (replaces the old bottom sheet): summary, teacher, members.
  Future<void> _openTeam(BuildContext context, AdminTeamRow team) async {
    await context.push('/admin/teams/${team.id}');
    if (!mounted) return;
    _reload();
  }

  Future<void> _addTeam() async {
    if (_addingTeam) return;
    setState(() => _addingTeam = true);
    final repo = AdminRepositoryScope.of(context);
    final name = TextEditingController();
    try {
      final types = await repo.teamTypes();
      final candidates = await repo.teacherCandidates();
      if (!mounted) return;
      var typeId = types.isEmpty ? null : types.first.id;
      var typeName = types.isEmpty ? '' : types.first.name;
      var teacherName = '';
      var submitting = false;
      var error = '';
      await showAppSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) => StatefulBuilder(
          builder: (context, setSheetState) => Padding(
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
                  Text(
                    'حلقة جديدة',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'اسم الحلقة'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: typeName.isEmpty ? null : typeName,
                    decoration: const InputDecoration(
                      labelText: 'النوع (إلزامي)',
                    ),
                    items: [
                      for (final t in types)
                        DropdownMenuItem(value: t.name, child: Text(t.name)),
                    ],
                    onChanged: (v) => setSheetState(() {
                      final picked = types
                          .where((t) => t.name == v)
                          .firstOrNull;
                      typeName = picked?.name ?? typeName;
                      typeId = picked?.id ?? typeId;
                    }),
                  ),
                  if (types.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'أضف نوع حلقة أولًا — لا تُنشأ حلقة بلا نوع.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Teacher: same searchable picker as the team page, including
                  // the «حساب مدرس جديد» shortcut.
                  InkWell(
                    onTap: () async {
                      final result = await showTeamTeacherPicker(
                        context,
                        repository: repo,
                        candidates: candidates,
                        selected: teacherName,
                      );
                      if (result == null || !context.mounted) return;
                      if (result is TeacherCandidate) {
                        setSheetState(() => teacherName = result.name);
                      } else if (result is String) {
                        setSheetState(() => teacherName = '');
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 20,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              teacherName.isEmpty ? 'اختر المعلم' : teacherName,
                              style: teacherName.isEmpty
                                  ? TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    )
                                  : const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                            ),
                          ),
                          const Icon(Icons.expand_more),
                        ],
                      ),
                    ),
                  ),
                  if (error.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  AppButton(
                    label: submitting ? 'جارٍ الإضافة…' : 'إضافة',
                    loading: submitting,
                    onPressed: types.isEmpty || typeId == null || submitting
                        ? null
                        : () async {
                            final trimmed = name.text.trim();
                            if (trimmed.isEmpty) {
                              setSheetState(
                                () => error = 'أدخل اسم الحلقة أولًا.',
                              );
                              return;
                            }
                            setSheetState(() {
                              submitting = true;
                              error = '';
                            });
                            try {
                              await repo.addTeam(
                                name: trimmed,
                                teamTypeId: typeId,
                                typeName: typeName,
                                teacherName: teacherName,
                              );
                              if (context.mounted) Navigator.of(context).pop();
                            } catch (e) {
                              if (!context.mounted) return;
                              setSheetState(() {
                                submitting = false;
                                error = 'تعذّرت إضافة الحلقة: $e';
                              });
                            }
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
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('تعذّر فتح نموذج الحلقة: $error')),
        );
    } finally {
      if (mounted) setState(() => _addingTeam = false);
    }
  }

  Future<void> _addType() async {
    final repo = AdminRepositoryScope.of(context);
    final name = TextEditingController();
    var submitting = false;
    var error = '';
    await showAppSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
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
              Text(
                'نوع حلقة جديد',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'الاسم'),
              ),
              if (error.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  error,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              AppButton(
                label: submitting ? 'جارٍ الإضافة…' : 'إضافة',
                loading: submitting,
                onPressed: submitting
                    ? null
                    : () async {
                        final trimmed = name.text.trim();
                        if (trimmed.isEmpty) {
                          setSheetState(
                            () => error = 'أدخل اسم نوع الحلقة أولًا.',
                          );
                          return;
                        }
                        setSheetState(() {
                          submitting = true;
                          error = '';
                        });
                        try {
                          await repo.addTeamType(trimmed);
                          if (context.mounted) Navigator.of(context).pop();
                        } catch (e) {
                          if (!context.mounted) return;
                          setSheetState(() {
                            submitting = false;
                            error = 'تعذّرت الإضافة: $e';
                          });
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    _reload();
  }
}
