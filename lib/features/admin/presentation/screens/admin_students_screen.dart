import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/search_picker_field.dart';
import '../../../student/presentation/widgets/qr_code_view.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';

/// Students list (E6 → list): search (name/id/barcode/team) + rows with
/// barcode preview → student profile (E7). Rich create form opens the new
/// student's profile on success.
class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  final _search = TextEditingController();
  late Future<List<AdminStudentRow>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<List<AdminStudentRow>> _load() =>
      AdminRepositoryScope.of(context).students(query: _search.text);

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلاب'),
        actions: [
          IconButton(
            tooltip: 'إضافة طالب',
            icon: const Icon(Icons.person_add_alt),
            onPressed: _addStudent,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              onChanged: (_) => _reload(),
              decoration: const InputDecoration(
                hintText: 'بحث: اسم / معرّف / باركود / حلقة',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: AsyncView<List<AdminStudentRow>>(
              future: _future,
              builder: (context, students) {
                if (students.isEmpty) {
                  return const EmptyState(
                    title: 'لا طلاب',
                    icon: Icons.groups_outlined,
                    message: 'أضف أول طالب',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: students.length,
                  itemBuilder: (context, i) =>
                      _StudentRowTile(student: students[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addStudent() async {
    final repo = AdminRepositoryScope.of(context);
    final name = TextEditingController();
    final father = TextEditingController();
    final year = TextEditingController();
    final phone = TextEditingController();
    final teams = await repo.teams();
    if (!mounted) return;
    int? teamId;
    final created = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
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
              Text('طالب جديد', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              TextField(
                  controller: name,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'الاسم')),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                        controller: father,
                        textInputAction: TextInputAction.next,
                        decoration:
                            const InputDecoration(labelText: 'اسم الأب')),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                        controller: year,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                            labelText: 'سنة الميلاد')),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                  ],
                  decoration: const InputDecoration(
                      labelText: 'رقم ولي الأمر (اختياري)')),
              const SizedBox(height: 12),
              SearchPickerField<AdminTeamRow>(
                label: 'اختر الحلقة (اختياري)',
                items: teams,
                titleBuilder: (t) => t.name,
                subtitleBuilder: (t) =>
                    '${t.typeName} · ${t.studentsCount} طالب',
                value: teamId == null
                    ? null
                    : teams.where((t) => t.id == teamId).firstOrNull,
                onChanged: (t) => setSheetState(() => teamId = t.id),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'إنشاء',
                onPressed: () async {
                  final trimmed = name.text.trim();
                  if (trimmed.isEmpty) return;
                  final id = await repo.addStudent(
                    name: trimmed,
                    fatherName: father.text.trim().isEmpty
                        ? null
                        : father.text.trim(),
                    yearOfBirth: int.tryParse(year.text),
                    teamId: teamId,
                    phone: phone.text.trim(),
                  );
                  if (context.mounted) Navigator.of(context).pop(id);
                },
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    if (created != null) {
      context.push('/admin/students/$created');
    }
    _reload();
  }
}

class _StudentRowTile extends StatelessWidget {
  const _StudentRowTile({required this.student});

  final AdminStudentRow student;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        onTap: () => context.push('/admin/students/${student.id}'),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: tokens.brandTint,
              child: Text(student.name.characters.first,
                  style: TextStyle(
                      color: tokens.brandText, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  Text(
                    [
                      if (student.teamNames.isNotEmpty) student.teamNames,
                      if (student.yearOfBirth != null)
                        'ميلاد ${student.yearOfBirth}',
                    ].join(' · '),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: tokens.textMuted),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  student.barcode,
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: tokens.info),
                ),
                if (!student.active)
                  Text('معطّل',
                      style: TextStyle(color: tokens.dangerText, fontSize: 12)),
              ],
            ),
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'عرض الباركود',
              icon: const Icon(Icons.qr_code_2, size: 20),
              color: tokens.brandText,
              onPressed: () => _showBarcode(context),
            ),
            Icon(Icons.chevron_left, color: tokens.borderStructural),
          ],
        ),
      ),
    );
  }

  void _showBarcode(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('باركود ${student.name}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            QrCodeCard(code: student.barcode, size: 180),
            const SizedBox(height: 8),
            Text(
              student.barcode,
              textDirection: TextDirection.ltr,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).extension<AppTokens>()!.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
