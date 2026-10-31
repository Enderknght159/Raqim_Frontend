import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/date_grouped_list.dart';
import '../../../../core/widgets/icon_tile.dart';
import '../../../../core/widgets/list_row.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../data/student_repository.dart';
import '../../domain/models/student_models.dart';
import '../student_shell.dart';

/// Notifications feed: every record added for the student, sorted
/// chronologically (newest first) and grouped by day.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final repo = StudentRepositoryScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات')),
      body: AsyncView<List<StudentNotification>>(
        future: _load(repo),
        cacheKey: 'student-notifications',
        builder: (context, items) {
          if (items.isEmpty) {
            return const Center(child: Text('لا إشعارات بعد'));
          }
          return ResponsivePage(
            maxWidth: 800,
            child: DateGroupedList<StudentNotification>(
              items: items,
              dateOf: (n) => n.when,
              itemBuilder: (context, n) => _NotificationRow(notification: n),
            ),
          );
        },
      ),
    );
  }

  // Marks notifications as read after loading them.
  Future<List<StudentNotification>> _load(StudentRepository repo) async {
    final items = await repo.notifications();
    await repo.markNotifRead();
    return items;
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.notification});

  final StudentNotification notification;

  (IconData, Color) _style(AppTokens tokens) => switch (notification.kind) {
    NotificationKind.attendance => (Icons.schedule, tokens.infoLight),
    NotificationKind.memorization => (Icons.menu_book, tokens.brand),
    NotificationKind.transaction => (Icons.payments_outlined, tokens.reward),
    NotificationKind.exam => (
      Icons.assignment_turned_in_outlined,
      tokens.accentMatn,
    ),
    NotificationKind.certificate => (Icons.school_outlined, tokens.reward),
    NotificationKind.matn => (Icons.menu_book, tokens.accentMatn),
    NotificationKind.team => (Icons.groups_outlined, tokens.infoLight),
    NotificationKind.notice => (Icons.campaign_outlined, tokens.info),
  };

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final (icon, color) = _style(tokens);
    return ListRow(
      leading: IconTile(icon: icon, color: color, size: 40, iconSize: 20),
      title: notification.title,
      subtitle: notification.body,
      trailing: Text(
        formatTime(notification.when),
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
      ),
    );
  }
}
