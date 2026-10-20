import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';

/// Reusable student lookup field (BR-627): tolerant auto-search by
/// name / id / barcode / team + a barcode-scan button. Emits the picked
/// [AdminStudentRow] via [onChanged].
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
  List<AdminStudentRow> _students = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final students = await AdminRepositoryScope.of(context).students();
    if (!mounted) return;
    setState(() {
      _students = students
          .where((s) => !widget.excludeIds.contains(s.id))
          .toList();
      _loading = false;
    });
  }

  Future<void> _open() async {
    final picker = await showModalBottomSheet<AdminStudentRow>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _StudentPickerSheet(
        students: _students,
        selected: widget.selected,
      ),
    );
    if (picker != null) {
      widget.onChanged(picker);
    }
  }

  Future<void> _scan() async {
    final code = await context.push<String>('/admin/scan-student');
    if (code == null || !mounted) return;
    final match = _students
        .where((s) => s.barcode.toLowerCase() == code.trim().toLowerCase())
        .firstOrNull;
    if (match == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لا يوجد طالب بالباركود $code')),
      );
      return;
    }
    widget.onChanged(match);
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
                    Icon(Icons.person_search_outlined,
                        size: 20, color: tokens.textMuted)
                  else ...[
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: tokens.brandTint,
                      child: Text(selected.name.characters.first,
                          style: TextStyle(
                              color: tokens.brandText,
                              fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selected.name,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          if (selected.teamNames.isNotEmpty)
                            Text(selected.teamNames,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: tokens.textMuted)),
                        ],
                      ),
                    ),
                  ],
                  if (selected == null) ...[
                    const SizedBox(width: 10),
                    Text(
                      _loading ? 'جارِ التحميل…' : widget.label,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: tokens.textMuted),
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
  const _StudentPickerSheet({required this.students, this.selected});

  final List<AdminStudentRow> students;
  final AdminStudentRow? selected;

  @override
  State<_StudentPickerSheet> createState() => _StudentPickerSheetState();
}

class _StudentPickerSheetState extends State<_StudentPickerSheet> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final results = widget.students
        .where((s) => studentMatchesQuery(s, _search.text))
        .toList();
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
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'بحث: اسم / معرّف / باركود / حلقة',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(child: Text('لا نتائج'))
                : ListView.builder(
                    controller: controller,
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final s = results[i];
                      final selected = s.id == widget.selected?.id;
                      return ListTile(
                        selected: selected,
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: tokens.brandTint,
                          child: Text(s.name.characters.first,
                              style: TextStyle(
                                  color: tokens.brandText,
                                  fontWeight: FontWeight.w800)),
                        ),
                        title: Text(s.name),
                        subtitle: Text(
                          [
                            if (s.teamNames.isNotEmpty) s.teamNames,
                            s.barcode,
                          ].join(' · '),
                        ),
                        trailing: selected
                            ? const Icon(Icons.check_circle,
                                color: Color(0xFF00A572))
                            : Icon(Icons.chevron_left,
                                color: tokens.borderStructural),
                        onTap: () => Navigator.of(context).pop(s),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
