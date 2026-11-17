import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/numeral_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../student/domain/models/student_models.dart';
import '../../domain/admin_models.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

/// E3 «سجلات الجلسة»: the records written in this session grouped into
/// memorization · matn · transactions, with a short preview and «عرض الكل».
///
/// Rows are icon-first: the repeated words baked into the backend titles
/// («حفظ صفحة», «تقييم», «البيت», «نقطة» …) are stripped and replaced by an
/// icon + value, so nothing is said twice.
class SessionRecordsSection extends StatelessWidget {
  const SessionRecordsSection({super.key, required this.records});

  final List<AdminSessionRecord> records;

  static const int _groupPreview = 2;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final groups = _groups(tokens).where((g) => g.items.isNotEmpty).toList();

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
              const SizedBox(width: 8),
              StatusBadge(
                label: '${records.length}',
                color: records.isEmpty ? tokens.textMuted : tokens.info,
              ),
            ],
          ),
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'لا سجلات في هذه الجلسة',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else ...[
            for (var i = 0; i < groups.length; i++)
              _group(context, groups[i], divider: i > 0),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: () => _showAll(context, groups),
                child: const Text('عرض الكل'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<_RecordGroup> _groups(AppTokens tokens) {
    const known = {'memorization', 'matn', 'transaction'};
    return [
      _RecordGroup(
        title: 'الحفظ',
        icon: Icons.menu_book,
        color: tokens.brand,
        items: _itemsOf('memorization'),
      ),
      _RecordGroup(
        title: 'المتون',
        icon: Icons.format_quote_outlined,
        color: tokens.accentMatn,
        items: _itemsOf('matn'),
      ),
      _RecordGroup(
        title: 'المعاملات',
        icon: Icons.payments_outlined,
        color: tokens.reward,
        items: _itemsOf('transaction'),
      ),
      _RecordGroup(
        title: 'سجلات أخرى',
        icon: Icons.receipt_long_outlined,
        color: tokens.info,
        items: records.where((r) => !known.contains(r.kind)).toList(),
      ),
    ];
  }

  List<AdminSessionRecord> _itemsOf(String kind) =>
      records.where((r) => r.kind == kind).toList();

  Widget _group(
    BuildContext context,
    _RecordGroup group, {
    required bool divider,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    if (group.items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: divider ? 12 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (divider) ...[
            Divider(height: 1, thickness: 1, color: tokens.borderStructural),
            const SizedBox(height: 10),
          ],
          _GroupHeader(group: group),
          const SizedBox(height: 4),
          for (final r in group.items.take(_groupPreview)) _row(context, r),
        ],
      ),
    );
  }

  /// Single-line record row: student name first, then icon + value metrics.
  Widget _row(
    BuildContext context,
    AdminSessionRecord r, {
    bool showDetail = false,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final metrics = _metrics(context, r, tokens);
    final detail = showDetail ? _detailOf(r) : null;
    final row = Row(
      children: [
        Expanded(
          child: Text(
            r.studentName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ...metrics,
      ],
    );
    if (detail == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: row,
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row,
          const SizedBox(height: 2),
          Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
          ),
        ],
      ),
    );
  }

  /// Builds the compact icon + value pairs for one record, stripping the
  /// repeated prefix words carried by the backend titles.
  List<Widget> _metrics(
    BuildContext context,
    AdminSessionRecord r,
    AppTokens tokens,
  ) {
    switch (r.kind) {
      case 'memorization':
        final page = _firstNumber(r.title);
        final rating = _firstNumber(r.subtitle);
        return [
          _metric(
            context,
            icon: Icons.menu_book_outlined,
            color: tokens.brand,
            text: page == null ? r.title : formatNumber(page),
            tooltip: r.title,
            maxWidth: page == null ? 120 : 46,
          ),
          if (rating != null) ...[
            const SizedBox(width: 10),
            _metric(
              context,
              icon: Icons.star_outline,
              color: tokens.reward,
              text: formatNumber(rating),
              tooltip: 'التقييم ${formatNumber(rating)}',
              maxWidth: 46,
            ),
          ],
        ];
      case 'matn':
        final parts = r.title.split('—');
        final name = parts.first.trim();
        final verseSource = parts.length > 1 ? parts.sublist(1).join('—') : '';
        final verse = _firstNumber(verseSource);
        return [
          _metric(
            context,
            icon: Icons.format_quote_outlined,
            color: tokens.accentMatn,
            text: name.isEmpty ? r.title : name,
            tooltip: 'المتن: ${name.isEmpty ? r.title : name}',
            maxWidth: 118,
          ),
          if (verse != null) ...[
            const SizedBox(width: 10),
            _metric(
              context,
              icon: Icons.format_list_numbered,
              color: tokens.accentMatnText,
              text: formatNumber(verse),
              tooltip: 'آخر بيت',
              maxWidth: 46,
            ),
          ],
        ];
      case 'transaction':
        final parts = r.title.split('·');
        final typeLabel = parts.length > 1 ? parts.first.trim() : '';
        final points = _firstNumber(
          parts.length > 1 ? parts.sublist(1).join('·') : r.title,
        );
        if (typeLabel.isEmpty) {
          return [
            _metric(
              context,
              icon: Icons.payments_outlined,
              color: tokens.reward,
              text: points == null ? r.title : _signedPoints('', points),
              tooltip: r.title,
              maxWidth: points == null ? 120 : 52,
            ),
          ];
        }
        return [
          _metric(
            context,
            icon: Icons.payments_outlined,
            color: tokens.reward,
            text: typeLabel,
            tooltip: 'المعاملة: $typeLabel',
            maxWidth: 94,
          ),
          if (points != null) ...[
            const SizedBox(width: 10),
            _pointsLabel(context, tokens, typeLabel, points),
          ],
        ];
      default:
        final number = _firstNumber(r.title);
        return [
          _metric(
            context,
            icon: _kindIcon(r.kind),
            color: tokens.info,
            text: number == null ? r.title : formatNumber(number),
            tooltip: r.title,
            maxWidth: number == null ? 140 : 52,
          ),
        ];
    }
  }

  Widget _metric(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String text,
    required String tooltip,
    double maxWidth = 120,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Tooltip(
      message: tooltip,
      triggerMode: TooltipTriggerMode.longPress,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: tokens.textSecondary,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pointsLabel(
    BuildContext context,
    AppTokens tokens,
    String typeLabel,
    int points,
  ) {
    final type = _transactionTypeOf(typeLabel);
    final color = type == null
        ? tokens.textSecondary
        : _isDeduction(type)
        ? tokens.dangerText
        : tokens.brandText;
    return Tooltip(
      message: 'النقاط',
      triggerMode: TooltipTriggerMode.longPress,
      child: Text(
        _signedPoints(typeLabel, points),
        textDirection: TextDirection.ltr,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
      ),
    );
  }

  /// Non-repeated extra line used only in the «عرض الكل» sheet (teacher,
  /// reciter, transaction description …).
  String? _detailOf(AdminSessionRecord r) {
    final subtitle = r.subtitle.trim();
    if (subtitle.isEmpty) return null;
    switch (r.kind) {
      case 'memorization':
        final parts = subtitle
            .split('·')
            .map((p) => p.trim())
            .where((p) => p.isNotEmpty && !p.startsWith('تقييم'))
            .toList();
        return parts.isEmpty ? null : parts.join(' · ');
      case 'transaction':
        if (subtitle == 'بدون وصف') return null;
        final typeLabel = r.title.split('·').first.trim();
        return subtitle == typeLabel ? null : subtitle;
      default:
        return subtitle;
    }
  }

  void _showAll(BuildContext context, List<_RecordGroup> groups) {
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'سجلات الجلسة',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(label: '${records.length}', color: tokens.info),
              ],
            ),
            const SizedBox(height: 4),
            if (records.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'لا سجلات',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
                ),
              ),
            for (var i = 0; i < groups.length; i++)
              _fullGroup(context, groups[i], divider: i > 0),
          ],
        ),
      ),
    );
  }

  Widget _fullGroup(
    BuildContext context,
    _RecordGroup group, {
    required bool divider,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Padding(
      padding: EdgeInsets.only(top: divider ? 12 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (divider) ...[
            Divider(height: 1, thickness: 1, color: tokens.borderStructural),
            const SizedBox(height: 10),
          ],
          _GroupHeader(group: group),
          const SizedBox(height: 4),
          for (final r in group.items) _row(context, r, showDetail: true),
        ],
      ),
    );
  }

  static IconData _kindIcon(String kind) => switch (kind) {
    'recitation' => Icons.record_voice_over_outlined,
    'tajweed' => Icons.graphic_eq,
    'exam' || 'test' => Icons.quiz_outlined,
    'certificate' => Icons.workspace_premium_outlined,
    _ => Icons.receipt_long_outlined,
  };

  static final RegExp _digits = RegExp(r'\d+');

  static int? _firstNumber(String text) {
    final match = _digits.firstMatch(text);
    if (match == null) return null;
    return int.tryParse(match.group(0)!);
  }

  static TransactionType? _transactionTypeOf(String label) {
    for (final type in TransactionType.values) {
      if (type.arabic == label) return type;
    }
    return null;
  }

  static bool _isDeduction(TransactionType type) =>
      type == TransactionType.penalty || type == TransactionType.purchase;

  static String _signedPoints(String typeLabel, int points) {
    final value = formatNumber(points.abs());
    final type = _transactionTypeOf(typeLabel);
    if (type == null) return value;
    return _isDeduction(type) ? '-$value' : '+$value';
  }
}

/// Icon + count group header (the group name lives in a Tooltip only).
class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.group});

  final _RecordGroup group;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Tooltip(
        message: group.title,
        triggerMode: TooltipTriggerMode.longPress,
        child: Semantics(
          label: group.title,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(group.icon, size: 16, color: group.color),
                const SizedBox(width: 4),
                Text(
                  formatNumber(group.items.length),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.textMuted,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordGroup {
  const _RecordGroup({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<AdminSessionRecord> items;
}
