import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/admin_local_repository.dart';
import '../../domain/admin_models.dart';

/// Opens the team members manager (E8): preview/remove with multi-select +
/// add via tolerant search. Saves on close. Reused by the teams screen and
/// the admin student profile (tap a team chip).
Future<void> showTeamManagerSheet(
  BuildContext context,
  AdminTeamRow team, {
  required AdminLocalRepository repository,
}) {
  return showModalBottomSheet<void>(
    context: context,
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
  final AdminLocalRepository repo;

  @override
  State<TeamManagerSheet> createState() => _TeamManagerSheetState();
}

class _TeamManagerSheetState extends State<TeamManagerSheet> {
  final _search = TextEditingController();
  List<AdminStudentRow> _members = const [];
  List<AdminStudentRow> _all = const [];
  List<({String name, String role})> _teacherCandidates = const [];
  Set<int> _selected = {};
  bool _adding = false;
  bool _loading = true;
  late String _teacherName = widget.team.teacherName;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final members = await widget.repo.teamStudents(widget.team.id);
    final all = await widget.repo.students();
    final candidates = await widget.repo.teacherCandidates();
    if (!mounted) return;
    setState(() {
      _members = members;
      _all = all;
      _teacherCandidates = candidates;
      _loading = false;
    });
  }

  List<AdminStudentRow> get _candidates {
    final memberIds = _members.map((m) => m.id).toSet();
    return _all
        .where((s) =>
            !memberIds.contains(s.id) && studentMatchesQuery(s, _search.text))
        .toList();
  }

  Future<void> _removeSelected() async {
    await widget.repo
        .removeStudentsFromTeam(widget.team.id, _selected.toList());
    if (!mounted) return;
    setState(() {
      _members = _members.where((m) => !_selected.contains(m.id)).toList();
      _selected = {};
    });
  }

  Future<void> _addSelected() async {
    await widget.repo.addStudentsToTeam(widget.team.id, _selected.toList());
    if (!mounted) return;
    final added = _all.where((s) => _selected.contains(s.id)).toList();
    setState(() {
      _members = [..._members, ...added]
        ..sort((a, b) => a.name.compareTo(b.name));
      _selected = {};
    });
  }

  /// Change the team teacher at any time (any existing account).
  Future<void> _editTeacher() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _TeacherPickerSheet(
        candidates: _teacherCandidates,
        selected: _teacherName,
      ),
    );
    if (result == null || !mounted) return;
    if (result.isEmpty) {
      await widget.repo.removeTeamTeacher(widget.team.id);
    } else {
      await widget.repo.setTeamTeacher(widget.team.id, result);
    }
    if (!mounted) return;
    setState(() => _teacherName = result);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    if (_loading) {
      return const SizedBox(
          height: 300, child: Center(child: CircularProgressIndicator()));
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
                      Text(widget.team.name,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(
                        '${widget.team.typeName} · '
                        '${_teacherName.isEmpty ? 'بلا معلم' : _teacherName}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: tokens.textMuted),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                    label: '${_members.length} طالب',
                    color: tokens.infoLight),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: tokens.surfaceSubtle,
                  borderRadius: BorderRadius.circular(tokens.radiusSmall),
                  border: Border.all(color: tokens.borderStructural),
                ),
                child: Row(
                  children: [
                    Icon(Icons.school_outlined,
                        size: 18, color: tokens.accentMatn),
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
                    Icon(Icons.edit_outlined,
                        size: 18, color: tokens.textMuted),
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
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('إضافة طلاب'),
                    selected: _adding,
                    onSelected: (_) => setState(() {
                      _adding = true;
                      _selected = {};
                    }),
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
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'بحث: اسم / معرّف / باركود / حلقة',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          Expanded(
            child: _adding
                ? _candidates.isEmpty
                    ? const Center(child: Text('لا نتائج'))
                    : ListView.builder(
                        controller: controller,
                        itemCount: _candidates.length,
                        itemBuilder: (context, i) {
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
                              } else {
                                _selected.remove(s.id);
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

  final List<({String name, String role})> candidates;
  final String selected;

  @override
  State<_TeacherPickerSheet> createState() => _TeacherPickerSheetState();
}

class _TeacherPickerSheetState extends State<_TeacherPickerSheet> {
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
        ? widget.candidates
        : widget.candidates
            .where((c) =>
                c.name.toLowerCase().contains(q) ||
                c.role.toLowerCase().contains(q))
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
                Text('معلم الحلقة',
                    style: Theme.of(context).textTheme.titleMedium),
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
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: results.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.person_off_outlined,
                        color: tokens.textMuted),
                    title: const Text('بلا معلم'),
                    trailing: widget.selected.isEmpty
                        ? Icon(Icons.check_circle, color: tokens.brand)
                        : null,
                    onTap: () => Navigator.of(context).pop(''),
                  );
                }
                final c = results[i - 1];
                final isSelected = c.name == widget.selected;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: tokens.accentMatn.withValues(alpha: 0.15),
                    child: Text(c.name.characters.first,
                        style: TextStyle(
                            color: tokens.accentMatn,
                            fontWeight: FontWeight.w800)),
                  ),
                  title: Text(c.name),
                  subtitle: Text(c.role),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: tokens.brand)
                      : null,
                  onTap: () => Navigator.of(context).pop(c.name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
