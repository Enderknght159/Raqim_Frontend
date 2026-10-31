import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/responsive_grid.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

/// E9 — Content assets: matn · subjects · distributables (editable/deletable).
class AdminAssetsScreen extends StatefulWidget {
  const AdminAssetsScreen({super.key});

  @override
  State<AdminAssetsScreen> createState() => _AdminAssetsScreenState();
}

class _AdminAssetsScreenState extends State<AdminAssetsScreen> {
  late Future<List<List<AdminContentItem>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<List<AdminContentItem>>> _load() async {
    final repo = AdminRepositoryScope.of(context);
    return [
      await repo.matns(),
      await repo.subjects(),
      await repo.distributables(),
    ];
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AsyncView<List<List<AdminContentItem>>>(
      future: _future,
      cacheKey: 'admin-assets',
      builder: (context, lists) => Scaffold(
        appBar: AppBar(title: const Text('المحتوى')),
        body: ResponsivePage(
          maxWidth: 1100,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _section(
                'المتون',
                lists[0],
                () => _addMatn(),
                onEdit: (item) => _editMatn(item),
                onDelete: _deleteMatn,
              ),
              _section(
                'المواد',
                lists[1],
                () => _addSimple('مادة'),
                onEdit: (item) => _editSimple('مادة', item),
                onDelete: _deleteSubject,
              ),
              _section(
                'الموزّعات',
                lists[2],
                () => _addSimple('موزّع'),
                onEdit: (item) => _editSimple('موزّع', item),
                onDelete: _deleteDistributable,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(
    String title,
    List<AdminContentItem> items,
    VoidCallback onAdd, {
    required ValueChanged<AdminContentItem> onEdit,
    required Future<void> Function(AdminContentItem) onDelete,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          icon: Icons.list_alt_outlined,
          title: title,
          trailing: TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('إضافة'),
          ),
        ),
        const SizedBox(height: 6),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'لا عناصر',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          ResponsiveGrid(
            minItemWidth: 280,
            maxColumns: 3,
            children: [
              for (final it in items)
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  onTap: () => onEdit(it),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(it.name),
                        ),
                      ),
                      if ((it.subtitle ?? '').isNotEmpty)
                        Flexible(
                          child: Text(
                            it.subtitle!,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: tokens.textMuted),
                          ),
                        ),
                      const SizedBox(width: 6),
                      IconButton(
                        tooltip: 'حذف',
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: tokens.dangerText,
                        onPressed: () => onDelete(it),
                      ),
                      Icon(Icons.chevron_left, color: tokens.borderStructural),
                    ],
                  ),
                ),
            ],
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<bool> _confirmDelete(String label) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف $label'),
        content: const Text('لا يمكن التراجع عن الحذف. متابعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    return confirm == true;
  }

  Future<void> _deleteMatn(AdminContentItem item) async {
    if (!await _confirmDelete('المتن «${item.name}»')) return;
    if (!mounted) return;
    await AdminRepositoryScope.of(context).deleteMatn(item.id);
    if (!mounted) return;
    _reload();
  }

  Future<void> _deleteSubject(AdminContentItem item) async {
    if (!await _confirmDelete('المادة «${item.name}»')) return;
    if (!mounted) return;
    await AdminRepositoryScope.of(context).deleteSubject(item.id);
    if (!mounted) return;
    _reload();
  }

  Future<void> _deleteDistributable(AdminContentItem item) async {
    if (!await _confirmDelete('الموزّع «${item.name}»')) return;
    if (!mounted) return;
    await AdminRepositoryScope.of(context).deleteDistributable(item.id);
    if (!mounted) return;
    _reload();
  }

  Future<void> _addMatn() async {
    await _matnSheet();
    if (!mounted) return;
    _reload();
  }

  Future<void> _editMatn(AdminContentItem item) async {
    final repo = AdminRepositoryScope.of(context);
    final name = TextEditingController(text: item.name);
    var pointsPerVerse = 1;
    var totalVerses = 10;
    // Parse the subtitle note to prefill points/verses when possible.
    final match = RegExp(
      r'(\d+) نقطة/بيت · (\d+) بيت',
    ).firstMatch(item.subtitle ?? '');
    if (match != null) {
      pointsPerVerse = int.tryParse(match.group(1)!) ?? 1;
      totalVerses = int.tryParse(match.group(2)!) ?? 10;
    }
    final points = TextEditingController(text: '$pointsPerVerse');
    final verses = TextEditingController(text: '$totalVerses');
    await showAppSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 0,
          bottom: 28 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('تعديل المتن', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'الاسم'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: points,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'نقاط/بيت'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: verses,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'عدد الأبيات'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'حفظ',
              onPressed: () async {
                if (name.text.trim().isEmpty) return;
                await repo.updateMatn(
                  item.id,
                  name.text.trim(),
                  int.tryParse(points.text) ?? 1,
                  int.tryParse(verses.text) ?? 10,
                );
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    _reload();
  }

  Future<void> _editSimple(String kind, AdminContentItem item) async {
    final repo = AdminRepositoryScope.of(context);
    final name = TextEditingController(text: item.name);
    final note = TextEditingController(text: item.subtitle ?? '');
    await showAppSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 0,
          bottom: 28 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('تعديل $kind', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'الاسم'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: note,
              decoration: InputDecoration(
                labelText: kind == 'مادة' ? 'الكتاب' : 'ملاحظة',
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'حفظ',
              onPressed: () async {
                if (name.text.trim().isEmpty) return;
                final noteValue = note.text.trim().isEmpty
                    ? null
                    : note.text.trim();
                if (kind == 'مادة') {
                  await repo.updateSubject(
                    item.id,
                    name.text.trim(),
                    noteValue,
                  );
                } else {
                  await repo.updateDistributable(
                    item.id,
                    name.text.trim(),
                    noteValue,
                  );
                }
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    _reload();
  }

  Future<void> _matnSheet() async {
    final repo = AdminRepositoryScope.of(context);
    final name = TextEditingController();
    final points = TextEditingController(text: '1');
    final verses = TextEditingController(text: '10');
    await showAppSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 0,
          bottom: 28 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('متن جديد', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'الاسم'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: points,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'نقاط/بيت'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: verses,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'عدد الأبيات'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'إضافة',
              onPressed: () async {
                if (name.text.trim().isEmpty) return;
                await repo.addMatn(
                  name.text.trim(),
                  int.tryParse(points.text) ?? 1,
                  int.tryParse(verses.text) ?? 10,
                );
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addSimple(String kind) async {
    final repo = AdminRepositoryScope.of(context);
    final name = TextEditingController();
    final note = TextEditingController();
    await showAppSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 0,
          bottom: 28 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('$kind جديد', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'الاسم'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: note,
              decoration: const InputDecoration(labelText: 'ملاحظة'),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'إضافة',
              onPressed: () async {
                if (name.text.trim().isEmpty) return;
                if (kind == 'مادة') {
                  await repo.addSubject(
                    name.text.trim(),
                    note.text.trim().isEmpty ? null : note.text.trim(),
                  );
                } else {
                  await repo.addDistributable(
                    name.text.trim(),
                    note.text.trim().isEmpty ? null : note.text.trim(),
                  );
                }
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    _reload();
  }
}
