import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/section_loader.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../shared/permissions.dart';
import '../../data/admin_refresh.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';
import '../widgets/course_metrics_panel.dart';

/// Unified teacher page (merges the old teacher profile and teaching
/// permissions pages): account/teacher identity, his teams, assignment,
/// removal, and navigation to each team page.
class AdminTeacherManagementScreen extends StatefulWidget {
  const AdminTeacherManagementScreen({
    super.key,
    this.userId,
    this.teacherName,
    this.initialTeacherId,
    this.initialName,
    this.initialUsername,
  }) : assert(
         userId != null || teacherName != null || initialTeacherId != null,
         'A userId, teacher name or teacher id is required',
       );

  /// Account id (not the teacher row id).
  final int? userId;

  /// Teacher name for the legacy `/admin/teachers/:name` route.
  final String? teacherName;

  final int? initialTeacherId;
  final String? initialName;
  final String? initialUsername;

  @override
  State<AdminTeacherManagementScreen> createState() =>
      _AdminTeacherManagementScreenState();
}

typedef _TeacherIdentity = ({
  AdminUserRow? row,
  AdminTeacherDetail? detail,
  int? teacherId,
  String name,
  String username,
});

typedef _TeacherTeams = ({
  List<AdminTeamRow> mine,
  List<AdminTeamRow> others,
});

class _AdminTeacherManagementScreenState
    extends State<AdminTeacherManagementScreen> {
  /// Bumped after writes and org changes so both sections reload.
  int _revision = 0;
  String _name = '';
  String _username = '';
  int? _userId;
  int? _teacherId;
  AdminTeacherDetail? _detail;

  /// One identity request shared by the profile and teams sections.
  Future<_TeacherIdentity>? _identityFuture;
  int _identityToken = 0;
  bool _saving = false;
  int? _busyTeamId;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName?.trim() ?? widget.teacherName?.trim() ?? '';
    _username = widget.initialUsername?.trim() ?? '';
    _userId = widget.userId;
    _teacherId = widget.initialTeacherId;
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
    setState(() {
      _identityFuture = null;
      _identityToken++;
      _revision++;
    });
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() {
      _identityFuture = null;
      _identityToken++;
      _revision++;
    });
  }

  Future<_TeacherIdentity> _identity() {
    final existing = _identityFuture;
    if (existing != null) return existing;
    final future = _loadIdentity();
    _identityFuture = future;
    // A failed identity must not stay memoized, or a section retry would
    // replay the same failure.
    future.then<void>(
      (_) {},
      onError: (Object _) {
        if (identical(_identityFuture, future)) _identityFuture = null;
      },
    );
    return future;
  }

  Future<_TeacherIdentity> _loadIdentity() async {
    final token = _identityToken;
    final repo = AdminRepositoryScope.of(context);
    AdminUserRow? row;
    var teacherId = _teacherId;
    var name = _name;
    var username = _username;
    var userId = _userId;
    if (userId != null) {
      row = await repo.user(userId);
    } else if (teacherId == null && name.isNotEmpty) {
      final teachers = await repo.teachers();
      teacherId = teachers.where((t) => t.name == name).firstOrNull?.id;
    }

    final resolvedTeacherId = teacherId ?? row?.teacherId;
    final detail = resolvedTeacherId == null || resolvedTeacherId == 0
        ? null
        : await repo.teacherDetail(resolvedTeacherId);
    var resolvedUserId = userId ?? row?.id ?? detail?.userId;
    if (row?.teacherId != null) resolvedUserId = row!.id;

    final identity = (
      row: row,
      detail: detail,
      teacherId: detail?.id ?? resolvedTeacherId,
      name: _pickName(row, detail),
      username: row?.username.trim() ?? username,
    );
    if (mounted && token == _identityToken) {
      setState(() {
        _name = identity.name;
        _username = identity.username;
        _userId = resolvedUserId;
        // The local demo repository has no teacher detail endpoint; keep the
        // id resolved from the teachers list so the profile still renders.
        _teacherId = identity.teacherId;
        _detail = detail;
      });
    }
    return identity;
  }

  String _pickName(AdminUserRow? row, AdminTeacherDetail? detail) {
    final candidates = [
      row?.displayName ?? '',
      detail?.name ?? '',
      _name,
      _username,
    ];
    for (final value in candidates) {
      if (value.trim().isNotEmpty) return value.trim();
    }
    return 'حساب بدون اسم';
  }

  List<AdminTeamRow> _mineFor(
    _TeacherIdentity identity,
    List<AdminTeamRow> allTeams,
  ) {
    final byId = {for (final team in allTeams) team.id: team};
    final refs = identity.detail?.teams ?? const <AdminTeamRef>[];
    final result = <AdminTeamRow>[];
    final seen = <int>{};
    for (final ref in refs) {
      final full = byId[ref.id];
      result.add(
        AdminTeamRow(
          id: ref.id,
          name: ref.name.isEmpty ? (full?.name ?? 'حلقة بدون اسم') : ref.name,
          typeName: full?.typeName ?? '',
          teacherName: identity.name,
          studentsCount: full?.studentsCount ?? 0,
          teacherId: identity.teacherId,
        ),
      );
      seen.add(ref.id);
    }
    for (final team in allTeams) {
      if (seen.contains(team.id)) continue;
      final matchesTeacherId =
          identity.teacherId != null &&
          identity.teacherId != 0 &&
          team.teacherId == identity.teacherId;
      final matchesName =
          identity.detail == null &&
          identity.name.isNotEmpty &&
          team.teacherName == identity.name;
      if (matchesTeacherId || matchesName) {
        result.add(team);
        seen.add(team.id);
      }
    }
    return result;
  }

  /// Teams section loader. Waits for the shared identity so the teacher id is
  /// resolved before pairing him with his teams.
  Future<_TeacherTeams?> _loadTeams() async {
    final repo = AdminRepositoryScope.of(context);
    final identity = await _identity();
    if (identity.teacherId == null) return null;
    final allTeams = await repo.teams();
    final mine = _mineFor(identity, allTeams);
    final mineIds = mine.map((team) => team.id).toSet();
    return (
      mine: mine,
      others: allTeams.where((team) => !mineIds.contains(team.id)).toList(),
    );
  }

  bool get _canEditTeams => canEditModule(context, 'teams');
  bool get _canManageAccounts => hasAnyAbility(context, ['userManagement']);
  bool get _canRemoveTeacher =>
      _canManageAccounts && canDeleteModule(context, 'teams');

  Future<void> _assignTeacher() async {
    if (_saving || !_canManageAccounts) return;
    final name = await showDialog<String>(
      context: context,
      builder: (context) =>
          _TeacherNameDialog(initialName: _name.isNotEmpty ? _name : _username),
    );
    if (name == null || name.isEmpty || !mounted) return;

    setState(() => _saving = true);
    try {
      final repo = AdminRepositoryScope.of(context);
      final teacherId = await repo.createTeacher(name);
      await repo.linkTeacherToUser(_userId!, teacherId);
      if (!mounted) return;
      _notice('تم تعيين الحساب كمدرس.');
      AdminRefresh.instance.teamsChanged();
      _reload();
    } catch (error) {
      if (!mounted) return;
      _notice('تعذر تعيين الحساب كمدرس: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _removeTeacher() async {
    final teacherId = _teacherId;
    if (teacherId == null || teacherId <= 0 || _saving || !_canRemoveTeacher) {
      return;
    }
    final confirmed = await _confirm(
      title: 'إزالة حساب المدرس',
      message:
          'سيُحذف ملف المعلم حذفًا ناعمًا، ويُفك ربطه بالحساب وبكل حلقاته. '
          'لن تُحذف حلقاته أو طلابه.',
      confirmLabel: 'إزالة',
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      await AdminRepositoryScope.of(context).deleteTeacher(teacherId);
      if (!mounted) return;
      setState(() {
        _teacherId = null;
        _detail = null;
      });
      _notice('تمت إزالة حساب المدرس.');
      AdminRefresh.instance.teamsChanged();
      _reload();
    } catch (error) {
      if (!mounted) return;
      _notice('تعذر إزالة حساب المدرس: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _assignTeam(List<AdminTeamRow> others) async {
    if (_saving || !_canEditTeams) return;
    final targetUserId = _userId ?? _detail?.userId;
    if (targetUserId == null) {
      _notice('لا يوجد حساب مستخدم مرتبط بهذا المعلم. اربط الحساب أولًا.');
      return;
    }
    if (others.isEmpty) {
      _notice('كل الحلقات مسندة بالفعل، أو لا توجد حلقات متاحة.');
      return;
    }
    final teamId = await showDialog<int>(
      context: context,
      builder: (context) => _TeamPickerDialog(teams: others, teacherName: _name),
    );
    if (teamId == null || !mounted) return;
    setState(() {
      _saving = true;
      _busyTeamId = teamId;
    });
    try {
      await AdminRepositoryScope.of(
        context,
      ).setTeamTeacherById(teamId, targetUserId);
      if (!mounted) return;
      _notice('تم إسناد الحلقة.');
      AdminRefresh.instance.teamsChanged();
      _reload();
    } catch (error) {
      if (!mounted) return;
      _notice('تعذر إسناد الحلقة: $error');
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
          _busyTeamId = null;
        });
      }
    }
  }

  Future<void> _removeTeam(AdminTeamRow team) async {
    if (_saving || _busyTeamId != null || !_canEditTeams) return;
    final confirmed = await _confirm(
      title: 'إزالة الحلقة',
      message:
          'ستُزال حلقة «${team.name}» من هذا المدرس فقط. لن تُحذف الحلقة '
          'ولن يُحذف طلابها.',
      confirmLabel: 'إزالة',
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _saving = true;
      _busyTeamId = team.id;
    });
    try {
      await AdminRepositoryScope.of(context).removeTeamTeacher(team.id);
      if (!mounted) return;
      _notice('تمت إزالة الحلقة من المدرس.');
      AdminRefresh.instance.teamsChanged();
      _reload();
    } catch (error) {
      if (!mounted) return;
      _notice('تعذر إزالة الحلقة: $error');
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
          _busyTeamId = null;
        });
      }
    }
  }

  Future<void> _openTeam(AdminTeamRow team) async {
    await context.push('/admin/teams/${team.id}');
    if (!mounted) return;
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final title = _name.isEmpty ? 'صلاحيات التدريس' : _name;
    final identityKey =
        widget.userId?.toString() ??
        widget.initialTeacherId?.toString() ??
        widget.teacherName ??
        widget.initialName ??
        'unknown';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if ((_teacherId ?? 0) > 0 && _canRemoveTeacher)
            IconButton(
              tooltip: 'إزالة حساب المدرس',
              icon: Icon(
                Icons.person_remove_outlined,
                color: tokens.dangerText,
              ),
              onPressed: _saving ? null : _removeTeacher,
            ),
        ],
      ),
      body: ResponsivePage(
        maxWidth: 760,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              AsyncSection<_TeacherIdentity>(
                cacheKey: 'admin-teacher-$identityKey-identity',
                revision: _revision,
                skeleton: const SectionSkeleton(height: 64, lines: 2),
                errorBuilder: (context, retry) => SectionError(
                  onRetry: retry,
                  message: 'تعذر تحميل بيانات المعلم',
                ),
                load: _identity,
                builder: (context, identity) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _accountCard(context, identity),
                    const SizedBox(height: 16),
                    const SectionHeader(
                      icon: Icons.school_outlined,
                      title: 'صلاحيات التدريس',
                    ),
                    const SizedBox(height: 8),
                    if (identity.teacherId == null)
                      _notTeacherCard(context)
                    else ...[
                      _teacherHeaderCard(context, identity),
                      if ((identity.teacherId ?? 0) > 0 &&
                          _canRemoveTeacher) ...[
                        const SizedBox(height: 12),
                        AppButton(
                          label: 'إزالة حساب المدرس',
                          icon: Icons.person_remove_outlined,
                          variant: AppButtonVariant.dangerOutline,
                          loading: _saving,
                          onPressed: _saving ? null : _removeTeacher,
                        ),
                      ],
                    ],
                    if (_saving) ...[
                      const SizedBox(height: 12),
                      LinearProgressIndicator(color: tokens.brand),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Depends on the identity above; waits for the same shared
              // request instead of firing a second one.
              AsyncSection<_TeacherTeams?>(
                cacheKey: 'admin-teacher-$identityKey-teams',
                revision: _revision,
                delay: const Duration(milliseconds: 80),
                skeleton: const SectionSkeleton(height: 64, lines: 2),
                errorBuilder: (context, retry) => SectionError(
                  onRetry: retry,
                  message: 'تعذر تحميل حلقات المعلم',
                ),
                load: _loadTeams,
                builder: (context, data) => data == null
                    ? const SizedBox.shrink()
                    : _teamsCard(context, data),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountCard(BuildContext context, _TeacherIdentity identity) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: tokens.accentMatn.withValues(alpha: 0.15),
            child: Icon(Icons.person_outline, color: tokens.accentMatn),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  identity.name.isEmpty ? 'حساب بدون اسم' : identity.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (identity.username.isNotEmpty)
                  Text(
                    '@${identity.username}',
                    style: TextStyle(color: tokens.textMuted, fontSize: 13),
                  ),
                if (identity.username.isEmpty && identity.teacherId != null)
                  Text(
                    identity.row == null
                        ? 'ملف معلم غير مرتبط بحساب مستخدم'
                        : 'حساب مرتبط بملف معلم',
                    style: TextStyle(color: tokens.textMuted, fontSize: 13),
                  ),
              ],
            ),
          ),
          StatusBadge(
            label: identity.teacherId == null ? 'غير مدرّس' : 'مدرّس',
            color: identity.teacherId == null
                ? tokens.textMuted
                : tokens.accentMatn,
          ),
        ],
      ),
    );
  }

  Widget _notTeacherCard(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      child: Column(
        children: [
          Icon(Icons.school_outlined, size: 44, color: tokens.textMuted),
          const SizedBox(height: 10),
          Text(
            'هذا الحساب ليس مدرّسًا بعد',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'أنشئ ملف معلم واربطه بهذا الحساب لإتاحة إدارة حلقاته.',
            style: TextStyle(color: tokens.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'تعيين كمدرس',
            icon: Icons.person_add_alt_1_outlined,
            loading: _saving,
            onPressed: _saving || _userId == null || !_canManageAccounts
                ? null
                : _assignTeacher,
          ),
        ],
      ),
    );
  }

  Widget _teacherHeaderCard(BuildContext context, _TeacherIdentity identity) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.badge_outlined, color: tokens.accentMatn),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  identity.detail?.name.trim().isNotEmpty == true
                      ? identity.detail!.name
                      : (identity.name.isEmpty
                            ? 'ملف المعلم مرتبط'
                            : identity.name),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'هذا الحساب مرتبط بملف معلم ويمكنه إدارة الحلقات المسندة إليه.',
            style: TextStyle(color: tokens.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _teamsCard(BuildContext context, _TeacherTeams data) {
    if (data.mine.isEmpty) {
      return AppCard(
        child: Column(
          children: [
            EmptyState(
              title: 'لا حلقات مرتبطة',
              message: 'أسنِد الحساب لحلقة ليظهر هنا.',
              icon: Icons.hub_outlined,
              actionLabel: 'إسناد لحلقة',
              onAction: _saving || !_canEditTeams
                  ? null
                  : () => _assignTeam(data.others),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'حلقاته',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton.icon(
              onPressed: _saving || !_canEditTeams
                  ? null
                  : () => _assignTeam(data.others),
              icon: const Icon(Icons.add_home_outlined, size: 18),
              label: const Text('إسناد لحلقة'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        for (final team in data.mine)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _teamRow(context, team),
          ),
      ],
    );
  }

  Widget _teamRow(BuildContext context, AdminTeamRow team) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final busy = _busyTeamId == team.id;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      onTap: busy ? null : () => _openTeam(team),
      child: Row(
        children: [
          Icon(Icons.hub_outlined, color: tokens.accentMatn),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name.isEmpty ? 'حلقة بدون اسم' : team.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (team.typeName.isNotEmpty)
                      Text(
                        team.typeName,
                        style: TextStyle(color: tokens.textMuted, fontSize: 12),
                      ),
                    IconCount(
                      icon: Icons.groups_outlined,
                      value: team.studentsCount,
                      tooltip: 'عدد الطلاب',
                      color: tokens.infoLight,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (busy)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else ...[
            if (_canEditTeams)
              TextButton(
                onPressed: _saving ? null : () => _removeTeam(team),
                style: TextButton.styleFrom(foregroundColor: tokens.dangerText),
                child: const Text('إزالة'),
              ),
            Icon(Icons.chevron_left, color: tokens.borderStructural),
          ],
        ],
      ),
    );
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
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
            style: TextButton.styleFrom(
              foregroundColor: destructive ? tokens.dangerText : null,
            ),
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

class _TeacherNameDialog extends StatefulWidget {
  const _TeacherNameDialog({required this.initialName});

  final String initialName;

  @override
  State<_TeacherNameDialog> createState() => _TeacherNameDialogState();
}

class _TeacherNameDialogState extends State<_TeacherNameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialName,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تعيين كمدرس'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'اسم المعلم'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('تعيين'),
        ),
      ],
    );
  }
}

class _TeamPickerDialog extends StatefulWidget {
  const _TeamPickerDialog({required this.teams, required this.teacherName});

  final List<AdminTeamRow> teams;
  final String teacherName;

  @override
  State<_TeamPickerDialog> createState() => _TeamPickerDialogState();
}

class _TeamPickerDialogState extends State<_TeamPickerDialog> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final query = _search.text.trim().toLowerCase();
    final teams = widget.teams.where((team) {
      if (query.isEmpty) return true;
      return team.name.toLowerCase().contains(query) ||
          team.typeName.toLowerCase().contains(query) ||
          team.teacherName.toLowerCase().contains(query);
    }).toList();
    return AlertDialog(
      title: const Text('إسناد لحلقة'),
      content: SizedBox(
        width: 380,
        height: 420,
        child: Column(
          children: [
            TextField(
              controller: _search,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'ابحث باسم الحلقة أو النوع',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: teams.isEmpty
                  ? const Center(child: Text('لا نتائج'))
                  : ListView.builder(
                      itemCount: teams.length,
                      itemBuilder: (context, index) {
                        final team = teams[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.hub_outlined,
                            color: tokens.accentMatn,
                          ),
                          title: Text(team.name),
                          subtitle: Wrap(
                            spacing: 8,
                            runSpacing: 2,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (team.typeName.isNotEmpty) Text(team.typeName),
                              if (team.teacherName.isNotEmpty)
                                Text('المعلم: ${team.teacherName}'),
                              IconCount(
                                icon: Icons.groups_outlined,
                                value: team.studentsCount,
                                tooltip: 'عدد الطلاب',
                                color: tokens.infoLight,
                              ),
                            ],
                          ),
                          onTap: () => Navigator.of(context).pop(team.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
      ],
    );
  }
}
