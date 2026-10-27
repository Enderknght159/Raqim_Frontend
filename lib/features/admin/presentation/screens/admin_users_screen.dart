import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/responsive_grid.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';
import '../widgets/permission_editor.dart';
import 'admin_user_detail_screen.dart';

/// E11 — Users + permissions. Search + filter; the «مشرف» state shows on the
/// outer tile (shield icon) and inside the editor; teacher is an indicator
/// derived from the backend with a shortcut to their teams; the admin covers
/// all special abilities.
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _search = TextEditingController();
  late Future<_Data> _future;
  String _filter = 'الكل';

  /// Session-local permissions (the trial has no server persistence).
  final Map<String, AdminPermissionResult> _permissions = {};

  static const _filterChips = ['الكل', 'مشرف', 'طالب', 'مدرس'];

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<_Data> _load() async {
    final repo = AdminRepositoryScope.of(context);
    return _Data(
      students: await repo.students(),
      teachers: await repo.teachers(),
      teams: await repo.teams(),
    );
  }

  AdminPermissionResult _permissionsFor(String key, AdminUserKind kind) {
    final existing = _permissions[key];
    if (existing != null) return existing;
    final result = switch (kind) {
      AdminUserKind.admin => const AdminPermissionResult(
        isAdmin: true,
        granted: {
          'students',
          'attendance',
          'memorization',
          'recitation',
          'matn',
          'points',
          'exams',
          'distributions',
          'teams',
          'courses',
          'reports',
          'imports',
        },
        abilities: {
          'messagesExport',
          'barcodeExport',
          'phoneSearch',
          'dataChangeApproval',
          'auditView',
          'userManagement',
          'permissionManagement',
        },
      ),
      AdminUserKind.teacher => const AdminPermissionResult(
        isAdmin: false,
        granted: {'attendance', 'memorization', 'recitation', 'matn'},
        abilities: {},
        isTeacher: true,
      ),
      AdminUserKind.student => const AdminPermissionResult(
        isAdmin: false,
        granted: {'students', 'attendance', 'points', 'courses'},
        abilities: {},
      ),
    };
    _permissions[key] = result;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المستخدمون والصلاحيات')),
      body: AsyncView<_Data>(
        future: _future,
        builder: (context, data) {
          final teamNamesByTeacher = {
            for (final t in data.teachers)
              t.name: data.teams
                  .where((team) => team.teacherName == t.name)
                  .map((team) => team.name)
                  .toList(),
          };
          final q = _search.text.trim();
          final visibleStudents = q.isEmpty
              ? data.students
              : data.students.where((s) => studentMatchesQuery(s, q)).toList();
          final visibleTeachers = q.isEmpty
              ? data.teachers
              : data.teachers.where((t) => t.name.contains(q)).toList();

          bool matchesFilter(String key, AdminUserKind kind) {
            if (_filter == 'الكل') return true;
            final p = _permissionsFor(key, kind);
            return switch (_filter) {
              'مشرف' => p.isSupervisor,
              'مدرس' => kind == AdminUserKind.teacher,
              'طالب' => kind == AdminUserKind.student,
              _ => true,
            };
          }

          final showAdmin = matchesFilter('admin', AdminUserKind.admin);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'بحث عن مستخدم',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  for (final f in _filterChips)
                    ChoiceChip(
                      label: Text(f),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ResponsiveGrid(
                minItemWidth: 360,
                maxColumns: 3,
                children: [
                  if (showAdmin)
                    _userTile(
                      context,
                      key: 'admin',
                      name: 'مدير المسجد',
                      subtitle: 'admin',
                      kind: AdminUserKind.admin,
                      username: 'admin',
                    ),
                  for (final t in visibleTeachers)
                    if (matchesFilter('t-${t.name}', AdminUserKind.teacher))
                      _userTile(
                        context,
                        key: 't-${t.name}',
                        name: t.name,
                        subtitle: (teamNamesByTeacher[t.name] ?? []).isEmpty
                            ? 'لا حلقات'
                            : (teamNamesByTeacher[t.name]!).join(' · '),
                        kind: AdminUserKind.teacher,
                        teams: teamNamesByTeacher[t.name] ?? const [],
                      ),
                  for (final s in visibleStudents)
                    if (matchesFilter('s-${s.id}', AdminUserKind.student))
                      _userTile(
                        context,
                        key: 's-${s.id}',
                        name: s.name,
                        subtitle: 'حساب طالب · ${s.barcode}',
                        kind: AdminUserKind.student,
                        studentId: s.id,
                      ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _userTile(
    BuildContext context, {
    required String key,
    required String name,
    required String subtitle,
    required AdminUserKind kind,
    int? studentId,
    String? username,
    List<String> teams = const [],
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final permissions = _permissionsFor(key, kind);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        onTap: () => _openDetail(
          key: key,
          name: name,
          kind: kind,
          studentId: studentId,
          username: username,
          teams: teams,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: switch (kind) {
                AdminUserKind.admin => tokens.infoTint,
                AdminUserKind.teacher => tokens.accentMatn.withValues(
                  alpha: 0.15,
                ),
                AdminUserKind.student => tokens.brandTint,
              },
              child: Icon(
                switch (kind) {
                  AdminUserKind.admin => Icons.admin_panel_settings,
                  AdminUserKind.teacher => Icons.school,
                  AdminUserKind.student => Icons.person,
                },
                size: 18,
                color: switch (kind) {
                  AdminUserKind.admin => tokens.info,
                  AdminUserKind.teacher => tokens.accentMatn,
                  AdminUserKind.student => tokens.brandText,
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                  ),
                ],
              ),
            ),
            // Icon-only indicators (no crowding): shield = supervisor.
            if (permissions.isSupervisor)
              Tooltip(
                message: 'مشرف',
                child: Icon(Icons.verified_user, size: 18, color: tokens.info),
              ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_left, color: tokens.borderStructural),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetail({
    required String key,
    required String name,
    required AdminUserKind kind,
    int? studentId,
    String? username,
    List<String> teams = const [],
  }) async {
    final permissions = _permissionsFor(key, kind);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AdminUserDetailScreen(
          name: name,
          kind: kind,
          studentId: studentId,
          username: username,
          teams: teams,
          permissions: permissions,
          onPermissionsChanged: (result) {
            setState(() => _permissions[key] = result);
          },
        ),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }
}

class _Data {
  const _Data({
    required this.students,
    required this.teachers,
    required this.teams,
  });

  final List<AdminStudentRow> students;
  final List<AdminTeacherRow> teachers;
  final List<AdminTeamRow> teams;
}
