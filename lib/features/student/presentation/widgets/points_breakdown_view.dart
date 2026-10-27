import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/responsive_scope.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/models/student_models.dart';
import '../../domain/student_stats.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

/// Full-page «محصلة النقاط» (student + admin student view): two hero
/// balances, a colored icon grid for every points source, and the latest
/// transactions with «عرض الكل».
class PointsBreakdownView extends StatelessWidget {
  const PointsBreakdownView({super.key, required this.bundle});

  final StudentCourseBundle bundle;

  /// Preview size before «عرض الكل».
  static const int _previewTransactions = 5;

  @override
  Widget build(BuildContext context) {
    final b = bundle.breakdown;
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final transactions = [...bundle.transactions]
      ..sort((a, b) => b.date.compareTo(a.date));
    final expanded = ResponsiveScope.of(context).isExpanded;

    return ResponsivePage(
      maxWidth: 1100,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _hero(context, b),
          const SizedBox(height: 16),
          const SectionHeader(
            icon: Icons.insights_outlined,
            title: 'تفصيل النقاط',
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: expanded ? 4 : 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.98,
            children: [
              _PointTile(
                icon: Icons.schedule,
                color: tokens.infoLight,
                label: 'الحضور',
                value: b.attendance,
              ),
              _PointTile(
                icon: Icons.menu_book,
                color: tokens.brand,
                label: 'القرآن الكريم',
                value: b.memorization,
              ),
              _PointTile(
                icon: Icons.school_outlined,
                color: tokens.reward,
                label: 'شهادات القرآن',
                value: b.certificates,
              ),
              _PointTile(
                icon: Icons.assignment_turned_in_outlined,
                color: tokens.accentMatn,
                label: 'الاختبارات العلمية',
                value: b.exams,
              ),
              _PointTile(
                icon: Icons.format_quote_outlined,
                color: tokens.accentMatn,
                label: 'المتون',
                value: b.matn,
              ),
              _PointTile(
                icon: Icons.add_circle_outline,
                color: tokens.brand,
                label: 'المكافآت',
                // دخل/صرف يُجمع هنا (لا يظهر بندًا منفصلًا).
                value: b.reward + b.incomeExpense,
              ),
              _PointTile(
                icon: Icons.remove_circle_outline,
                color: tokens.danger,
                label: 'العقوبات',
                value: -b.penalty,
              ),
              _PointTile(
                icon: Icons.shopping_bag_outlined,
                color: tokens.reward,
                label: 'الشراء',
                // دخل/صرف يُجمع هنا أيضًا (لا يظهر بندًا منفصلًا).
                value: -(b.purchase + b.incomeExpense),
                valueColor: tokens.rewardText,
              ),
              _PointTile(
                icon: Icons.savings_outlined,
                color: tokens.info,
                label: 'التحصيل',
                value: b.collection,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SectionHeader(
            icon: Icons.receipt_long_outlined,
            title: 'المعاملات',
            trailing: transactions.length > _previewTransactions
                ? TextButton(
                    onPressed: () =>
                        _showAllTransactions(context, transactions),
                    child: const Text('عرض الكل'),
                  )
                : null,
          ),
          const SizedBox(height: 4),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: transactions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'لا توجد معاملات',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : Column(
                    children: [
                      for (final t in transactions.take(_previewTransactions))
                        _transactionRow(context, t),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context, PointsBreakdown b) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: _balance(
              context,
              label: 'المحصلة',
              value: b.total,
              color: b.total < 0 ? tokens.dangerText : tokens.rewardText,
              icon: Icons.emoji_events,
            ),
          ),
          Container(width: 1, height: 56, color: tokens.borderStructural),
          Expanded(
            child: _balance(
              context,
              label: 'المتاح للشراء',
              value: b.purchaseBalance,
              color: tokens.info,
              icon: Icons.account_balance_wallet_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _balance(
    BuildContext context, {
    required String label,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          'نقطة',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
        ),
      ],
    );
  }

  Widget _transactionRow(BuildContext context, StudentTransaction t) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final color = _txColor(t.type, tokens);
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(_txIcon(t.type), color: color, size: 20),
      title: Text(t.type.arabic),
      subtitle: Text(
        '${t.description == null || t.description!.isEmpty ? formatDate(t.date) : t.description!} · ${formatDate(t.date)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: tokens.textMuted, fontSize: 13),
      ),
      trailing: Text(
        _txSigned(t.type, t.pointsValue),
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  void _showAllTransactions(
    BuildContext context,
    List<StudentTransaction> transactions,
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
        builder: (context, controller) => ListView.builder(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          itemCount: transactions.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(
                      'كل المعاملات',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    Text(
                      '${transactions.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: tokens.info,
                      ),
                    ),
                  ],
                ),
              );
            }
            return _transactionRow(context, transactions[i - 1]);
          },
        ),
      ),
    );
  }
}

class _PointTile extends StatelessWidget {
  const _PointTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int value;

  /// Overrides the default number color (negatives are red by default).
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final negative = value < 0;
    return AppCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(tokens.radiusSmall),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            value > 0 ? '+$value' : '$value',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color:
                  valueColor ??
                  (negative ? tokens.dangerText : tokens.textPrimary),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: tokens.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _txIcon(TransactionType t) => switch (t) {
  TransactionType.reward => Icons.add_circle_outline,
  TransactionType.penalty => Icons.remove_circle_outline,
  TransactionType.purchase => Icons.shopping_bag_outlined,
  TransactionType.collection => Icons.savings_outlined,
  TransactionType.incomeExpense => Icons.swap_horiz,
};

Color _txColor(TransactionType t, AppTokens tokens) => switch (t) {
  TransactionType.penalty => tokens.danger,
  TransactionType.purchase => tokens.reward,
  _ => tokens.brand,
};

String _txSigned(TransactionType t, int value) {
  final v = value.abs();
  return switch (t) {
    TransactionType.reward ||
    TransactionType.collection ||
    TransactionType.incomeExpense => '+$v',
    _ => '-$v',
  };
}
