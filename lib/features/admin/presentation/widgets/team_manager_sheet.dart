import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/admin_repository.dart';
import '../../domain/admin_models.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

/// Opens the team members manager (E8): preview/remove with multi-select +
/// add via tolerant search. Saves on close. Reused by the teams screen and
/// the admin student profile (tap a team chip).
Future<void> showTeamManagerSheet(
  BuildContext context,
  AdminTeamRow team, {
  required AdminRepository repository,
}) {
  return showAppSheet<void>(
    context: context,
    maxWidth: 640,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => TeamManagerSheet(team: team, repo: repository),
  );
}

/// Team members manager: two modes (preview/remove with multi-select +
/// add via tolerant search).
class TeamManagerSheet extends StatefulWidget {
  const TeamManagerSheet({super.key, required this.team, required this.repo});

  final AdminTeamRow team;
  final AdminRepository repo;

  @override
  State<TeamManagerSheet> createState() => _TeamManagerSheetState();
}

class _TeamManagerSheetState extends State<TeamManagerSheet> {
  final _search = TextEditingController();
  List<AdminStudentRow> _members = const [];
  List<TeacherCandidate> _teacherCandidates = const [];
  Set<int> _selected = {};
  final Map<int, AdminStudentRow> _selectedRows = {};
  bool _adding = false;
  bool _loading = true;

  final _searchResults = <AdminStudentRow>[];
  int _searchPage = 1;
  int _searchRequestId = 0;
  bool _searchHasMore = true;
  bool _searchLoading = false;
  bool _searchLoadingMore = false;
  Object? _searchError;
  Timer? _debounce;
  late String _teacherName = widget.team.teacherName;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final membersF = widget.repo.teamStudents(widget.team.id);
    final candidatesF = widget.repo.teacherCandidates();
    final members = await membersF;
    final candidates = await candidatesF;
    if (!mounted) return;
    setState(() {
      _members = members;
      _teacherCandidates = candidates;
      _loading = false;
    });
  }

  Future<void> _searchStudents({required bool reset}) async {
    final requestId = ++_searchRequestId;
    if (reset) {
      setState(() {
        _searchLoading = true;
        _searchError = null;
        _searchResults.clear();
        _searchPage = 1;
        _searchHasMore = true;
      });
    } else {
      if (_searchLoadingMore || !_searchHasMore) return;
      setState(() => _searchLoadingMore = true);
    }
    try {
      final page = await widget.repo.studentsPage(
        query: _search.text,
        page: _searchPage,
        pageSize: 30,
      );
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _searchResults.addAll(page.items);
        _searchHasMore = page.hasMore;
        _searchPage = page.page + 1;
        _searchLoading = false;
        _searchLoadingMore = false;
      });
    } catch (error) {
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _searchLoading = false;
        _searchLoadingMore = false;
        _searchError = error;
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchStudents(reset: true);
    });
  }

  List<AdminStudentRow> get _candidates {
    final memberIds = _members.map((m) => m.id).toSet();
    return _searchResults.where((s) => !memberIds.contains(s.id)).toList();
  }

  Future<void> _removeSelected() async {
    await widget.repo.removeStudentsFromTeam(
      widget.team.id,
      _selected.toList(),
    );
    if (!mounted) return;
    setState(() {
      _members = _members.where((m) => !_selected.contains(m.id)).toList();
      _selected = {};
      _selectedRows.clear();
    });
  }

  Future<void> _addSelected() async {
    await widget.repo.addStudentsToTeam(widget.team.id, _selected.toList());
    if (!mounted) return;
    final added = _selectedRows.values
        .where((s) => _selected.contains(s.id))
        .toList();
    setState(() {
      _members = [..._members, ...added]
        ..sort((a, b) => a.name.compareTo(b.name));
      _selected = {};
      _selectedRows.clear();
    });
  }

  /// Change the team teacher at any time (any existing account).
  Future<void> _editTeacher() async {
    final result = await showAppSheet<Object>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _TeacherPickerSheet(
        candidates: _teacherCandidates,
        selected: _teacherName,
      ),
    );
    if (result == null || !mounted) return;
    try {
      if (result is String && result.isEmpty) {
        await widget.repo.removeTeamTeacher(widget.team.id);
      } else if (result is TeacherCandidate) {
        await widget.repo.setTeamTeacherById(widget.team.id, result.userId);
      } else {
        return;
      }
      if (!mounted) return;
      // The assignment may create a teacher row; refresh the resolved name.
      final teams = await widget.repo.teams();
      final updated = teams.where((t) => t.id == widget.team.id).firstOrNull;
      if (!mounted) return;
      setState(() => _teacherName = updated?.teacherName ?? '');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذّر تعديل معلم الحلقة: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    if (_loading) {
      return const AppLoadingView();
    }
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.team.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${widget.team.typeName} · '
                        '${_teacherName.isEmpty ? 'بلا معلم' : _teacherName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: '${_members.length} طالب',
                  color: tokens.infoLight,
                ),
              ],
            ),
          ),
          // Teacher can be changed at any time (any existing account).
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: InkWell(
              borderRadius: BorderRadius.circular(tokens.radiusSmall),
              onTap: _editTeacher,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: tokens.surfaceSubtle,
                  borderRadius: BorderRadius.circular(tokens.radiusSmall),
                  border: Border.all(color: tokens.borderStructural),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 18,
                      color: tokens.accentMatn,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _teacherName.isEmpty
                            ? 'تعيين معلم للحلقة'
                            : 'المعلم: $_teacherName',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _teacherName.isEmpty
                              ? tokens.textMuted
                              : tokens.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: tokens.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('الطلاب'),
                    selected: !_adding,
                    onSelected: (_) => setState(() {
                      _adding = false;
                      _selected = {};
                      _selectedRows.clear();
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('إضافة طلاب'),
                    selected: _adding,
                    onSelected: (_) {
                      setState(() {
                        _adding = true;
                        _selected = {};
                        _selectedRows.clear();
                      });
                      _searchStudents(reset: true);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_adding)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _search,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'بحث: اسم / معرّف / باركود / حلقة',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          Expanded(
            child: _adding
                ? _searchLoading && _candidates.isEmpty
                      ? const AppLoadingView()
                      : _searchError != null && _candidates.isEmpty
                      ? AppErrorView(
                          error: _searchError,
                          onRetry: () => _searchStudents(reset: true),
                        )
                      : _candidates.isEmpty
                      ? const Center(child: Text('لا نتائج'))
                      : ListView.builder(
                          controller: controller,
                          itemCount:
                              _candidates.length + (_searchHasMore ? 1 : 0),
                          itemBuilder: (context, i) {
                            if (i >= _candidates.length) {
                              _searchStudents(reset: false);
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            }
                            final s = _candidates[i];
                            return CheckboxListTile(
                              dense: true,
                              value: _selected.contains(s.id),
                              title: Text(s.name),
                              subtitle: Text(
                                [
                                  if (s.teamNames.isNotEmpty) s.teamNames,
                                  s.barcode,
                                ].join(' · '),
                              ),
                              onChanged: (v) => setState(() {
                                if (v == true) {
                                  _selected.add(s.id);
                                  _selectedRows[s.id] = s;
                                } else {
                                  _selected.remove(s.id);
                                  _selectedRows.remove(s.id);
                                }
                              }),
                            );
                          },
                        )
                : ListView.builder(
                    controller: controller,
                    itemCount: _members.length,
                    itemBuilder: (context, i) {
                      final s = _members[i];
                      return CheckboxListTile(
                        dense: true,
                        value: _selected.contains(s.id),
                        title: Text(s.name),
                        subtitle: Text(
                          s.teamNames.isEmpty ? s.barcode : s.teamNames,
                        ),
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            _selected.add(s.id);
                          } else {
                            _selected.remove(s.id);
                          }
                        }),
                      );
                    },
                  ),
          ),
          if (_selected.isNotEmpty)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: AppButton(
                  label: _adding
                      ? 'إضافة (${_selected.length})'
                      : 'إزالة (${_selected.length})',
                  variant: _adding
                      ? AppButtonVariant.primary
                      : AppButtonVariant.destructive,
                  onPressed: _adding ? _addSelected : _removeSelected,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Searchable teacher picker: every account can be a team teacher.
class _TeacherPickerSheet extends StatefulWidget {
  const _TeacherPickerSheet({required this.candidates, required this.selected});

  final List<TeacherCandidate> candidates;
  final String selected;

  @override
  State<_TeacherPickerSheet> createState() => _TeacherPickerSheetState();
}

class _TeacherPickerSheetState extends State<_TeacherPickerSheet> {
  final _search = TextEditingController();
  bool _teachersOnly = true;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final q = _search.text.trim().toLowerCase();
    final base = _teachersOnly
        ? widget.candidates
              .where(
                (c) =>
                    c.role.contains('معلم') ||
                    c.role.contains('مدير') ||
                    c.role.contains('إدارة'),
              )
              .toList()
        : widget.candidates;
    final results = q.isEmpty
        ? base
        : base
              .where(
                (c) =>
                    c.name.toLowerCase().contains(q) ||
                    c.username.toLowerCase().contains(q) ||
                    c.role.toLowerCase().contains(q),
              )
              .toList();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                Text(
                  'معلم الحلقة',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _search,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'بحث عن حساب',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            dense: true,
            title: const Text('المعلمون فقط'),
            subtitle: const Text('أوقف العرض لإظهار كل الحسابات'),
            value: _teachersOnly,
            onChanged: (value) => setState(() => _teachersOnly = value),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: results.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.person_off_outlined,
                      color: tokens.textMuted,
                    ),
                    title: const Text('بلا معلم'),
                    trailing: widget.selected.isEmpty
                        ? Icon(Icons.check_circle, color: tokens.brand)
                        : null,
                    onTap: () => Navigator.of(context).pop(''),
                  );
                }
                final c = results[i - 1];
                final isSelected =
                    c.name == widget.selected ||
                    c.username == widget.selected ||
                    c.displayName == widget.selected;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: tokens.accentMatn.withValues(alpha: 0.15),
                    child: Text(
                      c.displayName.characters.first,
                      style: TextStyle(
                        color: tokens.accentMatn,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  title: Text(c.displayName),
                  subtitle: Text(
                    [
                      c.usernameLabel,
                      c.role,
                    ].where((v) => v.isNotEmpty).join(' · '),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: tokens.brand)
                      : null,
                  onTap: () => Navigator.of(context).pop(c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
