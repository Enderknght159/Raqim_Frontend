import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/section_loader.dart';
import '../../../../core/storage/screen_cache.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/icon_tile.dart';
import '../../../../core/widgets/icon_toggle_group.dart';
import '../../../../core/widgets/search_picker_field.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../student/domain/models/student_models.dart';
import '../../data/admin_repository.dart';
import '../../domain/admin_models.dart';
import '../../../../shared/permissions.dart';
import '../admin_shell.dart';
import '../widgets/certificate_editor_sheet.dart';
import '../widgets/course_editor_sheet.dart';
import '../widgets/course_metrics_panel.dart';
import '../widgets/session_index_slider.dart';
import '../widgets/session_setup_sheet.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

/// E2 — Admin course page: overview card + 4 sections (sessions · exams ·
/// top students · certificates).
class AdminCourseDetailScreen extends StatefulWidget {
  const AdminCourseDetailScreen({super.key, required this.courseId});

  final int courseId;

  @override
  State<AdminCourseDetailScreen> createState() =>
      _AdminCourseDetailScreenState();
}

class _AdminCourseDetailScreenState extends State<AdminCourseDetailScreen> {
  static const double _railReservedWidth = 36;

  /// Bumped after any write (session / exam / certificate / course) so every
  /// [AsyncSection] on the page reloads on its own.
  int _revision = 0;

  /// Identity-only course row (name + dates) used to paint the AppBar and the
  /// tabs before the heavier section requests finish.
  late Future<AdminCourseSummary?> _briefFuture;

  /// True while the editor waits for a summary that is not cached yet.
  bool _openingEditor = false;

  bool _selecting = false;
  final Set<int> _selectedSessions = {};

  /// Controller for the sessions list so the quick-jump rail can correct the
  /// scroll position when a target row is not built yet.
  final ScrollController _sessionsScroll = ScrollController();

  /// One key per session row: the rail jumps to the row via
  /// `Scrollable.ensureVisible`.
  final Map<int, GlobalKey> _sessionKeys = {};

  String get _briefKey => 'admin-course-brief-${widget.courseId}';

  String get _overviewKey => 'admin-course-overview-${widget.courseId}';

  @override
  void initState() {
    super.initState();
    _briefFuture = _loadBrief();
  }

  @override
  void dispose() {
    _sessionsScroll.dispose();
    super.dispose();
  }

  /// Loads only the course name/brief. Failures (or a missing course row) fall
  /// back to the session cache, then to the generic «الدورة» title, so the
  /// page never waits on this request.
  Future<AdminCourseSummary?> _loadBrief() async {
    final cached = ScreenCache.instance.read<AdminCourseSummary>(_briefKey);
    try {
      final repo = AdminRepositoryScope.of(context);
      final briefs = await repo.courseBriefs();
      for (final c in briefs) {
        if (c.id == widget.courseId) {
          ScreenCache.instance.write(_briefKey, c);
          return c;
        }
      }
    } catch (_) {
      // Keep the cached / generic title.
    }
    return cached;
  }

  GlobalKey _sessionKey(int sessionId) => _sessionKeys.putIfAbsent(
    sessionId,
    () => GlobalKey(debugLabel: 'session-$sessionId'),
  );

  /// Reloads every section without dropping the page shell.
  void _bumpRevision() {
    if (!mounted) return;
    setState(() => _revision++);
  }

  @override
  Widget build(BuildContext context) {
    final repo = AdminRepositoryScope.of(context);
    final canEdit = canEditModule(context, 'courses');
    final canDelete = canDeleteModule(context, 'courses');
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: FutureBuilder<AdminCourseSummary?>(
            future: _briefFuture,
            initialData: ScreenCache.instance.read<AdminCourseSummary>(
              _briefKey,
            ),
            builder: (context, snapshot) =>
                Text(snapshot.data?.name ?? 'الدورة'),
          ),
          actions: [
            if (canEdit)
              if (_openingEditor)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else
                IconButton(
                  tooltip: 'تعديل الدورة',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: _editCourse,
                ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'الجلسات'),
              Tab(text: 'الامتحانات'),
              Tab(text: 'الطلاب الأوائل'),
              Tab(text: 'الشهادات'),
            ],
          ),
        ),
        body: Column(
          children: [
            AsyncSection<AdminCourseSummary>(
              cacheKey: _overviewKey,
              revision: _revision,
              load: () async {
                final summary = await repo.courseSummary(widget.courseId);
                if (summary == null) throw StateError('course');
                return summary;
              },
              skeleton: _overviewSkeleton(context),
              builder: (context, summary) => _overviewCard(context, summary),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _sessionsSection(
                    context,
                    repo,
                    canEdit: canEdit,
                    canDelete: canDelete,
                  ),
                  _examsSection(context, repo),
                  _leaderboardSection(context, repo),
                  _certificatesSection(context, repo),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens the course editor (identity + dates + criteria) or deletes it.
  Future<void> _editCourse() async {
    if (_openingEditor) return;
    var summary = ScreenCache.instance.read<AdminCourseSummary>(_overviewKey);
    if (summary == null) {
      setState(() => _openingEditor = true);
      try {
        summary = await AdminRepositoryScope.of(
          context,
        ).courseSummary(widget.courseId);
      } catch (_) {
        summary = null;
      }
      if (!mounted) return;
      setState(() => _openingEditor = false);
    }
    final course = summary;
    if (course == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر تحميل بيانات الدورة')));
      return;
    }
    final result = await showCourseEditorSheet(context, course: course);
    if (!mounted || result == null) return;
    if (result == CourseEditorResult.deleted) {
      // Back to the courses landing page (it reloads on return).
      context.pop();
      return;
    }
    // The name may have changed: refresh the title and every section.
    setState(() {
      _briefFuture = _loadBrief();
      _revision++;
    });
  }

  /// Course card: status + compact date range on top, then the shared
  /// metrics panel (donut left, attendance trend right, icon counters below).
  Widget _overviewCard(BuildContext context, AdminCourseSummary c) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                StatusBadge(
                  label: c.isActive ? 'نشطة' : 'منتهية',
                  color: c.isActive ? tokens.brand : tokens.textMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Tooltip(
                        message: 'مدة الدورة',
                        child: Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: tokens.textMuted,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          '${formatDate(c.startDate)} – ${formatDate(c.endDate)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: tokens.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CourseMetricsPanel(
              attendancePercent: c.attendancePercent,
              series: c.series,
              studentsCount: c.studentsCount,
              sessionsCount: c.sessionsCount,
              lastPresent: c.lastSessionPresent,
              lastTotal: c.lastSessionTotal,
            ),
          ],
        ),
      ),
    );
  }

  /// Shape-matched placeholder for the overview card (status row + chart).
  Widget _overviewSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Skeleton(width: 54, height: 22, radius: 8),
                Spacer(),
                Skeleton(width: 132, height: 12),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Skeleton(height: 92, radius: 12)),
                SizedBox(width: 14),
                Skeleton(width: 84, height: 84, radius: 42),
              ],
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                Skeleton(width: 62, height: 14),
                SizedBox(width: 16),
                Skeleton(width: 62, height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared tab skeleton ─────────────────────────────────────────────────

  /// Placeholder shaped like a tab body: action button, section header and a
  /// few rows — close enough that nothing jumps when the data lands.
  Widget _tabSkeleton({
    int rows = 3,
    bool showAction = true,
    bool reserveRail = false,
  }) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        reserveRail ? 16 + _railReservedWidth : 16,
        12,
      ),
      children: [
        if (showAction) ...[
          const Skeleton(height: 44, radius: 12),
          const SizedBox(height: 14),
        ],
        const Skeleton(height: 18, width: 120),
        const SizedBox(height: 10),
        for (var i = 0; i < rows; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          const Skeleton(height: 48, radius: 12),
        ],
      ],
    );
  }

  // ── Sessions tab ────────────────────────────────────────────────────────

  Widget _sessionsSection(
    BuildContext context,
    AdminRepository repo, {
    required bool canEdit,
    required bool canDelete,
  }) {
    return AsyncSection<List<AdminSessionRow>>(
      cacheKey: 'admin-course-sessions-${widget.courseId}',
      revision: _revision,
      delay: const Duration(milliseconds: 60),
      load: () => repo.courseSessions(widget.courseId),
      skeleton: _tabSkeleton(rows: 4, showAction: canEdit, reserveRail: true),
      builder: (context, sessions) => _sessionsTab(
        context,
        sessions,
        canEdit: canEdit,
        canDelete: canDelete,
      ),
    );
  }

  Widget _sessionsTab(
    BuildContext context,
    List<AdminSessionRow> loaded, {
    required bool canEdit,
    required bool canDelete,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    // Newest first — the rail labels follow the same display order.
    final sessions = loaded.reversed.toList(growable: false);
    return Stack(
      children: [
        ListView(
          controller: _sessionsScroll,
          padding: EdgeInsets.fromLTRB(16, 12, 16 + _railReservedWidth, 12),
          children: [
            if (canEdit) ...[
              AppButton(
                label: 'إنشاء جلسة اليوم',
                icon: Icons.today_outlined,
                onPressed: () => _createTodaySession(loaded),
              ),
              const SizedBox(height: 12),
            ],
            SectionHeader(
              icon: Icons.event_note_outlined,
              title: 'الجلسات',
              trailing: sessions.isNotEmpty && canDelete
                  ? TextButton(
                      onPressed: () => setState(() {
                        _selecting = !_selecting;
                        _selectedSessions.clear();
                      }),
                      child: Text(_selecting ? 'إلغاء التحديد' : 'تحديد'),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            if (sessions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('لا جلسات بعد')),
              )
            else
              for (var i = 0; i < sessions.length; i++) ...[
                _sessionCard(context, tokens, sessions[i]),
                if (i != sessions.length - 1) const SizedBox(height: 8),
              ],
            if (_selecting) ...[
              const SizedBox(height: 12),
              AppButton(
                label: 'حذف المحدد (${_selectedSessions.length})',
                icon: Icons.delete_outline,
                variant: AppButtonVariant.destructive,
                onPressed: _selectedSessions.isEmpty
                    ? null
                    : _deleteSelectedSessions,
              ),
            ],
          ],
        ),
        if (sessions.isNotEmpty)
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: SessionIndexSlider(
              labels: [for (final s in sessions) '${s.index}'],
              onSelected: (index) => _jumpToSession(index, sessions),
            ),
          ),
      ],
    );
  }

  /// Scrolls the sessions list to the row picked on the quick-jump rail.
  void _jumpToSession(int index, List<AdminSessionRow> sessions) {
    if (index < 0 || index >= sessions.length) return;
    final key = _sessionKey(sessions[index].id);
    final target = key.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: 0.06,
      );
      return;
    }
    // The row is off-screen (lazy list): jump to a proportional offset first,
    // then let ensureVisible settle the exact position once it is built.
    if (!_sessionsScroll.hasClients) return;
    final position = _sessionsScroll.position;
    final last = sessions.length - 1;
    final fraction = last == 0 ? 0.0 : index / last;
    final guess =
        position.minScrollExtent +
        (position.maxScrollExtent - position.minScrollExtent) * fraction;
    _sessionsScroll.jumpTo(
      guess
          .clamp(position.minScrollExtent, position.maxScrollExtent)
          .toDouble(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final built = key.currentContext;
      if (built == null) return;
      Scrollable.ensureVisible(
        built,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        alignment: 0.06,
      );
    });
  }

  Widget _sessionCard(
    BuildContext context,
    AppTokens tokens,
    AdminSessionRow s,
  ) {
    final selected = _selectedSessions.contains(s.id);
    final caption = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: tokens.textSecondary);
    return AppCard(
      key: _sessionKey(s.id),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: _selecting && selected ? tokens.brandTint : null,
      borderColor: _selecting && selected ? tokens.brandBorder : null,
      onTap: () {
        if (_selecting) {
          setState(() {
            if (!_selectedSessions.add(s.id)) _selectedSessions.remove(s.id);
          });
        } else {
          _openSession(s.id);
        }
      },
      onLongPress: () => setState(() {
        _selecting = true;
        _selectedSessions.add(s.id);
      }),
      child: Row(
        children: [
          if (_selecting) ...[
            Tooltip(
              message: selected ? 'إلغاء التحديد' : 'تحديد الجلسة',
              triggerMode: TooltipTriggerMode.longPress,
              child: Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 20,
                color: selected ? tokens.brand : tokens.textMuted,
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Session number pill — the word «جلسة» is never repeated.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: tokens.brand,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '#${s.index}',
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.3,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: tokens.textMuted,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    formatDate(s.date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: caption?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'الحضور',
            triggerMode: TooltipTriggerMode.longPress,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.groups_outlined, size: 14, color: tokens.textMuted),
                const SizedBox(width: 4),
                Text(
                  '${s.present}/${s.total}',
                  style: caption?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_left, size: 20, color: tokens.borderStructural),
        ],
      ),
    );
  }

  Future<void> _openSession(int sessionId) async {
    await context.push('/admin/sessions/$sessionId');
    _bumpRevision();
  }

  /// Creates today's session **after** the setup sheet is confirmed — closing
  /// the sheet cancels the creation entirely.
  Future<void> _createTodaySession(List<AdminSessionRow> sessions) async {
    final repo = AdminRepositoryScope.of(context);
    final last = sessions.isEmpty ? null : sessions.last;
    final setup = await showSessionSetupSheet(
      context,
      title: 'إعداد الجلسة الجديدة',
      initial: SessionSetupValues(
        earlyPoints: last?.earlyPoints ?? 3,
        midPoints: last?.midPoints ?? 2,
        latePoints: last?.latePoints ?? 1,
        earlyUntil: last?.earlyUntil ?? '16:00',
        lateFrom: last?.lateFrom ?? '16:30',
        date: DateTime.now(),
      ),
    );
    if (setup == null || !mounted) return;
    final id = await repo.addSession(widget.courseId, setup.date);
    await repo.updateSession(
      id,
      earlyPoints: setup.earlyPoints,
      midPoints: setup.midPoints,
      latePoints: setup.latePoints,
      earlyUntil: setup.earlyUntil,
      lateFrom: setup.lateFrom,
      date: setup.date,
    );
    if (!mounted) return;
    _bumpRevision();
    await context.push('/admin/sessions/$id');
    _bumpRevision();
  }

  Future<void> _deleteSelectedSessions() async {
    final ids = _selectedSessions.toList();
    if (ids.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الجلسات'),
        content: Text(
          'سيتم حذف ${ids.length} جلسة مع كل سجلاتها (حضور، حفظ، متون، '
          'معاملات). يمكن التراجع بعد الحذف.',
        ),
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
    if (confirmed != true || !mounted) return;
    final repo = AdminRepositoryScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final snapshot = await repo.deleteSessionsWithRecords(ids);
    if (!mounted) return;
    setState(() {
      _selecting = false;
      _selectedSessions.clear();
    });
    _bumpRevision();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('حُذفت ${ids.length} جلسة وسجلاتها'),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: 'تراجع',
            onPressed: () async {
              await repo.restoreSessions(snapshot);
              _bumpRevision();
            },
          ),
        ),
      );
  }

  // ── Exams tab (details open a full page) ───────────────────────────────

  Widget _examsSection(BuildContext context, AdminRepository repo) {
    return AsyncSection<List<AdminContentItem>>(
      cacheKey: 'admin-course-exams-${widget.courseId}',
      revision: _revision,
      delay: const Duration(milliseconds: 80),
      load: () => repo.courseExams(widget.courseId),
      skeleton: _tabSkeleton(rows: 3),
      builder: (context, exams) => _examsTab(context, exams),
    );
  }

  Widget _examsTab(BuildContext context, List<AdminContentItem> exams) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppButton(
          label: 'إضافة امتحان',
          icon: Icons.add,
          onPressed: () => _addExam(context),
        ),
        const SizedBox(height: 16),
        const SectionHeader(
          icon: Icons.assignment_outlined,
          title: 'الامتحانات',
        ),
        const SizedBox(height: 8),
        if (exams.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('لا امتحانات')),
          )
        else
          for (final e in exams) ...[
            _examCard(context, tokens, e),
            const SizedBox(height: 8),
          ],
      ],
    );
  }

  /// Exam type drives the tile icon; the type word already lives in the
  /// subtitle so it is never repeated as a separate label.
  (IconData, Color) _examIcon(AppTokens tokens, AdminContentItem e) {
    final haystack = '${e.name} ${e.subtitle ?? ''}';
    if (haystack.contains('نهائي')) {
      return (Icons.emoji_events_outlined, tokens.reward);
    }
    if (haystack.contains('شفهي')) {
      return (Icons.record_voice_over_outlined, tokens.infoLight);
    }
    if (haystack.contains('سبر') || haystack.contains('كتابي')) {
      return (Icons.description_outlined, tokens.accentMatn);
    }
    return (Icons.assignment_outlined, tokens.brand);
  }

  Widget _examCard(BuildContext context, AppTokens tokens, AdminContentItem e) {
    final (icon, color) = _examIcon(tokens, e);
    final subtitle = e.subtitle?.trim();
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      onTap: () => _openExam(e.id),
      child: Row(
        children: [
          IconTile(icon: icon, color: color, size: 36, iconSize: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_left, size: 20, color: tokens.borderStructural),
        ],
      ),
    );
  }

  Future<void> _openExam(int examId) async {
    await context.push('/admin/courses/${widget.courseId}/exams/$examId');
    _bumpRevision();
  }

  Future<void> _addExam(BuildContext context) async {
    final repo = AdminRepositoryScope.of(context);
    final subjects = await repo.subjects();
    if (!context.mounted) return;
    final maxMark = TextEditingController(text: '100');
    final minSuccess = TextEditingController(text: '50');
    final points = TextEditingController(text: '0');
    String subjectName = subjects.isEmpty ? '' : subjects.first.name;
    var type = 'final';
    await showAppSheet<void>(
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'امتحان جديد',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                // Subject: pick from the mosque subjects (BR-802).
                SearchPickerField<String>(
                  label: 'اختر المادة',
                  items: subjects.map((s) => s.name).toList(),
                  titleBuilder: (name) => name,
                  subtitleBuilder: null,
                  value: subjectName.isEmpty ? null : subjectName,
                  onChanged: (name) => setSheetState(() => subjectName = name),
                ),
                const SizedBox(height: 12),
                Text(
                  'النوع',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).extension<AppTokens>()!.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                IconToggleGroup<String>(
                  value: type,
                  onChanged: (v) => setSheetState(() => type = v),
                  options: const [
                    IconToggleOption(
                      value: 'oral',
                      icon: Icons.record_voice_over_outlined,
                      label: 'شفهي',
                    ),
                    IconToggleOption(
                      value: 'writtenProbe',
                      icon: Icons.description_outlined,
                      label: 'سبر كتابي',
                    ),
                    IconToggleOption(
                      value: 'final',
                      icon: Icons.emoji_events_outlined,
                      label: 'اختبار نهائي',
                      color: Color(0xFFF59E0B),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: maxMark,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'الدرجة القصوى',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: minSuccess,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'درجة النجاح',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: points,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'النقاط'),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'إنشاء',
                  onPressed: () async {
                    if (subjectName.trim().isEmpty) return;
                    await repo.addExam(
                      courseId: widget.courseId,
                      subjectName: subjectName.trim(),
                      type: type,
                      maxMark: int.tryParse(maxMark.text) ?? 100,
                      minSuccessMark: int.tryParse(minSuccess.text) ?? 50,
                      points: int.tryParse(points.text) ?? 0,
                    );
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    _bumpRevision();
  }

  // ── Certificates tab ────────────────────────────────────────────────────

  Widget _certificatesSection(BuildContext context, AdminRepository repo) {
    return AsyncSection<List<AdminCertificateRow>>(
      cacheKey: 'admin-course-certificates-${widget.courseId}',
      revision: _revision,
      delay: const Duration(milliseconds: 120),
      load: () => repo.courseCertificates(widget.courseId),
      skeleton: _tabSkeleton(rows: 3),
      builder: (context, certificates) =>
          _certificatesTab(context, certificates),
    );
  }

  Widget _certificatesTab(
    BuildContext context,
    List<AdminCertificateRow> certificates,
  ) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppButton(
          label: 'إضافة شهادة قرآن',
          icon: Icons.school_outlined,
          onPressed: _addCertificate,
        ),
        const SizedBox(height: 16),
        const SectionHeader(
          icon: Icons.school_outlined,
          title: 'شهادات القرآن',
        ),
        const SizedBox(height: 8),
        if (certificates.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('لا شهادات في هذه الدورة')),
          )
        else
          for (final c in certificates) ...[
            _certificateTile(context, tokens, c),
            const SizedBox(height: 8),
          ],
      ],
    );
  }

  Widget _certificateTile(
    BuildContext context,
    AppTokens tokens,
    AdminCertificateRow c,
  ) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () => _showCertificateDetails(c),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: tokens.reward.withValues(alpha: 0.15),
                child: Icon(
                  Icons.school_outlined,
                  size: 22,
                  color: tokens.reward,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.studentName.isEmpty
                          ? 'طالب #${c.studentId}'
                          : c.studentName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'الجزء ${c.startJuz} – ${c.endJuz} • ${formatDate(c.date)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left, color: tokens.borderStructural),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              StatusBadge(label: '${c.mark}/100', color: tokens.reward),
              StatusBadge(
                label: c.byHeart ? 'عن ظهر قلب' : 'عن حاضر',
                color: c.byHeart ? tokens.brand : tokens.textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showCertificateDetails(AdminCertificateRow c) async {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    await showAppSheet<void>(
      context: context,
      maxWidth: 560,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: tokens.reward.withValues(alpha: 0.15),
                  child: Icon(Icons.school_outlined, color: tokens.reward),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    c.studentName.isEmpty
                        ? 'طالب #${c.studentId}'
                        : c.studentName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                children: [
                  _detailRow(
                    context,
                    'نطاق الأجزاء',
                    '${c.startJuz} - ${c.endJuz}',
                  ),
                  _detailRow(context, 'الدرجة', '${c.mark}/100'),
                  _detailRow(
                    context,
                    'طريقة الأداء',
                    c.byHeart ? 'عن ظهر قلب' : 'عن حاضر',
                  ),
                  _detailRow(context, 'التاريخ', formatDate(c.date)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'تعديل الشهادة',
              icon: Icons.edit_outlined,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                _editCertificate(c);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: tokens.textMuted)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  /// Certificate points come from the overview summary; it is usually already
  /// in the section cache, otherwise a quiet fetch fills it in.
  Future<int> _certificatePoints() async {
    final cached = ScreenCache.instance.read<AdminCourseSummary>(_overviewKey);
    if (cached != null) return cached.certificatePoints;
    try {
      final summary = await AdminRepositoryScope.of(
        context,
      ).courseSummary(widget.courseId);
      return summary?.certificatePoints ?? 10;
    } catch (_) {
      return 10;
    }
  }

  Future<void> _addCertificate() async {
    final points = await _certificatePoints();
    if (!mounted) return;
    final saved = await showCertificateEditorSheet(
      context,
      courseId: widget.courseId,
      certificatePoints: points,
    );
    if (saved == true && mounted) _bumpRevision();
  }

  Future<void> _editCertificate(AdminCertificateRow certificate) async {
    final points = await _certificatePoints();
    if (!mounted) return;
    final saved = await showCertificateEditorSheet(
      context,
      courseId: widget.courseId,
      certificatePoints: points,
      existing: certificate,
    );
    if (saved == true && mounted) _bumpRevision();
  }

  // ── Leaderboard tab ─────────────────────────────────────────────────────

  Widget _leaderboardSection(BuildContext context, AdminRepository repo) {
    return AsyncSection<LeaderboardResult>(
      cacheKey: 'admin-course-leaderboard-${widget.courseId}',
      revision: _revision,
      delay: const Duration(milliseconds: 100),
      load: () => repo.leaderboard(widget.courseId),
      skeleton: _tabSkeleton(rows: 4, showAction: false),
      builder: (context, result) => _leaderboardTab(context, result.entries),
    );
  }

  Widget _leaderboardTab(
    BuildContext context,
    List<StudentLeaderboardEntry> entries,
  ) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    if (entries.isEmpty) {
      return const Center(child: Text('لا طلاب بعد'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'ترتيب طلاب الدورة حسب المحصلة — اضغط أي طالب لفتح ملفه',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
            ),
          );
        }
        final e = entries[i - 1];
        return _LeaderboardRow(entry: e);
      },
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry});

  final StudentLeaderboardEntry entry;

  (IconData icon, Color color, bool top) _medal(AppTokens tokens) {
    switch (entry.rank) {
      case 1:
        return (Icons.emoji_events, tokens.reward, true);
      case 2:
        return (Icons.emoji_events, Color(0xFF9AA5B1), true);
      case 3:
        return (Icons.emoji_events, Color(0xFFB08968), true);
      default:
        return (Icons.person_outline, tokens.textMuted, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final (icon, color, top) = _medal(tokens);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        color: top ? tokens.reward.withValues(alpha: 0.10) : null,
        borderColor: top ? tokens.reward.withValues(alpha: 0.4) : null,
        onTap: () => context.push('/admin/students/${entry.student.id}'),
        child: Row(
          children: [
            SizedBox(
              width: 26,
              child: Text(
                '${entry.rank}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: top ? tokens.rewardText : tokens.textMuted,
                ),
              ),
            ),
            CircleAvatar(
              radius: 16,
              backgroundColor: top
                  ? tokens.reward.withValues(alpha: 0.2)
                  : tokens.brandTint,
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(entry.student.name)),
            Text(
              '${entry.points}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: tokens.rewardText,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'نقطة',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
