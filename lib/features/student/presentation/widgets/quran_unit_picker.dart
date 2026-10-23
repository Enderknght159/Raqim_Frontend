import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/quran_units.dart';

/// Reusable memorization-page picker (BR-501..513): a paged 604-page map
/// (one view per juz — lazy PageView, only nearby views are built) where
/// multi-unit (split) pages open a unit checklist. Emits selected [QuranUnit]s.
///
/// The sheet mirrors the student "خريطة الحفظ" (B2): a square juz selector +
/// 7-column square page cells with a battery-style fill for partial selection.
class QuranUnitPicker extends StatefulWidget {
  const QuranUnitPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final List<QuranUnit> selected;
  final ValueChanged<List<QuranUnit>> onChanged;

  @override
  State<QuranUnitPicker> createState() => _QuranUnitPickerState();
}

class _QuranUnitPickerState extends State<QuranUnitPicker> {
  String get _summary {
    if (widget.selected.isEmpty) return 'لم تُحدد صفحات';
    final pages = widget.selected.map((u) => u.page).toSet().toList()
      ..sort();
    final names = pages.take(3).map((p) => 'ص$p').join(' · ');
    return '${widget.selected.length} وحدة ($names${pages.length > 3 ? ' …' : ''})';
  }

  Future<void> _open() async {
    final result = await showModalBottomSheet<List<QuranUnit>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _QuranUnitPickerSheet(initial: widget.selected),
    );
    if (result != null) widget.onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return InkWell(
      borderRadius: BorderRadius.circular(tokens.radiusSmall),
      onTap: _open,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: tokens.surfaceSubtle,
          borderRadius: BorderRadius.circular(tokens.radiusSmall),
          border: Border.all(color: tokens.borderStructural),
        ),
        child: Row(
          children: [
            Icon(Icons.auto_stories_outlined, size: 20, color: tokens.brandText),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _summary,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: widget.selected.isEmpty
                          ? tokens.textMuted
                          : tokens.textPrimary,
                      fontWeight: widget.selected.isEmpty
                          ? FontWeight.w400
                          : FontWeight.w700,
                    ),
              ),
            ),
            Icon(Icons.grid_view_outlined, size: 18, color: tokens.textMuted),
          ],
        ),
      ),
    );
  }
}

class _QuranUnitPickerSheet extends StatefulWidget {
  const _QuranUnitPickerSheet({required this.initial});

  final List<QuranUnit> initial;

  @override
  State<_QuranUnitPickerSheet> createState() => _QuranUnitPickerSheetState();
}

class _QuranUnitPickerSheetState extends State<_QuranUnitPickerSheet> {
  /// One view per juz (30), using the official Madinah page ranges.
  static const int _viewCount = 30;

  late Set<String> _keys = {
    for (final u in widget.initial) '${u.page}:${u.partIndex}',
  };
  late final PageController _pages =
      PageController(initialPage: _initialView());
  late int _currentView = _initialView();

  int _initialView() {
    if (widget.initial.isEmpty) return 0;
    final page = widget.initial.map((u) => u.page).reduce((a, b) => a < b ? a : b);
    return _viewOfPage(page);
  }

  static int _viewOfPage(int page) => juzOfPage(page) - 1;

  static (int first, int last) _viewRange(int view) =>
      juzPageRange(view + 1);

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  List<QuranUnit> get _selectedUnits => quranUnits
      .where((u) => _keys.contains('${u.page}:${u.partIndex}'))
      .toList();

  bool _pageFullySelected(int page) {
    final units = quranUnitsOfPage(page);
    return units.isNotEmpty &&
        units.every((u) => _keys.contains('${u.page}:${u.partIndex}'));
  }

  int _pageSelectedCount(int page) => quranUnitsOfPage(page)
      .where((u) => _keys.contains('${u.page}:${u.partIndex}'))
      .length;

  void _togglePage(int page) {
    final units = quranUnitsOfPage(page);
    setState(() {
      if (_pageFullySelected(page)) {
        for (final u in units) {
          _keys.remove('${u.page}:${u.partIndex}');
        }
      } else {
        for (final u in units) {
          _keys.add('${u.page}:${u.partIndex}');
        }
      }
    });
  }

  Future<void> _openUnits(int page) async {
    final units = quranUnitsOfPage(page);
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      showDragHandle: true,
      builder: (context) => _UnitChecklist(
        page: page,
        units: units,
        selectedKeys: _keys,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _keys = result;
      });
    }
  }

  void _jumpToView(int view) {
    _pages.animateToPage(
      view,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final count = _keys.length;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                Text('خريطة الحفظ',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(width: 8),
                StatusBadge(
                  label: '$count وحدة',
                  color: count == 0 ? tokens.textMuted : tokens.brand,
                ),
                const Spacer(),
                if (count > 0)
                  TextButton(
                    onPressed: () => setState(_keys.clear),
                    child: const Text('مسح'),
                  ),
              ],
            ),
          ),
          // Juz quick navigation — same shape as the student map slider.
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _viewCount,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final isSelected = i == _currentView;
                return GestureDetector(
                  onTap: () => _jumpToView(i),
                  child: Container(
                    width: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? tokens.brand : tokens.surfaceCard,
                      borderRadius: BorderRadius.circular(tokens.radiusSmall),
                      border: Border.all(
                        color:
                            isSelected ? tokens.brand : tokens.borderStructural,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : tokens.textMuted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: PageView.builder(
              controller: _pages,
              itemCount: _viewCount,
              onPageChanged: (view) => setState(() => _currentView = view),
              itemBuilder: (context, view) => _ViewGrid(
                first: _viewRange(view).$1,
                last: _viewRange(view).$2,
                title: 'الجزء ${view + 1}',
                cellBuilder: _cell,
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: AppButton(
                label: 'تم',
                onPressed: () => Navigator.of(context).pop(_selectedUnits),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Page cell shaped like the student map cell (B2): square, page number,
  /// small surah hint and a battery bar showing the selection fraction.
  Widget _cell(BuildContext context, int page) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final units = quranUnitsOfPage(page);
    final total = units.length;
    final selected = _pageSelectedCount(page);
    final full = total > 0 && selected == total;
    final partial = !full && selected > 0;
    final progress = total == 0 ? 0.0 : selected / total;

    final fg = full
        ? Colors.white
        : (partial ? tokens.brandText : tokens.textMuted);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => total > 1 ? _openUnits(page) : _togglePage(page),
      child: Container(
        decoration: BoxDecoration(
          color: full
              ? tokens.brand
              : (partial ? tokens.brandTint : tokens.surfaceCard),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: full
                ? tokens.brand
                : (partial ? tokens.brandBorder : tokens.borderStructural),
            width: full ? 2 : (partial ? 1.5 : 1),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Battery-style fill: selected units fraction.
            if (partial)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 4,
                child: FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: progress,
                  child: Container(height: 4, color: tokens.brandBorder),
                ),
              ),
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$page',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: fg,
                      ),
                    ),
                    if (total > 1)
                      Text(
                        '$total سور',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: full
                              ? Colors.white.withValues(alpha: 0.85)
                              : tokens.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One lazily-built page of the map: a square grid of [first..last] shaped
/// like the student map (7 columns like a mushaf page line).
class _ViewGrid extends StatelessWidget {
  const _ViewGrid({
    required this.first,
    required this.last,
    required this.title,
    required this.cellBuilder,
  });

  final int first;
  final int last;
  final String title;
  final Widget Function(BuildContext context, int page) cellBuilder;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final count = last - first + 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: tokens.info,
                  )),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: count,
              itemBuilder: (context, i) => cellBuilder(context, first + i),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitChecklist extends StatefulWidget {
  const _UnitChecklist({
    required this.page,
    required this.units,
    required this.selectedKeys,
  });

  final int page;
  final List<QuranUnit> units;
  final Set<String> selectedKeys;

  @override
  State<_UnitChecklist> createState() => _UnitChecklistState();
}

class _UnitChecklistState extends State<_UnitChecklist> {
  final Set<String> _keys = {};

  String _key(QuranUnit u) => '${u.page}:${u.partIndex}';

  @override
  void initState() {
    super.initState();
    _keys.addAll(widget.selectedKeys);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final allChecked = widget.units.every((u) => _keys.contains(_key(u)));
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('صفحة ${widget.page} — ${widget.units.length} وحدات',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'هذه الصفحة تضم أكثر من سورة (BR-502). اختر الوحدات المطلوبة.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: tokens.textMuted),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('تحديد الكل'),
            value: allChecked,
            onChanged: (v) => setState(() {
              if (v == true) {
                for (final u in widget.units) {
                  _keys.add(_key(u));
                }
              } else {
                for (final u in widget.units) {
                  _keys.remove(_key(u));
                }
              }
            }),
          ),
          const Divider(),
          for (final u in widget.units)
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text('${u.surah} — الوحدة ${u.partIndex}'),
              value: _keys.contains(_key(u)),
              onChanged: (v) => setState(() {
                if (v == true) {
                  _keys.add(_key(u));
                } else {
                  _keys.remove(_key(u));
                }
              }),
            ),
          const SizedBox(height: 8),
          AppButton(
            label: 'تم',
            onPressed: () => Navigator.of(context).pop(_keys),
          ),
        ],
      ),
    );
  }
}
