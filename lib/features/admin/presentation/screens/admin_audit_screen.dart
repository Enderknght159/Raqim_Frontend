import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/date_grouped_list.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/icon_tile.dart';
import '../admin_shell.dart';

/// E13 — Audit log (trial: derived recent writes; restore needs the server).
/// Grouped by date with kind filter + free search.
class AdminAuditScreen extends StatefulWidget {
  const AdminAuditScreen({super.key});

  @override
  State<AdminAuditScreen> createState() => _AdminAuditScreenState();
}

typedef _Write = ({String model, String action, String description, DateTime when, int recordId});

class _AdminAuditScreenState extends State<AdminAuditScreen> {
  late Future<List<_Write>> _future;
  final _search = TextEditingController();
  String? _modelFilter;

  @override
  void initState() {
    super.initState();
    _future = AdminRepositoryScope.of(context).recentWrites();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Scaffold(
      appBar: AppBar(title: const Text('التدقيق')),
      body: AsyncView<List<_Write>>(
        future: _future,
        builder: (context, writes) {
          if (writes.isEmpty) {
            return const EmptyState(
              title: 'لا سجلات',
              icon: Icons.history_outlined,
              message: 'لا توجد كتابات بعد',
            );
          }
          final models = writes.map((w) => w.model).toSet().toList();
          final q = _search.text.trim().toLowerCase();
          final visible = writes.where((w) {
            if (_modelFilter != null && w.model != _modelFilter) return false;
            if (q.isEmpty) return true;
            return w.description.toLowerCase().contains(q) ||
                w.model.toLowerCase().contains(q);
          }).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'بحث في السجل',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    ChoiceChip(
                      label: const Text('الكل'),
                      selected: _modelFilter == null,
                      onSelected: (_) => setState(() => _modelFilter = null),
                    ),
                    const SizedBox(width: 8),
                    for (final m in models) ...[
                      ChoiceChip(
                        label: Text(_modelLabel(m)),
                        selected: _modelFilter == m,
                        onSelected: (_) =>
                            setState(() => _modelFilter = m),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: visible.isEmpty
                    ? const Center(child: Text('لا نتائج'))
                    : DateGroupedList<_Write>(
                        items: visible,
                        dateOf: (w) => w.when,
                        itemBuilder: (context, w) =>
                            _row(context, w, tokens),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(BuildContext context, _Write w, AppTokens tokens) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            IconTile(icon: _icon(w.model), color: tokens.info, size: 40, iconSize: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(w.description,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Text('${_modelLabel(w.model)} · ${w.action}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: tokens.textMuted)),
                ],
              ),
            ),
            IconButton(
              tooltip: 'استرجاع',
              icon: const Icon(Icons.restore, size: 20),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('الاسترجاع يتطلب الخادم (مؤجّل تجريبيًا)')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _icon(String model) => switch (model) {
        'Attendance' => Icons.schedule,
        'Memorization' => Icons.menu_book,
        'Transaction' => Icons.payments_outlined,
        _ => Icons.edit_note,
      };

  String _modelLabel(String model) => switch (model) {
        'Attendance' => 'الحضور',
        'Memorization' => 'الحفظ',
        'Transaction' => 'المعاملات',
        _ => model,
      };
}
