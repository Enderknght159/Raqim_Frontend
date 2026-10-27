import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:raqim/core/theme/app_theme.dart';
import 'package:raqim/core/widgets/async_view.dart';
import 'package:raqim/core/widgets/skeleton.dart';

Widget _wrap(Widget child) => MaterialApp(theme: AppTheme.light(), home: child);

void main() {
  testWidgets('AsyncView shows the skeleton only on the first load', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        AsyncView<String>(
          future: Future.value('A'),
          builder: (context, value) => Text(value),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('AsyncView keeps the previous content while a reload is pending '
      '(no skeleton flash after closing a sheet / pull-to-refresh)', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        AsyncView<String>(
          future: Future.value('A'),
          builder: (context, value) => Text(value),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);

    // Reload with a pending future (like _reload() after a bottom sheet).
    final completer = Completer<String>();
    await tester.pumpWidget(
      _wrap(
        AsyncView<String>(
          future: completer.future,
          builder: (context, value) => Text(value),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Old content stays; no skeleton flash.
    expect(find.text('A'), findsOneWidget);
    expect(find.byType(SkeletonBlock), findsNothing);

    completer.complete('B');
    await tester.pumpAndSettle();
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets(
    'AsyncView shows an error state when the FIRST load fails and keeps '
    'stale content when a reload fails',
    (tester) async {
      final firstLoad = Completer<String>();
      await tester.pumpWidget(
        _wrap(
          AsyncView<String>(
            future: firstLoad.future,
            builder: (context, value) => Text(value),
          ),
        ),
      );
      firstLoad.completeError(Exception('x'));
      await tester.pumpAndSettle();
      expect(find.text('تعذر التحميل'), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          AsyncView<String>(
            future: Future.value('A'),
            builder: (context, value) => Text(value),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('A'), findsOneWidget);

      final failedReload = Completer<String>();
      await tester.pumpWidget(
        _wrap(
          AsyncView<String>(
            future: failedReload.future,
            builder: (context, value) => Text(value),
          ),
        ),
      );
      failedReload.completeError(Exception('reload failed'));
      await tester.pumpAndSettle();
      // Stale content is kept after a failed reload.
      expect(find.text('A'), findsOneWidget);
      expect(find.text('تعذر التحميل'), findsNothing);
    },
  );
}
