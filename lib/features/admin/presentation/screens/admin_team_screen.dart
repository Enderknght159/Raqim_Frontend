import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/section_loader.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../shared/permissions.dart';
import '../../data/admin_refresh.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';
import '../widgets/course_metrics_panel.dart';
import '../widgets/team_manager_sheet.dart';

/// Full team (halaqa) page: summary, teacher management, and members.
///
/// Opened from E8, the unified teacher page, and the account teaching page so
/// the old bottom sheet is replaced by a normal page with an AppBar/back.
class AdminTeamScreen extends StatefulWidget {
  const AdminTeamScreen({
    super.key,
    required this.teamId,
    this.initialName,
    this.initialTypeName,
    this.initialStudentsCount,
  });

  final int teamId;
  final String? initialName;
  final String? initialTypeName;
  final int? initialStudentsCount;

  @override
  State<AdminTeamScreen> createState() => _AdminTeamScreenState();
}

class _AdminTeamScreenState extends State<AdminTeamScreen> {
  /// Bumped after writes and org changes so both sections reload together.
  int _revision = 0;

  /// Last team payload, mirrored for the AppBar and the teacher actions.
  AdminTeamRow? _team;
  bool _saving = false;

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

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() => _revision++);
  }

  /// Summary section loader; also keeps [_team] in sync for the AppBar.
  Future<AdminTeamRow?> _loadTeam() async {
    final team = await AdminRepositoryScope.of(context).team(widget.teamId);
    if (mounted) setState(() => _team = team);
    return team;
  }

  bool get _canEdit => canEditModule(context, 'teams');

  Future<void> _editTeacher() async {
    if (_saving || _team == null || !_canEdit) return;
    final repo = AdminRepositoryScope.of(context);
    final List<TeacherCandidate> candidates;
    try {
      candidates = await repo.teacherCandidates();
    } catch (error) {
      if (!mounted) return;
      _notice('تعذّر تحميل قائمة المعلمين: $error');
      return;
    }
    if (!mounted) return;
    final result = await showTeamTeacherPicker(
      context,
      repository: repo,
      candidates: candidates,
      selected: _team!.teacherName,
    );
    if (result == null || !mounted) return;
    setState(() => _saving = true);
    try {
      if (result is String && result.isEmpty) {
        await repo.removeTeamTeacher(widget.teamId);
      } else if (result is TeacherCandidate) {
        await repo.setTeamTeacherById(widget.teamId, result.userId);
      } else {
        return;
      }
      if (!mounted) return;
      _notice(
        result is String ? 'أُزيل معلم الحلقة.' : 'تم تعيين معلم الحلقة.',
      );
      AdminRefresh.instance.teamsChanged();
      _reload();
    } catch (error) {
      if (!mounted) return;
      _notice('تعذّر تعديل معلم الحلقة: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _removeTeacher() async {
    final team = _team;
    if (_saving || team == null || team.teacherName.isEmpty || !_canEdit) {
      return;
    }
    final confirmed = await _confirm(
      title: 'إزالة معلم الحلقة',
      message:
          'ستُزال حلقة «${team.name}» من المدرس ${team.teacherName} فقط. '
          'لن يُحذف حساب المدرس ولن يُحذف طلاب الحلقة.',
      confirmLabel: 'إزالة',
    );
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      await AdminRepositoryScope.of(context).removeTeamTeacher(widget.teamId);
      if (!mounted) return;
      _notice('تمت إزالة معلم الحلقة.');
      AdminRefresh.instance.teamsChanged();
      _reload();
    } catch (error) {
      if (!mounted) return;
      _notice('تعذّر إزالة معلم الحلقة: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _manageMembers() async {
    final team = _team;
    if (team == null || !_canEdit) return;
    await showTeamManagerSheet(
      context,
      team,
      repository: AdminRepositoryScope.of(context),
    );
    if (!mounted) return;
    _reload();
  }

  Future<void> _openTeacher() async {
    final team = _team;
    if (team == null || team.teacherName.isEmpty) return;
    await context.push(
      '/admin/teachers/${Uri.encodeComponent(team.teacherName)}',
    );
    if (!mounted) return;
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final team = _team;
    final title = team?.name ?? widget.initialName ?? 'الحلقة';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (team != null && team.teacherName.isNotEmpty && _canEdit)
            IconButton(
              tooltip: 'إزالة معلم الحلقة',
              icon: Icon(
                Icons.person_remove_outlined,
                color: tokens.dangerText,
              ),
              onPressed: _saving ? null : _removeTeacher,
            ),
        ],
      ),
      body: ResponsivePage(
        maxWidth: 900,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              // Summary + teacher card share the team request; members load
              // independently so a slow roster never hides the header.
              AsyncSection<AdminTeamRow?>(
                cacheKey: 'admin-team-${widget.teamId}',
                revision: _revision,
                skeleton: const SectionSkeleton(height: 96, lines: 2),
                errorBuilder: (context, retry) => SectionError(
                  onRetry: retry,
                  message: 'تعذر تحميل بيانات الحلقة',
                ),
                load: _loadTeam,
                builder: (context, team) {
                  if (team == null) {
                    return const EmptyState(
                      title: 'الحلقة غير موجودة',
                      message: 'ربما حُذفت أو لم تعد متاحة لحسابك.',
                      icon: Icons.hub_outlined,
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _summaryCard(context, team),
                      const SizedBox(height: 16),
                      const SectionHeader(
                        icon: Icons.school_outlined,
                        title: 'معلم الحلقة',
                      ),
                      const SizedBox(height: 8),
                      _teacherCard(context, team),
                      if (_saving) ...[
                        const SizedBox(height: 12),
                        LinearProgressIndicator(color: tokens.brand),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              AsyncSection<List<AdminStudentRow>>(
                cacheKey: 'admin-team-students-${widget.teamId}',
                revision: _revision,
                delay: const Duration(milliseconds: 80),
                skeleton: const SectionSkeleton(height: 52, lines: 3),
                errorBuilder: (context, retry) => SectionError(
                  onRetry: retry,
                  message: 'تعذر تحميل طلاب الحلقة',
                ),
                load: () =>
                    AdminRepositoryScope.of(context).teamStudents(widget.teamId),
                builder: (context, members) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionHeader(
                      icon: Icons.groups_outlined,
                      title: 'الطلاب (${members.length})',
                      trailing: _canEdit
                          ? TextButton.icon(
                              onPressed: _saving || _team == null
                                  ? null
                                  : _manageMembers,
                              icon: const Icon(
                                Icons.manage_accounts_outlined,
                                size: 18,
                              ),
                              label: const Text('إدارة الطلاب'),
                            )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    if (members.isEmpty)
                      const EmptyState(
                        title: 'لا طلاب في الحلقة',
                        message: 'أضف طلابًا من «إدارة الطلاب».',
                        icon: Icons.person_add_alt_1_outlined,
                      )
                    else
                      for (final student in members)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _memberRow(context, student),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(BuildContext context, AdminTeamRow team) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: tokens.brandTint,
                child: Icon(Icons.hub, color: tokens.brandText),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name.isEmpty ? 'حلقة بدون اسم' : team.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      team.typeName.isEmpty ? 'حلقة' : team.typeName,
                      style: TextStyle(color: tokens.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconCount(
                icon: Icons.groups_outlined,
                value: team.studentsCount,
                tooltip: 'عدد الطلاب',
                color: tokens.infoLight,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.school_outlined, size: 18, color: tokens.accentMatn),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  team.teacherName.isEmpty
                      ? 'لا يوجد معلم معيّن لهذه الحلقة'
                      : 'المعلم: ${team.teacherName}',
                  style: TextStyle(
                    color: team.teacherName.isEmpty
                        ? tokens.textMuted
                        : tokens.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (team.teacherName.isNotEmpty)
                TextButton(
                  onPressed: _openTeacher,
                  child: const Text('ملف المعلم'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _teacherCard(BuildContext context, AdminTeamRow team) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: tokens.accentMatn.withValues(alpha: 0.15),
                child: Icon(Icons.school, color: tokens.accentMatn),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  team.teacherName.isEmpty ? 'بلا معلم' : team.teacherName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (_canEdit)
                TextButton.icon(
                  onPressed: _saving ? null : _editTeacher,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(team.teacherName.isEmpty ? 'تعيين' : 'تغيير'),
                ),
            ],
          ),
          if (team.teacherName.isNotEmpty && _canEdit) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'إزالة الحلقة من المدرس',
                icon: Icons.person_remove_outlined,
                variant: AppButtonVariant.dangerOutline,
                onPressed: _saving ? null : _removeTeacher,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _memberRow(BuildContext context, AdminStudentRow student) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      onTap: () => context.push('/admin/students/${student.id}'),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: tokens.brandTint,
            child: Text(
              student.name.isEmpty ? '؟' : student.name.characters.first,
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
                  student.name.isEmpty ? 'طالب بدون اسم' : student.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (student.barcode.isNotEmpty)
                  Text(
                    student.barcode,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: tokens.textMuted, fontSize: 12),
                  ),
              ],
            ),
          ),
          Icon(Icons.chevron_left, color: tokens.borderStructural),
        ],
      ),
    );
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: tokens.dangerText),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  void _notice(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
