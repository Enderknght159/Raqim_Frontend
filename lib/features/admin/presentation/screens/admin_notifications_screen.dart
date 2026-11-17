import 'package:flutter/material.dart';

import '../../../../core/state/section_loader.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/date_grouped_list.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/icon_tile.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';

/// Admin notifications: mosque-wide writes aggregated per day and per kind
/// («تسجيل حضور لفلان و54 آخرين») with editable wording (trial-local).
class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  /// Bumped after every undo so the list refetches.
  int _revision = 0;
  String? _kindFilter;

  Future<List<AdminNotification>> _load() async {
    final repo = AdminRepositoryScope.of(context);
    final items = await repo.notifications();
    await repo.markAdminNotifRead();
    return items;
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _revision++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات')),
      body: AsyncSection<List<AdminNotification>>(
        cacheKey: 'admin-notifications',
        revision: _revision,
        skeleton: const _NotificationsSkeleton(),
        errorBuilder: (context, retry) => Padding(
          padding: const EdgeInsets.all(16),
          child: SectionError(onRetry: retry, message: 'تعذر تحميل الإشعارات'),
        ),
        load: _load,
        builder: (context, items) {
          if (items.isEmpty) {
            return const EmptyState(
              title: 'لا إشعارات',
              icon: Icons.notifications_off_outlined,
              message: 'ستظهر الكتابات الأخيرة هنا',
            );
          }
          final kinds = items.map((n) => n.kind).toSet().toList();
          final visible = _kindFilter == null
              ? items
              : items.where((n) => n.kind == _kindFilter).toList();
          return Column(
            children: [
              SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    ChoiceChip(
                      label: const Text('الكل'),
                      selected: _kindFilter == null,
                      onSelected: (_) => setState(() => _kindFilter = null),
                    ),
                    const SizedBox(width: 8),
                    for (final k in kinds) ...[
                      ChoiceChip(
                        label: Text(adminNotificationKindLabel(k)),
                        selected: _kindFilter == k,
                        onSelected: (_) => setState(() => _kindFilter = k),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: ResponsivePage(
                  maxWidth: 800,
                  child: DateGroupedList<AdminNotification>(
                    items: visible,
                    dateOf: (n) => n.when,
                    itemBuilder: (context, n) => _row(context, n),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(BuildContext context, AdminNotification n) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final (icon, color) = _style(n.kind, tokens);
    final kind = adminNotificationKindLabel(n.kind);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Tooltip(
              message: kind,
              triggerMode: TooltipTriggerMode.longPress,
              child: IconTile(icon: icon, color: color, size: 40, iconSize: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title(n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    formatTime(n.when),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                  ),
                ],
              ),
            ),
            if (n.recordId != null)
              IconButton(
                tooltip: 'تراجع عن السجل',
                icon: const Icon(Icons.undo, size: 20),
                color: tokens.dangerText,
                onPressed: () => _revert(n),
              ),
          ],
        ),
      ),
    );
  }

  /// The kind is already carried by the leading icon (and its tooltip), so the
  /// row itself only names the person and how many others share the write.
  String _title(AdminNotification n) {
    if (n.extraCount == 0) return n.firstName;
    return '${n.firstName} و${n.extraCount} آخرين';
  }

  (IconData, Color) _style(String kind, AppTokens tokens) => switch (kind) {
    'Attendance' => (Icons.schedule, tokens.infoLight),
    'Memorization' => (Icons.menu_book, tokens.brand),
    'Transaction' => (Icons.payments_outlined, tokens.reward),
    _ => (Icons.edit_note, tokens.info),
  };

  /// Reverts the underlying record (not the notification text).
  Future<void> _revert(AdminNotification n) async {
    final kind = adminNotificationKindLabel(n.kind);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تراجع عن $kind'),
        content: Text('سيُحذف السجل «${n.firstName}» نهائيًا. متابعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تراجع'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final repo = AdminRepositoryScope.of(context);
    final ok = await repo.undoRecord(n.kind, n.recordId!);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(ok ? 'تم التراجع وحُذف السجل' : 'تعذّر التراجع'),
        ),
      );
    _reload();
  }
}

/// Rough shape of the kind chips and the first notification rows.
class _NotificationsSkeleton extends StatelessWidget {
  const _NotificationsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionSkeleton(height: 40, lines: 1, showCard: false),
          SizedBox(height: 12),
          SectionSkeleton(height: 44, lines: 1),
          SizedBox(height: 8),
          SectionSkeleton(height: 44, lines: 1),
          SizedBox(height: 8),
          SectionSkeleton(height: 44, lines: 1),
        ],
      ),
    );
  }
}
