import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/adaptive_sheet.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';

/// Opens the course/team scope picker for a single module grant.
///
/// Returns the updated [AdminModuleGrant] (actions preserved) or null when
/// cancelled. Empty course/team selections mean "all" (no restriction).
Future<AdminModuleGrant?> showPermissionScopePicker(
  BuildContext context, {
  required String moduleLabel,
  required AdminModuleGrant initial,
}) {
  return showAppSheet<AdminModuleGrant>(
    context: context,
    maxWidth: 640,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) =>
        PermissionScopePicker(moduleLabel: moduleLabel, initial: initial),
  );
}

class PermissionScopePicker extends StatefulWidget {
  const PermissionScopePicker({
    super.key,
    required this.moduleLabel,
    required this.initial,
  });

  final String moduleLabel;
  final AdminModuleGrant initial;

  @override
  State<PermissionScopePicker> createState() => _PermissionScopePickerState();
}

class _PermissionScopePickerState extends State<PermissionScopePicker> {
  late final Set<int> _courseIds = {...widget.initial.courseIds};
  late final Set<int> _teamIds = {...widget.initial.teamIds};
  Future<({List<AdminCourseSummary> courses, List<AdminTeamRow> teams})>?
  _options;

  @override
  void initState() {
    super.initState();
    _options = _loadOptions();
  }

  Future<({List<AdminCourseSummary> courses, List<AdminTeamRow> teams})>
  _loadOptions() async {
    final repo = AdminRepositoryScope.of(context);
    final results = await Future.wait<Object>([repo.courses(), repo.teams()]);
    return (
      courses: results[0] as List<AdminCourseSummary>,
      teams: results[1] as List<AdminTeamRow>,
    );
  }

  AdminModuleGrant _result() => widget.initial.copyWith(
    courseIds: _courseIds.toList()..sort(),
    teamIds: _teamIds.toList()..sort(),
  );

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      builder: (context, controller) => Column(
        children: [
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              children: [
                Text(
                  'نطاق «${widget.moduleLabel}»',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'اترك الاختيار فارغًا لمنح الوحدة على كل الدورات والحلقات. '
                  'يمكن الجمع بين دورات وحلقات (تقاطع).',
                  style: TextStyle(color: tokens.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 12),
                FutureBuilder<
                  ({List<AdminCourseSummary> courses, List<AdminTeamRow> teams})
                >(
                  future: _options,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: AppLoadingDots()),
                      );
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'تعذر تحميل الدورات والحلقات.',
                          style: TextStyle(color: tokens.dangerText),
                        ),
                      );
                    }
                    final data = snapshot.data;
                    if (data == null) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _scopeSection(
                          context,
                          title: 'الدورات',
                          emptyLabel: 'كل الدورات',
                          options: [
                            for (final course in data.courses)
                              (id: course.id, label: course.name),
                          ],
                          selected: _courseIds,
                        ),
                        const SizedBox(height: 12),
                        _scopeSection(
                          context,
                          title: 'الحلقات',
                          emptyLabel: 'كل الحلقات',
                          options: [
                            for (final team in data.teams)
                              (id: team.id, label: team.name),
                          ],
                          selected: _teamIds,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tokens.radiusSmall),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(_result()),
                child: const Text('اعتماد النطاق'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scopeSection(
    BuildContext context, {
    required String title,
    required String emptyLabel,
    required List<({int id, String label})> options,
    required Set<int> selected,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: Text(emptyLabel),
              selected: selected.isEmpty,
              onSelected: (_) => setState(selected.clear),
            ),
            for (final option in options)
              FilterChip(
                key: ValueKey(
                  'scope-${title == 'الدورات' ? 'course' : 'team'}'
                  '-${option.id}',
                ),
                label: Text(option.label),
                selected: selected.contains(option.id),
                onSelected: (value) => setState(() {
                  if (value) {
                    selected.add(option.id);
                  } else {
                    selected.remove(option.id);
                  }
                }),
              ),
          ],
        ),
        if (options.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'لا توجد خيارات متاحة.',
              style: TextStyle(color: tokens.textMuted, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
