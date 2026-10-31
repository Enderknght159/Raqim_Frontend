import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../shared/permissions.dart';
import '../../data/admin_refresh.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';

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

class _AdminTeacherManagementScreenState
    extends State<AdminTeacherManagementScreen> {
  String _name = '';
  String _username = '';
  int? _userId;
  int? _teacherId;
  AdminTeacherDetail? _detail;
  List<AdminTeamRow> _allTeams = const [];
  bool _loading = true;
  bool _saving = false;
  int? _busyTeamId;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName?.trim() ?? widget.teacherName?.trim() ?? '';
    _username = widget.initialUsername?.trim() ?? '';
    _userId = widget.userId;
    _teacherId = widget.initialTeacherId;
    AdminRefresh.instance.addListener(_onOrgChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    AdminRefresh.instance.removeListener(_onOrgChanged);
    super.dispose();
  }

  void _onOrgChanged() {
    if (!mounted) return;
    _load(silent: true);
  }

  Future<void> _load({bool silent = false}) async {
    if (!mounted) return;
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    final repo = AdminRepositoryScope.of(context);
    try {
      AdminUserRow? row;
      if (_userId != null) {
        row = await repo.user(_userId!);
      } else if (_teacherId == null && _name.isNotEmpty) {
        final teachers = await repo.teachers();
        final match = teachers.where((t) => t.name == _name).firstOrNull;
        _teacherId = match?.id;
      }

      final teacherId = _teacherId ?? row?.teacherId;
      final detail = teacherId == null || teacherId == 0
          ? null
          : await repo.teacherDetail(teacherId);
      final teams = await repo.teams();
      if (!mounted) return;
      setState(() {
        _name = _pickName(row, detail);
        _username = row?.username.trim() ?? _username;
        _userId = _userId ?? row?.id ?? detail?.userId;
        if (row?.teacherId != null) _userId = row!.id;
        // The local demo repository has no teacher detail endpoint; keep the
        // id resolved from the teachers list so the profile still renders.
        _teacherId = detail?.id ?? teacherId;
        _detail = detail;
        _allTeams = teams;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error;
      });
    }
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

  List<AdminTeamRow> get _mine {
    final byId = {for (final team in _allTeams) team.id: team};
    final refs = _detail?.teams ?? const <AdminTeamRef>[];
    final result = <AdminTeamRow>[];
    final seen = <int>{};
    for (final ref in refs) {
      final full = byId[ref.id];
      result.add(
        AdminTeamRow(
          id: ref.id,
          name: ref.name.isEmpty ? (full?.name ?? 'حلقة بدون اسم') : ref.name,
          typeName: full?.typeName ?? '',
          teacherName: _name,
          studentsCount: full?.studentsCount ?? 0,
          teacherId: _teacherId,
        ),
      );
      seen.add(ref.id);
    }
    for (final team in _allTeams) {
      if (seen.contains(team.id)) continue;
      final matchesTeacherId =
          _teacherId != null && _teacherId != 0 && team.teacherId == _teacherId;
      final matchesName =
          _detail == null && _name.isNotEmpty && team.teacherName == _name;
      if (matchesTeacherId || matchesName) {
        result.add(team);
        seen.add(team.id);
      }
    }
    return result;
  }

  List<AdminTeamRow> get _others {
    final mineIds = _mine.map((team) => team.id).toSet();
    return _allTeams.where((team) => !mineIds.contains(team.id)).toList();
  }

  bool get _canEditTeams => canEditModule(context, 'teams');
  bool get _canManageAccounts => hasAnyAbility(context, ['userManagement']);
  bool get _canRemoveTeacher => _canManageAccounts && canDeleteModule(context, 'teams');

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
      await _load(silent: true);
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
      await _load(silent: true);
    } catch (error) {
      if (!mounted) return;
      _notice('تعذر إزالة حساب المدرس: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _assignTeam() async {
    if (_saving || !_canEditTeams) return;
    final targetUserId = _userId ?? _detail?.userId;
    if (targetUserId == null) {
      _notice('لا يوجد حساب مستخدم مرتبط بهذا المعلم. اربط الحساب أولًا.');
      return;
    }
    if (_others.isEmpty) {
      _notice('كل الحلقات مسندة بالفعل، أو لا توجد حلقات متاحة.');
      return;
    }
    final teamId = await showDialog<int>(
      context: context,
      builder: (context) => _TeamPickerDialog(
        teams: _others,
        teacherName: _name,
      ),
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
      await _load(silent: true);
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
      await _load(silent: true);
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
    await _load(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final title = _name.isEmpty ? 'صلاحيات التدريس' : _name;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if ((_teacherId ?? 0) > 0 && _canRemoveTeacher)
            IconButton(
              tooltip: 'إزالة حساب المدرس',
              icon: Icon(Icons.person_remove_outlined, color: tokens.dangerText),
              onPressed: _saving ? null : _removeTeacher,
            ),
        ],
      ),
      body: ResponsivePage(
        maxWidth: 760,
        child: _loading && _detail == null && _allTeams.isEmpty
            ? const AppLoadingView()
            : _error != null && _detail == null && _allTeams.isEmpty
            ? AppErrorView(error: _error, onRetry: _load)
            : RefreshIndicator(
                onRefresh: () => _load(silent: true),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _accountCard(context),
                    const SizedBox(height: 16),
                    const SectionHeader(
                      icon: Icons.school_outlined,
                      title: 'صلاحيات التدريس',
                    ),
                    const SizedBox(height: 8),
                    if (_teacherId == null)
                      _notTeacherCard(context)
                    else
                      _teacherCard(context),
                    if (_saving) ...[
                      const SizedBox(height: 12),
                      LinearProgressIndicator(color: tokens.brand),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _accountCard(BuildContext context) {
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
                  _name.isEmpty ? 'حساب بدون اسم' : _name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (_username.isNotEmpty)
                  Text(
                    '@$_username',
                    style: TextStyle(color: tokens.textMuted, fontSize: 13),
                  ),
                if (_username.isEmpty && _teacherId != null)
                  Text(
                    _userId == null
                        ? 'ملف معلم غير مرتبط بحساب مستخدم'
                        : 'حساب مرتبط بملف معلم',
                    style: TextStyle(color: tokens.textMuted, fontSize: 13),
                  ),
              ],
            ),
          ),
          StatusBadge(
            label: _teacherId == null ? 'غير مدرّس' : 'مدرّس',
            color: _teacherId == null ? tokens.textMuted : tokens.accentMatn,
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

  Widget _teacherCard(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final teams = _mine;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.badge_outlined, color: tokens.accentMatn),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _detail?.name.trim().isNotEmpty == true
                          ? _detail!.name
                          : (_name.isEmpty ? 'ملف المعلم مرتبط' : _name),
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
        ),
        const SizedBox(height: 12),
        if (teams.isEmpty)
          AppCard(
            child: Column(
              children: [
                EmptyState(
                  title: 'لا حلقات مرتبطة',
                  message: 'أسنِد الحساب لحلقة ليظهر هنا.',
                  icon: Icons.hub_outlined,
                  actionLabel: 'إسناد لحلقة',
                  onAction: _saving || !_canEditTeams ? null : _assignTeam,
                ),
              ],
            ),
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'حلقاته',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton.icon(
                onPressed: _saving || !_canEditTeams ? null : _assignTeam,
                icon: const Icon(Icons.add_home_outlined, size: 18),
                label: const Text('إسناد لحلقة'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final team in teams)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _teamRow(context, team),
            ),
        ],
        if ((_teacherId ?? 0) > 0 && _canRemoveTeacher) ...[
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
    );
  }

  Widget _teamRow(BuildContext context, AdminTeamRow team) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final busy = _busyTeamId == team.id;
    final subtitle = [
      if (team.typeName.isNotEmpty) team.typeName,
      '${team.studentsCount} طالب',
    ].join(' · ');
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
                Text(
                  subtitle,
                  style: TextStyle(color: tokens.textMuted, fontSize: 12),
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
                          subtitle: Text(
                            [
                              if (team.typeName.isNotEmpty) team.typeName,
                              if (team.teacherName.isNotEmpty)
                                'المعلم: ${team.teacherName}',
                              '${team.studentsCount} طالب',
                            ].join(' · '),
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
