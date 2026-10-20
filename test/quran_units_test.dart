import 'package:flutter_test/flutter_test.dart';

import 'package:raqim/features/student/domain/quran_units.dart';

void main() {
  test('quran_units covers all 604 pages', () {
    final pages = quranUnits.map((u) => u.page).toSet();
    expect(pages.length, 604);
    expect(pages.first, 1);
    expect(pages.last, 604);
  });

  test('single pages have exactly one unit', () {
    expect(quranUnitsOfPage(1).length, 1);
    expect(quranUnitsOfPage(555).length, 1);
  });

  test('3-unit pages are 596, 599, 601, 602, 603, 604', () {
    const threeUnit = [596, 599, 601, 602, 603, 604];
    for (final page in threeUnit) {
      expect(quranPageParts(page), 3, reason: 'page $page');
      expect(quranUnitsOfPage(page).length, 3, reason: 'page $page');
    }
  });

  test('split pages have 2 units with real surah names', () {
    expect(quranPageParts(106), 2);
    expect(quranUnitsOfPage(106).map((u) => u.surah),
        ['المائدة', 'الأنعام']);
    expect(quranUnitsOfPage(596).map((u) => u.surah),
        ['الليل', 'الضحى', 'الشرح']);
  });

  test('partIndex is 1-based per page', () {
    for (var page = 1; page <= 604; page++) {
      final units = quranUnitsOfPage(page);
      expect(units.map((u) => u.partIndex).toList(),
          List.generate(units.length, (i) => i + 1),
          reason: 'page $page');
    }
  });

  test('total unit count = pages + extra units', () {
    // 45 two-split pages (+1 extra unit each) + 6 three-split pages (+2 each).
    final extra = quranUnits.length - 604;
    expect(extra, 45 + 12);
    expect(quranUnits.length, 661);
  });
}
