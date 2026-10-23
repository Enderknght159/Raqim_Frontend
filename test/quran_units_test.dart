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

  test('3-unit pages are 596, 599, 600, 601, 602, 603, 604', () {
    const threeUnit = [596, 599, 600, 601, 602, 603, 604];
    for (final page in threeUnit) {
      expect(quranPageParts(page), 3, reason: 'page $page');
      expect(quranUnitsOfPage(page).length, 3, reason: 'page $page');
    }
  });

  test('split pages have 2 units with real surah names', () {
    expect(quranPageParts(106), 2);
    expect(quranUnitsOfPage(106).map((u) => u.surah),
        ['النساء', 'المائدة']);
    expect(quranUnitsOfPage(596).map((u) => u.surah),
        ['الليل', 'الضحى', 'الشرح']);
    // A single page always exposes its real surah (no '—' stubs).
    expect(quranUnitsOfPage(1).single.surah, 'الفاتحة');
    expect(quranUnitsOfPage(255).map((u) => u.surah), ['الرعد', 'ابراهيم']);
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
    // 44 two-split pages (+1 extra unit each) + 7 three-split pages (+2 each).
    final extra = quranUnits.length - 604;
    expect(extra, 44 + 14);
    expect(quranUnits.length, 662);
  });

  test('juz ranges follow the 604-page Madinah mushaf', () {
    expect(juzPageRange(1), (1, 21));
    expect(juzPageRange(2), (22, 41));
    expect(juzPageRange(3), (42, 61));
    expect(juzPageRange(29), (562, 581));
    expect(juzPageRange(30), (582, 604));
    for (var juz = 1; juz <= 30; juz++) {
      final (first, last) = juzPageRange(juz);
      expect(juzOfPage(first), juz, reason: 'first page of juz $juz');
      expect(juzOfPage(last), juz, reason: 'last page of juz $juz');
    }
    // Every page belongs to exactly one juz and the ranges are contiguous.
    expect(juzOfPage(1), 1);
    expect(juzOfPage(21), 1);
    expect(juzOfPage(22), 2);
    expect(juzOfPage(581), 29);
    expect(juzOfPage(582), 30);
    expect(juzOfPage(604), 30);
  });
}
