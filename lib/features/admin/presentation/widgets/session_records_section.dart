import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/admin_models.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

/// E3 «سجلات الجلسة»: the records written in this session grouped into
/// memorization · matn · transactions, with a short preview and «عرض الكل».
class SessionRecordsSection extends StatelessWidget {
  const SessionRecordsSection({super.key, required this.records});

  final List<AdminSessionRecord> records;

  static const int _groupPreview = 2;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final mems = records.where((r) => r.kind == 'memorization').toList();
    final matns = records.where((r) => r.kind == 'matn').toList();
    final txs = records.where((r) => r.kind == 'transaction').toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: SectionHeader(
                  icon: Icons.receipt_long_outlined,
                  title: 'سجلات الجلسة',
                ),
              ),
              StatusBadge(
                label: '${records.length}',
                color: records.isEmpty ? tokens.textMuted : tokens.info,
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'لا سجلات في هذه الجلسة',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else ...[
            _group(
              context,
              icon: Icons.menu_book,
              color: tokens.brand,
              title: 'الحفظ',
              items: mems,
            ),
            _group(
              context,
              icon: Icons.format_quote_outlined,
              color: tokens.accentMatn,
              title: 'المتون',
              items: matns,
            ),
            _group(
              context,
              icon: Icons.payments_outlined,
              color: tokens.reward,
              title: 'المعاملات',
              items: txs,
            ),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: () => _showAll(context, mems, matns, txs),
                child: const Text('عرض الكل'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _group(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required List<AdminSessionRecord> items,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 6),
              Text(
                '(${items.length})',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
              ),
            ],
          ),
          for (final r in items.take(_groupPreview)) _row(context, r),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, AdminSessionRecord r) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${r.studentName}: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: r.title,
                    style: TextStyle(color: tokens.textSecondary),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          if (r.subtitle.isNotEmpty)
            Flexible(
              child: Text(
                r.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
              ),
            ),
        ],
      ),
    );
  }

  void _showAll(
    BuildContext context,
    List<AdminSessionRecord> mems,
    List<AdminSessionRecord> matns,
    List<AdminSessionRecord> txs,
  ) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    showAppSheet<void>(
      context: context,
      maxWidth: 720,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text('سجلات الجلسة', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (records.isEmpty)
              Text('لا سجلات', style: Theme.of(context).textTheme.bodyMedium),
            _fullGroup(
              context,
              tokens,
              'الحفظ',
              mems,
              Icons.menu_book,
              tokens.brand,
            ),
            _fullGroup(
              context,
              tokens,
              'المتون',
              matns,
              Icons.format_quote_outlined,
              tokens.accentMatn,
            ),
            _fullGroup(
              context,
              tokens,
              'المعاملات',
              txs,
              Icons.payments_outlined,
              tokens.reward,
            ),
          ],
        ),
      ),
    );
  }

  Widget _fullGroup(
    BuildContext context,
    AppTokens tokens,
    String title,
    List<AdminSessionRecord> items,
    IconData icon,
    Color color,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            StatusBadge(label: '${items.length}', color: color),
          ],
        ),
        const SizedBox(height: 2),
        for (final r in items)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text('${r.studentName} — ${r.title}'),
            subtitle: r.subtitle.isEmpty ? null : Text(r.subtitle),
          ),
      ],
    );
  }
}
