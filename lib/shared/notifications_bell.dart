import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/presentation/admin_shell.dart';
import '../features/auth/presentation/cubits/auth_cubit.dart';
import '../features/auth/presentation/cubits/auth_state.dart';
import '../features/student/presentation/student_shell.dart';

/// Bell + unread badge shown in the shell top bar. In admin mode it counts
/// aggregated mosque-wide notifications and opens the admin feed.
class NotificationsBell extends StatefulWidget {
  const NotificationsBell({super.key, this.adminMode = false});

  final bool adminMode;

  @override
  State<NotificationsBell> createState() => _NotificationsBellState();
}

class _NotificationsBellState extends State<NotificationsBell> {
  int _unread = 0;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded && _canUse()) _loadUnread();
  }

  bool _canUse() {
    if (!widget.adminMode) return true;
    try {
      final auth = context.read<AuthCubit>().state;
      if (auth is AuthAuthenticated) {
        final profile = auth.profile;
        return profile.isAdmin ||
            profile.specialAbilities.contains('auditView');
      }
    } catch (_) {}
    return true;
  }

  Future<void> _loadUnread() async {
    if (!_canUse()) {
      if (mounted) {
        setState(() {
          _unread = 0;
          _loaded = true;
        });
      }
      return;
    }
    final adminRepo = AdminRepositoryScope.of(context);
    final studentRepo = StudentRepositoryScope.of(context);
    final count = widget.adminMode
        ? await adminRepo.unreadAdminNotifications()
        : await studentRepo.unreadNotifications();
    if (mounted) {
      setState(() {
        _unread = count;
        _loaded = true;
      });
    }
  }

  Future<void> _open() async {
    await context.push(
      widget.adminMode ? '/admin/notifications' : '/my-progress/notifications',
    );
    _loaded = false;
    if (!mounted) return;
    await _loadUnread();
  }

  @override
  Widget build(BuildContext context) {
    // Keep the icon's footprint even when the account may not see admin
    // notifications, so the mode label does not stick to the screen edge.
    if (!_canUse()) return const SizedBox(width: 48, height: 48);
    return IconButton(
      tooltip: 'الإشعارات',
      onPressed: _open,
      icon: Badge(
        isLabelVisible: _unread > 0,
        label: Text('$_unread'),
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}
