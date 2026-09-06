import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:raqim/core/theme/app_theme.dart';
import 'package:raqim/core/widgets/app_card.dart';
import 'package:raqim/core/widgets/empty_state.dart';
import 'package:raqim/core/widgets/stat_tile.dart';

void main() {
  testWidgets('AppTheme.dark builds a theme with tokens', (tester) async {
    final theme = AppTheme.dark();
    expect(theme.extensions, isNotEmpty);
  });

  testWidgets('AppCard renders its child', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: AppCard(child: Text('hello')),
        ),
      ),
    );
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('EmptyState shows title and action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: EmptyState(
            title: 'لا شيء هنا',
            actionLabel: 'إضافة',
            onAction: () {},
          ),
        ),
      ),
    );
    expect(find.text('لا شيء هنا'), findsOneWidget);
    expect(find.text('إضافة'), findsOneWidget);
  });

  testWidgets('StatTile shows value', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: StatTile(label: 'الطلاب', value: 42),
        ),
      ),
    );
    expect(find.text('الطلاب'), findsOneWidget);
    expect(find.text('٤٢'), findsOneWidget); // Arabic-Indic numerals
  });
}