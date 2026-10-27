import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'responsive_scope.dart';

/// Switches between a dense [DataTable] and the mobile card/list rendering.
///
/// Tables are only used when [ResponsiveData.showTables] is true (tablet or
/// web), so phone landscape never gets a cramped table.
class AdaptiveDataTable extends StatelessWidget {
  const AdaptiveDataTable({
    super.key,
    required this.table,
    required this.cards,
    this.forceTable = false,
  });

  final Widget table;
  final Widget cards;
  final bool forceTable;

  @override
  Widget build(BuildContext context) {
    final data = ResponsiveScope.of(context);
    return (forceTable || data.showTables) ? table : cards;
  }
}

/// Standard Raqim data table: flat, RTL-friendly, with optional horizontal
/// scrolling for genuinely dense admin tables.
class AppDataTable extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.emptyLabel = 'لا بيانات',
    this.horizontalScroll = true,
    this.minWidth,
  });

  final List<DataColumn> columns;
  final List<DataRow> rows;
  final String emptyLabel;
  final bool horizontalScroll;
  final double? minWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(emptyLabel, style: TextStyle(color: tokens.textMuted)),
        ),
      );
    }

    final table = DataTable(
      columns: columns,
      rows: rows,
      horizontalMargin: 0,
      columnSpacing: 24,
      headingRowHeight: 44,
      dataRowMinHeight: 48,
      dataRowMaxHeight: 64,
      headingRowColor: WidgetStatePropertyAll(tokens.surfaceSubtle),
      headingTextStyle: TextStyle(
        color: tokens.info,
        fontWeight: FontWeight.w800,
        fontSize: 13,
      ),
      dataTextStyle: TextStyle(
        color: tokens.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      border: TableBorder(
        horizontalInside: BorderSide(color: tokens.borderStructural),
      ),
      showCheckboxColumn: false,
    );

    if (!horizontalScroll) {
      return SizedBox(width: minWidth, child: table);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth ?? 0),
        child: table,
      ),
    );
  }
}
