import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';

/// E11 — «صلاحيات التدريس» for one account.
///
/// Shows the linked teacher identity and teams, and allows linking the account
/// as a teacher for the first time (create teacher + link user) or assigning
/// one of its teams.
class AdminUserTeachingScreen extends StatefulWidget {
  const AdminUserTeachingScreen({
    super.key,
    required this.userId,
    this.initialName,
    this.initialUsername,
    this.initialTeacherId,
  });

  /// Account id (not the teacher/student row id).
  final int userId;
  final String? initialName;
  final String? initialUsername;
  final int? initialTeacherId;

  @override
  State<AdminUserTeachingScreen> createState() =>
      _AdminUserTeachingScreenState();
}

class _AdminUserTeachingScreenState extends State<AdminUserTeachingScreen> {
  String _name = '';
  String _username = '';
  int? _teacherId;
  AdminTeacherDetail? _detail;
  bool _loading = true;
  bool _saving = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName?.trim() ?? '';
    _username = widget.initialUsername?.trim() ?? '';
    _teacherId = widget.initialTeacherId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = AdminRepositoryScope.of(context);
    try {
      AdminUserRow? row;
      if (_name.isEmpty || _teacherId == null) {
        row = await repo.user(widget.userId);
      }
      final name = _name.isNotEmpty ? _name : (row?.displayName ?? '');
      final username = _username.isNotEmpty ? _username : (row?.username ?? '');
      final teacherId = _teacherId ?? row?.teacherId;
      final detail = teacherId == null
          ? null
          : await repo.teacherDetail(teacherId);
      if (!mounted) return;
      setState(() {
        _name = name;
        _username = username;
        _teacherId = teacherId;
        _detail = detail;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  Future<void> _assignTeacher() async {
    if (_saving) return;
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
      await repo.linkTeacherToUser(widget.userId, teacherId);
      if (!mounted) return;
      _notice('تم تعيين الحساب كمدرس.');
      await _load();
    } catch (error) {
      if (!mounted) return;
      _notice('تعذر تعيين الحساب كمدرس: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _assignTeam() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final repo = AdminRepositoryScope.of(context);
      final teams = await repo.teams();
      if (!mounted) return;
      if (teams.isEmpty) {
        _notice('لا توجد حلقات متاحة للإسناد.');
        return;
      }
      final teamId = await showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('إسناد لحلقة'),
          content: SizedBox(
            width: 360,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                return ListTile(
                  title: Text(team.name),
                  subtitle: team.typeName.isEmpty ? null : Text(team.typeName),
                  onTap: () => Navigator.of(context).pop(team.id),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      );
      if (teamId == null || !mounted) return;
      await repo.setTeamTeacherById(teamId, widget.userId);
      if (!mounted) return;
      _notice('تم إسناد الحلقة.');
      await _load();
    } catch (error) {
      if (!mounted) return;
      _notice('تعذر إسناد الحلقة: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Scaffold(
      appBar: AppBar(title: const Text('صلاحيات التدريس')),
      body: ResponsivePage(
        maxWidth: 720,
        child: _loading
            ? const AppLoadingView()
            : _error != null
            ? AppErrorView(error: _error, onRetry: _load)
            : ListView(
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
            onPressed: _saving ? null : _assignTeacher,
          ),
        ],
      ),
    );
  }

  Widget _teacherCard(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final teams = _detail?.teams ?? const <AdminTeamRef>[];
    final teacherName = _detail?.name.trim() ?? '';
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
                      teacherName.isEmpty ? 'ملف المعلم مرتبط' : teacherName,
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
                  onAction: _saving ? null : _assignTeam,
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
                onPressed: _saving ? null : _assignTeam,
                icon: const Icon(Icons.add_home_outlined, size: 18),
                label: const Text('إسناد لحلقة'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final team in teams)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                child: Row(
                  children: [
                    Icon(Icons.hub_outlined, color: tokens.accentMatn),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        team.name.isEmpty ? 'حلقة بدون اسم' : team.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
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
