import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:raqim/core/theme/app_theme.dart';
import 'package:raqim/features/student/presentation/widgets/quran_grid.dart';

Widget _grid(int juz, {double width = 560}) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: width,
          child: QuranGrid(juz: juz, pageStatus: const {}),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('quran grid keeps 7 columns and square cells', (tester) async {
    await tester.pumpWidget(_grid(1));
    await tester.pumpAndSettle();

    final grid = tester.widget<GridView>(find.byType(GridView));
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 7);

    final cells = find.byType(PageGridCell);
    expect(cells, findsNWidgets(21));
    final first = tester.getSize(cells.first);
    expect(first.width, closeTo(first.height, 0.01));
  });

  testWidgets('juz 30 adds a fourth row without changing cell shape', (
    tester,
  ) async {
    expect(QuranGrid.rowsFor(1), 3);
    expect(QuranGrid.rowsFor(30), 4);
    expect(
      QuranGrid.heightFor(30, 560),
      greaterThan(QuranGrid.heightFor(1, 560)),
    );

    await tester.pumpWidget(_grid(30));
    await tester.pumpAndSettle();
    final first = tester.getSize(find.byType(PageGridCell).first);
    expect(first.width, closeTo(first.height, 0.01));
  });
}
