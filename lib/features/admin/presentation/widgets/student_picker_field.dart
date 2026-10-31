import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/adaptive_sheet.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';

/// Reusable student lookup field (BR-627): paginated server search by
/// name / id / barcode / phone + a barcode-scan button.
class StudentPickerField extends StatefulWidget {
  const StudentPickerField({
    super.key,
    required this.onChanged,
    this.selected,
    this.excludeIds = const {},
    this.label = 'الطالب',
  });

  final ValueChanged<AdminStudentRow?> onChanged;
  final AdminStudentRow? selected;
  final Set<int> excludeIds;
  final String label;

  @override
  State<StudentPickerField> createState() => _StudentPickerFieldState();
}

class _StudentPickerFieldState extends State<StudentPickerField> {
  Future<void> _open() async {
    final picker = await showAppSheet<AdminStudentRow>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _StudentPickerSheet(
        selected: widget.selected,
        excludeIds: widget.excludeIds,
      ),
    );
    if (picker != null) {
      widget.onChanged(picker);
    }
  }

  Future<void> _scan() async {
    final code = await context.push<String>('/admin/scan-student');
    if (code == null || !mounted) return;
    try {
      final page = await AdminRepositoryScope.of(
        context,
      ).studentsPage(query: code.trim(), pageSize: 20);
      final match = page.items
          .where((s) => s.barcode.toLowerCase() == code.trim().toLowerCase())
          .firstOrNull;
      if (match == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('لا يوجد طالب بالباركود $code')));
        return;
      }
      widget.onChanged(match);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذّر البحث: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final selected = widget.selected;
    return Row(
      children: [
        Expanded(
          child: InkWell(
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
                  if (selected == null)
                    Icon(
                      Icons.person_search_outlined,
                      size: 20,
                      color: tokens.textMuted,
                    )
                  else ...[
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: tokens.brandTint,
                      child: Text(
                        selected.name.characters.first,
                        style: TextStyle(
                          color: tokens.brandText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selected.name,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          if (selected.teamNames.isNotEmpty)
                            Text(
                              selected.teamNames,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: tokens.textMuted),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (selected == null) ...[
                    const SizedBox(width: 10),
                    Text(
                      widget.label,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: tokens.textMuted),
                    ),
                  ],
                  const Spacer(),
                  Icon(Icons.arrow_drop_down, color: tokens.textMuted),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'مسح باركود',
          style: IconButton.styleFrom(
            backgroundColor: tokens.brandTint,
            foregroundColor: tokens.brandText,
            minimumSize: const Size(56, 56),
          ),
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: _scan,
        ),
      ],
    );
  }
}

class _StudentPickerSheet extends StatefulWidget {
  const _StudentPickerSheet({this.selected, this.excludeIds = const {}});

  final AdminStudentRow? selected;
  final Set<int> excludeIds;

  @override
  State<_StudentPickerSheet> createState() => _StudentPickerSheetState();
}

class _StudentPickerSheetState extends State<_StudentPickerSheet> {
  final _search = TextEditingController();
  final _items = <AdminStudentRow>[];
  int _page = 1;
  int _requestId = 0;
  bool _hasMore = true;
  bool _loading = true;
  bool _loadingMore = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({required bool reset}) async {
    final requestId = ++_requestId;
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _items.clear();
        _page = 1;
        _hasMore = true;
      });
    } else {
      if (_loadingMore || !_hasMore) return;
      setState(() => _loadingMore = true);
    }
    try {
      final result = await AdminRepositoryScope.of(
        context,
      ).studentsPage(query: _search.text, page: _page, pageSize: 30);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _items.addAll(
          result.items.where((s) => !widget.excludeIds.contains(s.id)),
        );
        _hasMore = result.hasMore;
        _page = result.page + 1;
        _loading = false;
        _loadingMore = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: TextField(
              controller: _search,
              autofocus: true,
              onChanged: (_) => _load(reset: true),
              decoration: const InputDecoration(
                hintText: 'بحث: اسم / معرّف / باركود / هاتف',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(child: _body(context, controller, tokens)),
        ],
      ),
    );
  }

  Widget _body(
    BuildContext context,
    ScrollController controller,
    AppTokens tokens,
  ) {
    if (_loading && _items.isEmpty) return const AppLoadingView();
    if (_error != null && _items.isEmpty) {
      return AppErrorView(error: _error, onRetry: () => _load(reset: true));
    }
    if (_items.isEmpty) {
      return const Center(child: Text('لا نتائج'));
    }
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= _items.length) {
          _load(reset: false);
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final student = _items[i];
        final selected = student.id == widget.selected?.id;
        return ListTile(
          selected: selected,
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: tokens.brandTint,
            child: Text(
              student.name.characters.first,
              style: TextStyle(
                color: tokens.brandText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          title: Text(student.name),
          subtitle: Text(
            [
              if (student.teamNames.isNotEmpty) student.teamNames,
              student.barcode,
            ].join(' · '),
          ),
          trailing: selected
              ? const Icon(Icons.check_circle, color: Color(0xFF00A572))
              : Icon(Icons.chevron_left, color: tokens.borderStructural),
          onTap: () => Navigator.of(context).pop(student),
        );
      },
    );
  }
}
