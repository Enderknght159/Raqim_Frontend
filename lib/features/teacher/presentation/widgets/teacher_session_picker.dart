import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/adaptive_sheet.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../admin/data/admin_repository.dart';
import '../../../admin/domain/admin_models.dart';
import '../../../admin/presentation/widgets/course_metrics_panel.dart';
import '../../domain/teacher_models.dart';

/// Course-first, session-second picker. The teacher must pick the course
/// before the session so two sessions on the same day in different courses are
/// never confused.
Future<TeacherSessionSelection?> showTeacherSessionPicker(
  BuildContext context, {
  required AdminRepository repository,
  TeacherSessionSelection? current,
}) {
  return showAppSheet<TeacherSessionSelection>(
    context: context,
    maxWidth: 640,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) =>
        _TeacherSessionPickerSheet(repository: repository, current: current),
  );
}

class _TeacherSessionPickerSheet extends StatefulWidget {
  const _TeacherSessionPickerSheet({required this.repository, this.current});

  final AdminRepository repository;
  final TeacherSessionSelection? current;

  @override
  State<_TeacherSessionPickerSheet> createState() =>
      _TeacherSessionPickerSheetState();
}

class _TeacherSessionPickerSheetState
    extends State<_TeacherSessionPickerSheet> {
  late Future<List<AdminCourseSummary>> _coursesFuture;
  AdminCourseSummary? _course;
  Future<List<AdminSessionRow>>? _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _coursesFuture = widget.repository.courses();
    _course = widget.current?.course;
    if (_course != null) {
      _sessionsFuture = widget.repository.courseSessions(_course!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 24 + bottom),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 620),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (_course != null)
                  IconButton(
                    tooltip: 'رجوع إلى الدورات',
                    onPressed: () => setState(() {
                      _course = null;
                      _sessionsFuture = null;
                    }),
                    icon: const Icon(Icons.arrow_forward),
                  ),
                Expanded(
                  child: Text(
                    _course == null ? 'اختر الدورة' : 'اختر الجلسة',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: tokens.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _course == null
                  ? 'الدورة أولًا، ثم الجلسة — لتجنّب جلسات متشابهة في دورات مختلفة.'
                  : _course!.name,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: _course == null ? _courses(context) : _sessions(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _courses(BuildContext context) {
    return FutureBuilder<List<AdminCourseSummary>>(
      future: _coursesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorRetry(
            message: 'تعذّر تحميل الدورات',
            onRetry: () => setState(() {
              _coursesFuture = widget.repository.courses();
            }),
          );
        }
        final courses = snapshot.data ?? const <AdminCourseSummary>[];
        if (courses.isEmpty) {
          return const EmptyState(
            title: 'لا دورات متاحة',
            message: 'لم تُنشأ دورات في المسجد بعد.',
            icon: Icons.menu_book_outlined,
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          itemCount: courses.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final course = courses[index];
            return AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              onTap: () {
                setState(() {
                  _course = course;
                  _sessionsFuture = widget.repository.courseSessions(course.id);
                });
              },
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        // Icon + number instead of repeating «جلسة»/«طالب» in
                        // every row; the words live in the tooltips.
                        Wrap(
                          spacing: 10,
                          runSpacing: 2,
                          children: [
                            IconCount(
                              icon: Icons.event_note_outlined,
                              value: course.sessionsCount,
                              tooltip: 'عدد الجلسات',
                            ),
                            IconCount(
                              icon: Icons.groups_outlined,
                              value: course.studentsCount,
                              tooltip: 'عدد الطلاب',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppChip(
                    label: course.isActive ? 'نشطة' : 'منتهية',
                    color: course.isActive
                        ? Theme.of(context).extension<AppTokens>()!.brand
                        : Theme.of(context).extension<AppTokens>()!.textMuted,
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_left),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _sessions(BuildContext context) {
    return FutureBuilder<List<AdminSessionRow>>(
      future: _sessionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorRetry(
            message: 'تعذّر تحميل الجلسات',
            onRetry: () => setState(() {
              _sessionsFuture = widget.repository.courseSessions(_course!.id);
            }),
          );
        }
        // Teacher-facing order: newest first, then the highest session index.
        final sessions = [...(snapshot.data ?? const <AdminSessionRow>[])]
          ..sort((a, b) {
            final byDate = b.date.compareTo(a.date);
            return byDate != 0 ? byDate : b.index.compareTo(a.index);
          });
        if (sessions.isEmpty) {
          return const EmptyState(
            title: 'لا جلسات في هذه الدورة',
            message: 'اطلب من الإدارة إنشاء جلسة أولًا.',
            icon: Icons.event_busy_outlined,
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          itemCount: sessions.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final session = sessions[index];
            final selected = widget.current?.session.id == session.id;
            return AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              borderColor: selected
                  ? Theme.of(context).extension<AppTokens>()!.brandBorder
                  : null,
              onTap: () => Navigator.of(context).pop(
                TeacherSessionSelection(course: _course!, session: session),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الجلسة ${session.index}',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _dateLabel(session.date),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).extension<AppTokens>()!.textMuted,
                              ),
                        ),
                      ],
                    ),
                  ),
                  AppChip(
                    label: '${session.present}/${session.total}',
                    icon: Icons.how_to_reg_outlined,
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_left),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _dateLabel(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
