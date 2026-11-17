import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/adaptive_sheet.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../admin/domain/admin_models.dart';
import '../../domain/teacher_models.dart';

/// Full «ماذا سُجّل لهذا الطالب في الجلسة؟» sheet, opened from the compact
/// summary strip on the teacher's roster row.
Future<void> showTeacherSessionRecordsSheet(
  BuildContext context, {
  required TeacherRosterEntry entry,
  required List<AdminSessionRecord> records,
}) {
  return showAppSheet<void>(
    context: context,
    maxWidth: 640,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) =>
        _TeacherSessionRecordsSheet(entry: entry, records: records),
  );
}

class _TeacherSessionRecordsSheet extends StatelessWidget {
  const _TeacherSessionRecordsSheet({
    required this.entry,
    required this.records,
  });

  final TeacherRosterEntry entry;
  final List<AdminSessionRecord> records;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final summary = TeacherSessionSummary.fromRecords(records);
    final mems = records.where((r) => r.kind == 'memorization').toList();
    final matns = records.where((r) => r.kind == 'matn').toList();
    final txs = records.where((r) => r.kind == 'transaction').toList();
    final others = records
        .where(
          (r) =>
              r.kind != 'memorization' &&
              r.kind != 'matn' &&
              r.kind != 'transaction',
        )
        .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: tokens.brandTint,
                child: Text(
                  entry.student.name.trim().isEmpty
                      ? '?'
                      : entry.student.name.trim().characters.first,
                  style: TextStyle(
                    color: tokens.brandText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سجلات ${entry.student.name}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'في هذه الجلسة · ${records.length} سجل',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!summary.isEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (summary.pages > 0)
                  _SummaryChip(
                    icon: Icons.auto_stories_outlined,
                    label: summary.pagesLabel,
                    color: tokens.brand,
                  ),
                if (summary.matnLabel != null)
                  _SummaryChip(
                    icon: Icons.menu_book_outlined,
                    label: summary.matnLabel!,
                    color: tokens.accentMatn,
                  ),
                if (summary.pointsLabel != null)
                  _SummaryChip(
                    icon: Icons.stars_outlined,
                    label: summary.pointsLabel!,
                    color: tokens.reward,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          if (records.isEmpty)
            AppCard(
              child: Column(
                children: [
                  Icon(
                    Icons.playlist_add_check_circle_outlined,
                    size: 44,
                    color: tokens.textMuted,
                  ),
                  const SizedBox(height: 8),
                  const Text('لا سجلات لهذا الطالب في هذه الجلسة بعد.'),
                  const SizedBox(height: 4),
                  Text(
                    'استخدم أزرار الإضافة تحت اسمه في قائمة اليوم.',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                  ),
                ],
              ),
            )
          else ...[
            _group(
              context,
              title: 'تسميع القرآن',
              icon: Icons.auto_stories_outlined,
              color: tokens.brand,
              items: mems,
            ),
            _group(
              context,
              title: 'المتون',
              icon: Icons.menu_book_outlined,
              color: tokens.accentMatn,
              items: matns,
            ),
            _group(
              context,
              title: 'النقاط',
              icon: Icons.stars_outlined,
              color: tokens.reward,
              items: txs,
            ),
            _group(
              context,
              title: 'سجلات أخرى',
              icon: Icons.receipt_long_outlined,
              color: tokens.info,
              items: others,
            ),
          ],
        ],
      ),
    );
  }

  Widget _group(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<AdminSessionRecord> items,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                StatusBadge(label: '${items.length}', color: color),
              ],
            ),
            const SizedBox(height: 4),
            for (final record in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(icon, size: 15, color: color),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          if (record.subtitle.isNotEmpty)
                            Text(
                              record.subtitle,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: tokens.textSecondary),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatTime(record.when),
                      textDirection: TextDirection.ltr,
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: tokens.textMuted),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 210),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
