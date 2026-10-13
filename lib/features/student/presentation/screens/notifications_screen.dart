import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/icon_tile.dart';
import '../../../../core/widgets/list_row.dart';
import '../../data/student_local_repository.dart';
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
        builder: (context, items) {
          if (items.isEmpty) {
            return const Center(child: Text('لا إشعارات بعد'));
          }
          final groups = _groupByDay(items);
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: groups.length,
            itemBuilder: (context, i) =>
                _DayGroup(dayLabel: groups[i].label, items: groups[i].items),
          );
        },
      ),
    );
  }

  // Marks notifications as read after loading them.
  Future<List<StudentNotification>> _load(StudentLocalRepository repo) async {
    final items = await repo.notifications();
    await repo.markNotifRead();
    return items;
  }

  /// Groups (already sorted) by calendar day, keeping the desc order.
  List<({String label, List<StudentNotification> items})> _groupByDay(
      List<StudentNotification> items) {
    final groups = <({String label, List<StudentNotification> items})>[];
    ({String label, List<StudentNotification> items})? current;
    for (final n in items) {
      final day = DateTime(n.when.year, n.when.month, n.when.day);
      if (current == null || current.label != _dayLabel(day)) {
        groups.add((label: _dayLabel(day), items: []));
        current = groups.last;
      }
      current.items.add(n);
    }
    return groups;
  }
}

String _dayLabel(DateTime day) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'اليوم';
  if (diff == 1) return 'أمس';
  const months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];
  return '${day.day} ${months[day.month - 1]}';
}

class _DayGroup extends StatelessWidget {
  const _DayGroup({required this.dayLabel, required this.items});

  final String dayLabel;
  final List<StudentNotification> items;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: tokens.brand,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                dayLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: tokens.textPrimary,
                    ),
              ),
            ],
          ),
        ),
        for (final n in items) _NotificationRow(notification: n),
        const SizedBox(height: 4),
      ],
    );
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
            tokens.accentMatn
          ),
        NotificationKind.certificate => (Icons.school_outlined, tokens.reward),
        NotificationKind.matn => (Icons.menu_book, tokens.accentMatn),
        NotificationKind.team => (Icons.groups_outlined, tokens.infoLight),
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
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: tokens.textMuted),
      ),
    );
  }
}