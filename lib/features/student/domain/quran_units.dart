/// Quran page-unit registry (BR-501..BR-504).
///
/// The mushaf has 604 pages. Most pages are a single unit (one surah); a few
/// pages contain the end of one surah and the start of the next, so they are
/// split into 2 or 3 units. Surah names for single pages are stubbed with
/// '—' until the full page→surah map lands (display only).
///
/// Split pages (2 units) come from `business-rules-and-glossary.md` BR-504;
/// the 3-unit pages are: 596, 599, 601, 602, 603, 604.
class QuranUnit {
  const QuranUnit({
    required this.page,
    required this.partIndex,
    required this.surah,
  });

  /// 1..604 mushaf page number.
  final int page;

  /// 1-based index of the unit inside the page.
  final int partIndex;

  /// Surah occupying this unit ('—' for single-unit pages, display stub).
  final String surah;
}

/// `page → [surahs occupying it]` for split pages (BR-504 + 3-unit pages).
const Map<int, List<String>> quranSplitPages = {
  106: ['المائدة', 'الأنعام'],
  221: ['يونس', 'هود'],
  235: ['هود', 'يوسف'],
  255: ['إبراهيم', 'الحجر'],
  267: ['النحل', 'الإسراء'],
  293: ['الكهف', 'مريم'],
  312: ['طه', 'الأنبياء'],
  359: ['الفرقان', 'الشعراء'],
  385: ['القصص', 'العنكبوت'],
  396: ['العنكبوت', 'الروم'],
  404: ['الروم', 'لقمان'],
  434: ['فاطر', 'يس'],
  440: ['يس', 'الصافات'],
  458: ['الزمر', 'غافر'],
  467: ['غافر', 'فصلت'],
  489: ['الزخرف', 'الدخان'],
  502: ['الأحقاف', 'محمد'],
  515: ['الحجرات', 'ق'],
  520: ['الذاريات', 'الطور'],
  523: ['الطور', 'النجم'],
  528: ['القمر', 'الرحمن'],
  531: ['الرحمن', 'الواقعة'],
  534: ['الواقعة', 'الحديد'],
  537: ['الحديد', 'المجادلة'],
  545: ['الحشر', 'الممتحنة'],
  551: ['الصف', 'الجمعة'],
  554: ['المنافقون', 'التغابن'],
  564: ['القلم', 'الحاقة'],
  566: ['الحاقة', 'المعارج'],
  568: ['المعارج', 'نوح'],
  570: ['نوح', 'الجن'],
  575: ['المدثر', 'القيامة'],
  577: ['القيامة', 'الإنسان'],
  578: ['الإنسان', 'المرسلات'],
  580: ['المرسلات', 'النبأ'],
  583: ['النبأ', 'النازعات'],
  587: ['الانفطار', 'المطففين'],
  589: ['الانشقاق', 'البروج'],
  591: ['الطارق', 'الأعلى'],
  592: ['الأعلى', 'الغاشية'],
  594: ['البلد', 'الشمس'],
  595: ['الشمس', 'الليل'],
  596: ['الليل', 'الضحى', 'الشرح'],
  597: ['التين', 'العلق'],
  598: ['القدر', 'البينة'],
  599: ['البينة', 'الزلزلة', 'العاديات'],
  600: ['القارعة', 'التكاثر'],
  601: ['العصر', 'الهمزة', 'الفيل'],
  602: ['قريش', 'الماعون', 'الكوثر'],
  603: ['الكافرون', 'النصر', 'المسد'],
  604: ['الإخلاص', 'الفلق', 'الناس'],
};

/// Number of surah units occupying a page (BR-503).
int quranPageParts(int page) => quranSplitPages[page]?.length ?? 1;

/// All 604 pages expanded into their units, ordered by page then part.
final List<QuranUnit> quranUnits = [
  for (var page = 1; page <= 604; page++)
    if (quranSplitPages.containsKey(page))
      for (var i = 0; i < quranSplitPages[page]!.length; i++)
        QuranUnit(
          page: page,
          partIndex: i + 1,
          surah: quranSplitPages[page]![i],
        )
    else
      QuranUnit(page: page, partIndex: 1, surah: '—'),
];

/// Units belonging to a page, in part order.
List<QuranUnit> quranUnitsOfPage(int page) =>
    quranUnits.where((u) => u.page == page).toList();
