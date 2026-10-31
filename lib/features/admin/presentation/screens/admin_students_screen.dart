import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/adaptive_data_table.dart';
import '../../../../core/widgets/adaptive_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/search_picker_field.dart';
import '../../../student/presentation/widgets/qr_code_view.dart';
import '../../domain/admin_models.dart';
import '../../../../shared/permissions.dart';
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
  final _scroll = ScrollController();
  Timer? _debounce;
  final _items = <AdminStudentRow>[];
  int _page = 1;
  int _requestId = 0;
  bool _hasMore = true;
  bool _loading = true;
  bool _loadingMore = false;
  bool _refreshing = false;
  Object? _error;
  Object? _loadMoreError;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({required bool reset}) async {
    final requestId = ++_requestId;
    if (!mounted) return;
    if (reset) {
      setState(() {
        _loading = _items.isEmpty;
        _refreshing = _items.isNotEmpty;
        _error = null;
        _loadMoreError = null;
        _page = 1;
        _hasMore = true;
      });
    } else {
      if (_loadingMore || !_hasMore) return;
      setState(() {
        _loadingMore = true;
        _loadMoreError = null;
      });
    }

    final repo = AdminRepositoryScope.of(context);
    final fetchPage = reset ? 1 : _page;
    if (reset) {
      try {
        final cached = await repo.studentsPageCached(
          query: _search.text,
          page: 1,
          pageSize: 30,
        );
        if (!mounted || requestId != _requestId) return;
        if (cached != null && cached.items.isNotEmpty) {
          setState(() {
            _items
              ..clear()
              ..addAll(cached.items);
            _hasMore = cached.hasMore;
            _loading = false;
            _refreshing = true;
          });
        }
      } catch (_) {
        // Cache is a best-effort optimization.
      }
    }

    try {
      final result = await repo
          .studentsPage(query: _search.text, page: fetchPage, pageSize: 30)
          .timeout(const Duration(seconds: 20));
      if (!mounted || requestId != _requestId) return;
      setState(() {
        if (reset) {
          _items
            ..clear()
            ..addAll(result.items);
        } else {
          _items.addAll(result.items);
        }
        _hasMore = result.hasMore;
        _page = result.page + 1;
        _loading = false;
        _loadingMore = false;
        _refreshing = false;
        _error = null;
        _loadMoreError = null;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _refreshing = false;
        if (reset && _items.isEmpty) {
          _error = error;
        } else {
          _loadMoreError = error;
        }
      });
    }
  }

  void _onScroll() {
    if (!_scroll.hasClients || _loadMoreError != null) return;
    if (_scroll.position.maxScrollExtent <= 0) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 240) {
      _load(reset: false);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _load(reset: true);
    });
  }

  void _reload() => _load(reset: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلاب'),
        actions: [
          if (canEditModule(context, 'students'))
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
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'ابحث: اسم / هاتف / باركود / حلقة',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 3,
            child: _refreshing
                ? LinearProgressIndicator(
                    minHeight: 3,
                    color: Theme.of(context).extension<AppTokens>()!.brand,
                    backgroundColor: Theme.of(
                      context,
                    ).extension<AppTokens>()!.surfaceSubtle,
                  )
                : null,
          ),
          Expanded(child: _body(context)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading && _items.isEmpty) return const AppLoadingView();
    if (_error != null && _items.isEmpty) {
      return AppErrorView(error: _error, onRetry: _reload);
    }
    if (_items.isEmpty) {
      return const EmptyState(
        title: 'لا طلاب',
        icon: Icons.groups_outlined,
        message: 'أضف أول طالب',
      );
    }
    final footer = _footer(context);
    return AdaptiveDataTable(
      table: ListView(
        controller: _scroll,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          AppDataTable(
            columns: const [
              DataColumn(label: Text('الطالب')),
              DataColumn(label: Text('الحلقة')),
              DataColumn(label: Text('الباركود')),
              DataColumn(label: Text('الحالة')),
              DataColumn(label: Text('')),
            ],
            rows: [
              for (final student in _items)
                DataRow(
                  onSelectChanged: (_) =>
                      context.push('/admin/students/${student.id}'),
                  cells: [
                    DataCell(Text(student.name)),
                    DataCell(Text(student.teamNames)),
                    DataCell(
                      Text(student.barcode, textDirection: TextDirection.ltr),
                    ),
                    DataCell(
                      Text(
                        student.active ? 'نشط' : 'معطّل',
                        style: TextStyle(
                          color: student.active
                              ? Theme.of(
                                  context,
                                ).extension<AppTokens>()!.brandText
                              : Theme.of(
                                  context,
                                ).extension<AppTokens>()!.dangerText,
                        ),
                      ),
                    ),
                    DataCell(
                      IconButton(
                        tooltip: 'عرض الباركود',
                        icon: const Icon(Icons.qr_code_2, size: 20),
                        onPressed: () => _showStudentBarcode(context, student),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          footer,
        ],
      ),
      cards: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _items.length + 1,
        itemBuilder: (context, i) {
          if (i >= _items.length) return _footer(context);
          return _StudentRowTile(student: _items[i]);
        },
      ),
    );
  }

  Widget _footer(BuildContext context) {
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: AppLoadingDots(size: 8, spacing: 6)),
      );
    }
    if (_loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            const Text('تعذّر تحميل المزيد'),
            TextButton.icon(
              onPressed: () => _load(reset: false),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }
    if (!_hasMore) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: TextButton.icon(
          onPressed: () => _load(reset: false),
          icon: const Icon(Icons.expand_more, size: 18),
          label: const Text('تحميل المزيد'),
        ),
      ),
    );
  }

  void _showStudentBarcode(BuildContext context, AdminStudentRow student) {
    showAppSheet<void>(
      context: context,
      maxWidth: 420,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'باركود ${student.name}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            QrCodeCard(code: student.barcode, size: 180),
            const SizedBox(height: 8),
            Text(
              student.barcode,
              textDirection: TextDirection.ltr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).extension<AppTokens>()!.textMuted,
              ),
            ),
          ],
        ),
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
    final created = await showAppSheet<int>(
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
                decoration: const InputDecoration(labelText: 'الاسم'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: father,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'اسم الأب'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: year,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'سنة الميلاد',
                      ),
                    ),
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
                  labelText: 'رقم ولي الأمر (اختياري)',
                ),
              ),
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
              child: Text(
                student.name.characters.first,
                style: TextStyle(
                  color: tokens.brandText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    [
                      if (student.teamNames.isNotEmpty) student.teamNames,
                      if (student.yearOfBirth != null)
                        'ميلاد ${student.yearOfBirth}',
                    ].join(' · '),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.info),
                ),
                if (!student.active)
                  Text(
                    'معطّل',
                    style: TextStyle(color: tokens.dangerText, fontSize: 12),
                  ),
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
    showAppSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'باركود ${student.name}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            QrCodeCard(code: student.barcode, size: 180),
            const SizedBox(height: 8),
            Text(
              student.barcode,
              textDirection: TextDirection.ltr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).extension<AppTokens>()!.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
