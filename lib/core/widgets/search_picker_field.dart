import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

/// Generic searchable picker field (no barcode): opens a bottom sheet with a
/// tolerant search over [items] and a lazy list (scales to large collections).
/// Used for teachers, subjects, teams and matns.
class SearchPickerField<T> extends StatelessWidget {
  const SearchPickerField({
    super.key,
    required this.items,
    required this.label,
    required this.titleBuilder,
    required this.subtitleBuilder,
    required this.value,
    required this.onChanged,
    this.emptyLabel = 'لا عناصر',
  });

  final List<T> items;
  final String label;
  final String Function(T item) titleBuilder;
  final String? Function(T item)? subtitleBuilder;
  final T? value;
  final ValueChanged<T> onChanged;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return InkWell(
      borderRadius: BorderRadius.circular(tokens.radiusSmall),
      onTap: () => _open(context),
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
            Icon(Icons.manage_search, size: 20, color: tokens.brandText),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value == null ? label : titleBuilder(value as T),
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: value == null ? tokens.textMuted : tokens.textPrimary,
                  fontWeight: value == null ? FontWeight.w400 : FontWeight.w700,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: tokens.textMuted),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final result = await showAppSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _SearchPickerSheet<T>(
        items: items,
        titleBuilder: titleBuilder,
        subtitleBuilder: subtitleBuilder,
        value: value,
        label: label,
        emptyLabel: emptyLabel,
      ),
    );
    if (result != null) onChanged(result);
  }
}

class _SearchPickerSheet<T> extends StatefulWidget {
  const _SearchPickerSheet({
    required this.items,
    required this.titleBuilder,
    required this.subtitleBuilder,
    required this.value,
    required this.label,
    required this.emptyLabel,
  });

  final List<T> items;
  final String Function(T item) titleBuilder;
  final String? Function(T item)? subtitleBuilder;
  final T? value;
  final String label;
  final String emptyLabel;

  @override
  State<_SearchPickerSheet<T>> createState() => _SearchPickerSheetState<T>();
}

class _SearchPickerSheetState<T> extends State<_SearchPickerSheet<T>> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final q = _search.text.trim().toLowerCase();
    final results = q.isEmpty
        ? widget.items
        : widget.items
              .where(
                (i) =>
                    widget.titleBuilder(i).toLowerCase().contains(q) ||
                    (widget.subtitleBuilder?.call(i) ?? '')
                        .toLowerCase()
                        .contains(q),
              )
              .toList();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: TextField(
              controller: _search,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'بحث في ${widget.label}',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? Center(child: Text(widget.emptyLabel))
                : ListView.builder(
                    controller: controller,
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final item = results[i];
                      final selected = item == widget.value;
                      final subtitle = widget.subtitleBuilder?.call(item);
                      return ListTile(
                        selected: selected,
                        title: Text(widget.titleBuilder(item)),
                        subtitle: subtitle == null || subtitle.isEmpty
                            ? null
                            : Text(subtitle),
                        trailing: selected
                            ? const Icon(
                                Icons.check_circle,
                                color: Color(0xFF00A572),
                              )
                            : Icon(
                                Icons.chevron_left,
                                color: tokens.borderStructural,
                              ),
                        onTap: () => Navigator.of(context).pop(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
