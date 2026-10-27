import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/presentation/admin_shell.dart';
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
    if (!_loaded) _loadUnread();
  }

  Future<void> _loadUnread() async {
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
