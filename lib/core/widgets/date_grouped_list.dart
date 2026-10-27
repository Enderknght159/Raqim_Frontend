import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Groups a (sorted, newest-first) list by calendar day with friendly day
/// headers (اليوم · أمس · يوم/شهر). Used by the audit log and notifications.
class DateGroupedList<T> extends StatelessWidget {
  const DateGroupedList({
    super.key,
    required this.items,
    required this.dateOf,
    required this.itemBuilder,
    this.dayLabelBuilder,
    this.horizontalPadding = 16,
  });

  final List<T> items;
  final DateTime Function(T item) dateOf;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String Function(DateTime day)? dayLabelBuilder;

  /// Page margin applied to the whole list (rows no longer stick to the
  /// screen edges).
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final groups = <({DateTime day, List<T> items})>[];
    for (final item in items) {
      final d = dateOf(item);
      final day = DateTime(d.year, d.month, d.day);
      if (groups.isEmpty || groups.last.day != day) {
        groups.add((day: day, items: []));
      }
      groups.last.items.add(item);
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      itemCount: groups.length,
      itemBuilder: (context, i) => _DayGroup<T>(
        day: groups[i].day,
        label: (dayLabelBuilder ?? defaultDayLabel)(groups[i].day),
        items: groups[i].items,
        itemBuilder: itemBuilder,
      ),
    );
  }
}

/// Default day label: اليوم / أمس / يوم-شهر عربي.
String defaultDayLabel(DateTime day) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'اليوم';
  if (diff == 1) return 'أمس';
  const months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  return '${day.day} ${months[day.month - 1]}';
}

class _DayGroup<T> extends StatelessWidget {
  const _DayGroup({
    required this.day,
    required this.label,
    required this.items,
    required this.itemBuilder,
  });

  final DateTime day;
  final String label;
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
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
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: tokens.textPrimary,
                ),
              ),
            ],
          ),
        ),
        for (final item in items) itemBuilder(context, item),
        const SizedBox(height: 4),
      ],
    );
  }
}
