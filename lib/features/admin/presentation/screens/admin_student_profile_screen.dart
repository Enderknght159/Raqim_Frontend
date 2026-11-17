import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/section_loader.dart';
import '../../../../core/storage/screen_cache.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/icon_toggle_group.dart';
import '../../../../core/widgets/progress_bar.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../shared/permissions.dart';
import '../../../student/domain/models/student_models.dart';
import '../../../student/presentation/widgets/certificates_sheet.dart';
import '../../../student/presentation/widgets/qr_code_view.dart';
import '../../../student/presentation/widgets/quran_map.dart';
import '../../../student/presentation/widgets/tasmi_log_sheet.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';
import '../widgets/course_metrics_panel.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

/// E7 — Student profile (admin): the student's whole record — header (teams
/// open their manager), overview, the full Quran map + tasmi'/certificates
/// sheets, academic output with show-more (exams + matn log), editable data,
/// phones, QR, course records (each opens the student's course achievement)
/// and change requests.
///
/// With [teacherMode] the same page is read-only: phones are visible but not
/// editable, personal data is locked, and change requests / QR / admin links
/// are hidden.
class AdminStudentProfileScreen extends StatefulWidget {
  const AdminStudentProfileScreen({
    super.key,
    required this.studentId,
    this.teacherMode = false,
  });

  final int studentId;

  /// Teacher mode: read-only personal data, phones visible, no change requests,
  /// no QR/admin links.
  final bool teacherMode;

  @override
  State<AdminStudentProfileScreen> createState() =>
      _AdminStudentProfileScreenState();
}

class _AdminStudentProfileScreenState extends State<AdminStudentProfileScreen> {
  /// Bumped after every write so all card sections reload.
  int _revision = 0;
  String? _studentName;

  /// One profile request shared by the card sections.
  Future<AdminStudentProfile>? _profileFuture;
  int _profileToken = 0;
  bool _cacheSeeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_cacheSeeded) return;
    _cacheSeeded = true;
    // Paint the title immediately on a revisit instead of «ملف الطالب».
    final prefix =
        '${widget.teacherMode ? 'teacher' : 'admin'}-student-${widget.studentId}';
    final cached = ScreenCache.instance.read<AdminStudentProfile>(
      '$prefix-header',
    );
    final name = cached?.profile.name;
    if (name != null && name.isNotEmpty) _studentName = name;
  }

  Future<T?> _safe<T>(Future<T> future) async {
    try {
      return await future;
    } catch (_) {
      return null;
    }
  }

  Future<AdminStudentProfile> _fetchProfile() async {
    final token = _profileToken;
    final profile = await AdminRepositoryScope.of(
      context,
    ).studentProfile(widget.studentId);
    if (mounted &&
        token == _profileToken &&
        _studentName != profile.profile.name) {
      setState(() => _studentName = profile.profile.name);
    }
    return profile;
  }

  /// Memoized profile for the header/overview/Quran/output/data cards. A
  /// failure is not memoized so a section retry hits the repository again.
  Future<AdminStudentProfile> _profile() {
    final existing = _profileFuture;
    if (existing != null) return existing;
    final future = _fetchProfile();
    _profileFuture = future;
    future.then<void>(
      (_) {},
      onError: (Object _) {
        if (identical(_profileFuture, future)) _profileFuture = null;
      },
    );
    return future;
  }

  bool _canEditStudents(BuildContext context) {
    if (widget.teacherMode) {
      return currentProfile(context)?.teacherCanEdit('students') ?? false;
    }
    return canEditModule(context, 'students');
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _profileFuture = null;
      _profileToken++;
      _revision++;
    });
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() {
      _profileFuture = null;
      _profileToken++;
      _revision++;
    });
  }

  /// Shared error card for the profile-backed cards. Retrying reloads the
  /// whole page so every card that failed on the same request recovers.
  Widget _profileError(BuildContext context, VoidCallback _) =>
      SectionError(onRetry: _reload, message: 'تعذر تحميل بيانات الطالب');

  @override
  Widget build(BuildContext context) {
    final prefix =
        '${widget.teacherMode ? 'teacher' : 'admin'}-student-${widget.studentId}';
    return Scaffold(
      appBar: AppBar(title: Text(_studentName ?? 'ملف الطالب')),
      body: ResponsivePage(
        maxWidth: 1200,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              AsyncSection<AdminStudentProfile>(
                cacheKey: '$prefix-header',
                revision: _revision,
                skeleton: const SectionSkeleton(height: 52, lines: 1),
                errorBuilder: _profileError,
                load: _profile,
                builder: (context, profile) => _header(context, profile),
              ),
              const SizedBox(height: 12),
              AsyncSection<AdminStudentProfile>(
                cacheKey: '$prefix-overview',
                revision: _revision,
                skeleton: const SectionSkeleton(height: 72, lines: 1),
                errorBuilder: _profileError,
                load: _profile,
                builder: (context, profile) => _overview(context, profile),
              ),
              const SizedBox(height: 12),
              AsyncSection<AdminStudentProfile>(
                cacheKey: '$prefix-teams',
                revision: _revision,
                skeleton: const SectionSkeleton(height: 64, lines: 2),
                errorBuilder: _profileError,
                load: _profile,
                builder: (context, profile) => _teamsCard(context, profile),
              ),
              const SizedBox(height: 12),
              // Quran map + tasmi' + certificates sheet.
              AsyncSection<AdminStudentProfile>(
                cacheKey: '$prefix-quran',
                revision: _revision,
                skeleton: const SectionSkeleton(height: 140, lines: 3),
                errorBuilder: _profileError,
                load: _profile,
                builder: (context, profile) => _quranCard(context, profile),
              ),
              const SizedBox(height: 12),
              // Academic activity/output (subjects, exams, matn, show-more).
              AsyncSection<AdminStudentProfile>(
                cacheKey: '$prefix-output',
                revision: _revision,
                skeleton: const SectionSkeleton(height: 110, lines: 3),
                errorBuilder: _profileError,
                load: _profile,
                builder: (context, profile) =>
                    _achievementCard(context, profile),
              ),
              const SizedBox(height: 12),
              AsyncSection<AdminStudentProfile>(
                cacheKey: '$prefix-data',
                revision: _revision,
                skeleton: const SectionSkeleton(height: 96, lines: 2),
                errorBuilder: _profileError,
                load: _profile,
                builder: (context, profile) => _dataCard(context, profile),
              ),
              const SizedBox(height: 12),
              AsyncSection<AdminStudentProfile>(
                cacheKey: '$prefix-phones',
                revision: _revision,
                skeleton: const SectionSkeleton(height: 64, lines: 2),
                errorBuilder: _profileError,
                load: _profile,
                builder: (context, profile) => _phonesCard(context, profile),
              ),
              if (!widget.teacherMode) ...[
                const SizedBox(height: 12),
                AsyncSection<AdminStudentProfile>(
                  cacheKey: '$prefix-qr',
                  revision: _revision,
                  skeleton: const SectionSkeleton(height: 180, lines: 1),
                  errorBuilder: _profileError,
                  load: _profile,
                  builder: (context, profile) => _qr(context, profile),
                ),
              ],
              const SizedBox(height: 12),
              // Course records: their own request.
              AsyncSection<List<({int courseId, String course, int points})>>(
                cacheKey: '$prefix-records',
                revision: _revision,
                skeleton: const SectionSkeleton(height: 88, lines: 3),
                errorBuilder: (context, retry) => SectionError(
                  onRetry: retry,
                  message: 'تعذر تحميل سجلات الدورات',
                ),
                load: () => AdminRepositoryScope.of(
                  context,
                ).studentCourseRecords(widget.studentId),
                builder: (context, records) => _records(context, records),
              ),
              if (!widget.teacherMode) ...[
                const SizedBox(height: 12),
                AsyncSection<List<AdminChangeRequest>>(
                  cacheKey: '$prefix-requests',
                  revision: _revision,
                  skeleton: const SectionSkeleton(height: 64, lines: 2),
                  errorBuilder: (context, retry) => SectionError(
                    onRetry: retry,
                    message: 'تعذر تحميل طلبات التغيير',
                  ),
                  load: () async {
                    final requests =
                        await _safe(
                          AdminRepositoryScope.of(context).changeRequests(),
                        ) ??
                        const <AdminChangeRequest>[];
                    return requests
                        .where((r) => r.studentId == widget.studentId)
                        .toList();
                  },
                  builder: (context, requests) =>
                      _changeRequests(context, requests),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Header (teams are tappable → team manager) ─────────────────────────

  Widget _header(BuildContext context, AdminStudentProfile p) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: tokens.brandTint,
            child: Text(
              p.profile.name.characters.first,
              style: TextStyle(
                color: tokens.brandText,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.profile.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: tokens.textPrimary,
                  ),
                ),
                Text(
                  '#${p.profile.barcode}',
                  textDirection: TextDirection.ltr,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Explicit access to the student's teams (tap → team manager).
  Widget _teamsCard(BuildContext context, AdminStudentProfile p) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final teams = p.teams;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            icon: Icons.groups_outlined,
            title: 'الحلقات',
            trailing: StatusBadge(
              label: '${teams.length}',
              color: teams.isEmpty ? tokens.textMuted : tokens.brand,
            ),
          ),
          const SizedBox(height: 4),
          if (teams.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'لا حلقات لهذا الطالب',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            for (final team in teams)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: tokens.brandTint,
                  child: Icon(Icons.hub, size: 16, color: tokens.brandText),
                ),
                title: Text(
                  team.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${team.typeName} · ${team.teacherName.isEmpty ? 'بلا معلم' : team.teacherName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: widget.teacherMode
                    ? null
                    : Icon(Icons.chevron_left, color: tokens.borderStructural),
                onTap: widget.teacherMode ? null : () => _openTeam(team),
              ),
        ],
      ),
    );
  }

  Future<void> _openTeam(Team team) async {
    await context.push('/admin/teams/${team.id}');
    if (!mounted) return;
    _reload();
  }

  // ── Overview ───────────────────────────────────────────────────────────

  Widget _overview(BuildContext context, AdminStudentProfile p) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            icon: Icons.insights_outlined,
            title: 'نظرة عامة',
          ),
          const SizedBox(height: 10),
          // Three tiles on a phone squeeze the Arabic labels into ellipses,
          // so they reflow to two per row below 520px.
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 520 ? 3 : 2;
              final tileWidth =
                  (constraints.maxWidth - 8 * (columns - 1)) / columns;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: tileWidth,
                    child: StatTile(
                      label: 'صفحات محفوظة',
                      value: p.pagesMemorized,
                      icon: Icons.auto_stories_outlined,
                      color: tokens.brand,
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: StatTile(
                      label: 'شهادات',
                      value: p.certificatesCount,
                      icon: Icons.school_outlined,
                      color: tokens.reward,
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: StatTile(
                      label: 'حلقات',
                      value: p.teams.length,
                      icon: Icons.hub_outlined,
                      color: tokens.info,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Quran card: full map + tasmi' + certificates (student parity) ─────

  Widget _quranCard(BuildContext context, AdminStudentProfile p) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final tested = <int>{
      for (final c in p.certificates)
        for (var j = c.startJuz; j <= c.endJuz; j++) j,
    };
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            icon: Icons.auto_stories_outlined,
            title: 'البطاقة القرآنية',
          ),
          const SizedBox(height: 8),
          // Icon + number pairs: the caption lives in the tooltip so the three
          // counters never wrap into «رقم فوقه كلمة» stacks.
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              IconCount(
                icon: Icons.auto_stories_outlined,
                value: p.pagesMemorized,
                tooltip: 'صفحات محفوظة',
                color: tokens.brand,
              ),
              IconCount(
                icon: Icons.fact_check_outlined,
                value: p.testedJuz,
                fraction: 30,
                tooltip: 'أجزاء مختبرة من 30',
                color: tokens.info,
              ),
              IconCount(
                icon: Icons.school_outlined,
                value: p.certificatesCount,
                tooltip: 'شهادات',
                color: tokens.reward,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (p.memorizations.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'لا صفحات محفوظة بعد',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            QuranMap(memorizations: p.memorizations, testedJuz: tested),
          const SizedBox(height: 8),
          const Divider(height: 1),
          _TapRow(
            icon: Icons.record_voice_over_outlined,
            color: tokens.brand,
            title: 'سجل التسميع',
            subtitle: '${p.memorizations.length} تسجيلة حفظ',
            onTap: () => showTasmiLogSheet(context, p.memorizations),
          ),
          _TapRow(
            icon: Icons.school_outlined,
            color: tokens.reward,
            title: 'شهادات القرآن',
            subtitle: '${p.certificates.length} شهادة',
            onTap: () => showCertificatesSheet(context, [
              for (final c in p.certificates)
                (
                  startJuz: c.startJuz,
                  endJuz: c.endJuz,
                  mark: c.mark,
                  byHeart: c.byHeart,
                  date: c.date,
                ),
            ]),
          ),
        ],
      ),
    );
  }
  // ── Academic output: subjects + exams + matn + show more ──────────────

  Widget _achievementCard(BuildContext context, AdminStudentProfile p) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final hasMore = p.examResults.isNotEmpty || p.matnRecitationLog.isNotEmpty;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            icon: Icons.workspace_premium_outlined,
            title: 'النتاج العلمي',
          ),
          const SizedBox(height: 8),
          if (p.subjects.isNotEmpty) ...[
            for (final s in p.subjects)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 14,
                          color: tokens.accentMatn,
                        ),
                        const SizedBox(width: 6),
                        Expanded(child: Text(s.subject)),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'النتيجة النهائية',
                          child: Text(
                            s.result == null ? '—' : '${s.result}%',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: tokens.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ProgressBar(
                      value: (s.result ?? 0) / 100,
                      color: tokens.accentMatn,
                      height: 6,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            const Divider(height: 1),
          ],
          const SizedBox(height: 6),
          Text(
            'نتائج الاختبارات',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
          ),
          const SizedBox(height: 4),
          if (p.examResults.isEmpty)
            Text('لا نتائج بعد', style: Theme.of(context).textTheme.bodyMedium)
          else
            // Preview: the 3 latest — «عرض المزيد» shows the full list.
            for (final r in p.examResults.take(3)) _examRow(context, tokens, r),
          if (p.matnProgress.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 6),
            Text(
              'المتون',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
            ),
            const SizedBox(height: 4),
            for (final m in p.matnProgress)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(m.name)),
                        const SizedBox(width: 8),
                        IconCount(
                          icon: Icons.format_quote_outlined,
                          value: m.lastVerse,
                          fraction: m.totalVerses,
                          tooltip: 'البيت الأخير من إجمالي الأبيات',
                          color: tokens.accentMatn,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ProgressBar(
                      value: m.percent,
                      color: tokens.accentMatn,
                      height: 6,
                    ),
                  ],
                ),
              ),
          ],
          if (hasMore) ...[
            const SizedBox(height: 4),
            Center(
              child: TextButton.icon(
                onPressed: () => _showOutputSheet(context, p),
                icon: const Icon(Icons.expand_more, size: 18),
                label: const Text('عرض المزيد'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _examRow(BuildContext context, AppTokens tokens, AdminExamResult r) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            Icons.assignment_turned_in_outlined,
            size: 18,
            color: tokens.accentMatn,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${r.subject} · ${r.typeLabel}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${r.date.day}/${r.date.month}/${r.date.year}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
          Text(
            '${_fmtMark(r.mark)}/${r.maxMark}',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: r.passed ? tokens.brandText : tokens.dangerText,
            ),
          ),
        ],
      ),
    );
  }

  /// Full academic output: every exam result + the complete matn recitation
  /// log (E7 «عرض المزيد»).
  void _showOutputSheet(BuildContext context, AdminStudentProfile p) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    showAppSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text(
              'النتاج العلمي الكامل',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.assignment_turned_in_outlined,
                  size: 18,
                  color: tokens.accentMatn,
                ),
                const SizedBox(width: 8),
                Text(
                  'نتائج الاختبارات',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                StatusBadge(
                  label: '${p.examResults.length}',
                  color: tokens.accentMatn,
                ),
              ],
            ),
            if (p.examResults.isEmpty)
              Text(
                'لا نتائج بعد',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              for (final r in p.examResults) _examRow(context, tokens, r),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 18,
                  color: tokens.accentMatn,
                ),
                const SizedBox(width: 8),
                Text(
                  'سجلات المتون',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                StatusBadge(
                  label: '${p.matnRecitationLog.length}',
                  color: tokens.info,
                ),
              ],
            ),
            if (p.matnRecitationLog.isEmpty)
              Text(
                'لا تسميعات متون بعد',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              for (final m in p.matnRecitationLog)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.format_quote_outlined,
                    color: tokens.accentMatn,
                  ),
                  title: Text(m.matnName),
                  subtitle: Text(
                    '${m.teacherName}'
                    '${m.date == null ? '' : ' · ${m.date!.day}/${m.date!.month}/${m.date!.year}'}',
                  ),
                  trailing: IconCount(
                    icon: Icons.format_list_numbered_outlined,
                    value: m.lastVerse,
                    tooltip: 'البيت الأخير',
                    color: tokens.accentMatn,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  String _fmtMark(double mark) =>
      mark == mark.roundToDouble() ? '${mark.toInt()}' : '$mark';

  // ── Data / phones / QR ─────────────────────────────────────────────────

  Widget _dataCard(BuildContext context, AdminStudentProfile p) {
    final profile = p.profile;
    final canEdit = _canEditStudents(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(icon: Icons.person_outline, title: 'البيانات'),
          const SizedBox(height: 6),
          _dataRow(
            context,
            'الاسم',
            profile.name,
            !canEdit
                ? null
                : () => _editField(
                    context,
                    profile,
                    label: 'الاسم',
                    initial: profile.name,
                    onSave: (v) =>
                        AdminRepositoryScope.of(context).updateStudent(
                          profile.id,
                          name: v,
                          fatherName: profile.fatherName,
                          yearOfBirth: profile.yearOfBirth,
                        ),
                  ),
          ),
          _dataRow(
            context,
            'اسم الأب',
            profile.fatherName ?? '—',
            !canEdit
                ? null
                : () => _editField(
                    context,
                    profile,
                    label: 'اسم الأب',
                    initial: profile.fatherName ?? '',
                    onSave: (v) =>
                        AdminRepositoryScope.of(context).updateStudent(
                          profile.id,
                          name: profile.name,
                          fatherName: v.isEmpty ? null : v,
                          yearOfBirth: profile.yearOfBirth,
                        ),
                  ),
          ),
          _dataRow(
            context,
            'سنة الميلاد',
            profile.yearOfBirth?.toString() ?? '—',
            !canEdit
                ? null
                : () => _editField(
                    context,
                    profile,
                    label: 'سنة الميلاد',
                    initial: profile.yearOfBirth?.toString() ?? '',
                    numeric: true,
                    onSave: (v) =>
                        AdminRepositoryScope.of(context).updateStudent(
                          profile.id,
                          name: profile.name,
                          fatherName: profile.fatherName,
                          yearOfBirth: int.tryParse(v),
                        ),
                  ),
          ),
          _dataRow(
            context,
            'آخر حضور',
            profile.lastSeenAt == null
                ? '—'
                : _fmtDateTime(profile.lastSeenAt!),
            null,
          ),
        ],
      ),
    );
  }

  Widget _dataRow(
    BuildContext context,
    String label,
    String value,
    VoidCallback? onEdit,
  ) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(color: tokens.textMuted, fontSize: 13),
      ),
      subtitle: Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      trailing: onEdit == null
          ? null
          : IconButton(
              tooltip: 'تعديل $label',
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: tokens.brandText,
              onPressed: onEdit,
            ),
    );
  }

  Future<void> _editField(
    BuildContext context,
    StudentProfileModel profile, {
    required String label,
    required String initial,
    required Future<void> Function(String value) onSave,
    bool numeric = false,
  }) async {
    final controller = TextEditingController(text: initial);
    await showAppSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
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
            Text(
              'تعديل $label',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: numeric ? TextInputType.number : TextInputType.text,
              inputFormatters: numeric
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
              decoration: InputDecoration(labelText: label),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'حفظ',
              onPressed: () async {
                await onSave(controller.text.trim());
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    _reload();
  }

  Widget _phonesCard(BuildContext context, AdminStudentProfile p) {
    final phones = p.profile.phones;
    final canEdit = _canEditStudents(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            icon: Icons.phone_outlined,
            title: 'أرقام الهاتف',
            trailing: canEdit
                ? TextButton.icon(
                    onPressed: () => _phoneSheet(context, p),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('إضافة'),
                  )
                : null,
          ),
          const SizedBox(height: 4),
          if (phones.isEmpty)
            Text(
              'لا أرقام مسجلة',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            for (final phone in phones)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.phone_outlined),
                title: Text(phone.phone, textDirection: TextDirection.ltr),
                subtitle: Text(phone.typeLabel),
                trailing: canEdit
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'تعديل',
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () =>
                                _phoneSheet(context, p, editing: phone),
                          ),
                          IconButton(
                            tooltip: 'إزالة',
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () => _removePhone(p, phone),
                          ),
                        ],
                      )
                    : null,
              ),
        ],
      ),
    );
  }

  /// Removes a phone with confirmation + undo window.
  Future<void> _removePhone(AdminStudentProfile p, Phone phone) async {
    if (!_canEditStudents(context)) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إزالة رقم الهاتف'),
        content: Text('إزالة الرقم ${phone.phone}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إزالة'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final repo = AdminRepositoryScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await repo.removePhone(phone.id);
    if (!mounted) return;
    _reload();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('أُزيل الرقم ${phone.phone}'),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'تراجع',
            onPressed: () async {
              await repo.addPhone(p.profile.id, phone.phone, phone.type);
              if (mounted) _reload();
            },
          ),
        ),
      );
  }

  Future<void> _phoneSheet(
    BuildContext context,
    AdminStudentProfile p, {
    Phone? editing,
  }) async {
    if (!_canEditStudents(context)) return;
    final repo = AdminRepositoryScope.of(context);
    final number = TextEditingController(text: editing?.phone ?? '');
    var type = editing?.type ?? 'parent';
    var saving = false;
    String? error;
    await showAppSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
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
              Text(
                editing == null ? 'إضافة رقم هاتف' : 'تعديل رقم الهاتف',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: number,
                keyboardType: TextInputType.phone,
                enabled: !saving,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
              ),
              const SizedBox(height: 12),
              IconToggleGroup<String>(
                value: type,
                onChanged: saving
                    ? (_) {}
                    : (v) => setSheetState(() => type = v),
                options: const [
                  IconToggleOption(
                    value: 'parent',
                    icon: Icons.family_restroom,
                    label: 'ولي الأمر',
                  ),
                  IconToggleOption(
                    value: 'student',
                    icon: Icons.person_outline,
                    label: 'الطالب',
                  ),
                  IconToggleOption(
                    value: 'landline',
                    icon: Icons.phone_in_talk_outlined,
                    label: 'هاتف أرضي',
                  ),
                ],
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(
                  error!,
                  style: TextStyle(
                    color: Theme.of(context).extension<AppTokens>()!.dangerText,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              AppButton(
                label: saving ? 'جارٍ الحفظ…' : 'حفظ',
                loading: saving,
                onPressed: saving
                    ? null
                    : () async {
                        final value = number.text.trim();
                        if (value.isEmpty) {
                          setSheetState(() => error = 'أدخل رقم الهاتف');
                          return;
                        }
                        setSheetState(() {
                          saving = true;
                          error = null;
                        });
                        try {
                          if (editing == null) {
                            await repo.addPhone(p.profile.id, value, type);
                          } else {
                            await repo.updatePhone(
                              editing.id,
                              phone: value,
                              type: type,
                            );
                          }
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        } catch (e) {
                          if (sheetContext.mounted) {
                            setSheetState(() {
                              saving = false;
                              error = 'تعذر الحفظ: $e';
                            });
                          }
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    _reload();
  }

  Widget _qr(BuildContext context, AdminStudentProfile p) {
    return AppCard(
      child: Column(
        children: [
          const SectionHeader(icon: Icons.qr_code_2, title: 'الباركود'),
          const SizedBox(height: 12),
          QrCodeCard(code: p.profile.barcode, size: 180),
        ],
      ),
    );
  }

  // ── Course records (tap → the student's achievement in that course) ───

  Widget _records(
    BuildContext context,
    List<({int courseId, String course, int points})> records,
  ) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            icon: Icons.menu_book_outlined,
            title: 'سجلات الدورات',
          ),
          const SizedBox(height: 4),
          if (records.isEmpty)
            Text(
              'لا سجلات في أي دورة',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            for (final r in records)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.auto_stories_outlined,
                  color: tokens.brandText,
                ),
                title: Text(
                  r.course,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconCount(
                      icon: Icons.stars_outlined,
                      value: r.points,
                      tooltip: 'نقاط الدورة',
                      color: tokens.rewardText,
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.chevron_left, color: tokens.borderStructural),
                  ],
                ),
                onTap: widget.teacherMode
                    ? null
                    : () => context.push(
                        '/admin/students/${widget.studentId}/courses/${r.courseId}',
                      ),
              ),
        ],
      ),
    );
  }

  Widget _changeRequests(
    BuildContext context,
    List<AdminChangeRequest> requests,
  ) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            icon: Icons.rule_folder_outlined,
            title: 'طلبات التغيير',
          ),
          const SizedBox(height: 8),
          if (requests.isEmpty)
            Text('لا طلبات', style: Theme.of(context).textTheme.bodyMedium)
          else
            for (final r in requests)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${r.fieldLabel}: ${r.currentValue ?? '—'} → ${r.requestedValue}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    if (r.status == 'pending')
                      _approvalButtons(context, r)
                    else
                      StatusBadge(
                        label: r.status == 'approved' ? 'مقبول' : 'مرفوض',
                        color: r.status == 'approved'
                            ? tokens.brand
                            : tokens.danger,
                      ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _approvalButtons(BuildContext context, AdminChangeRequest r) {
    final repo = AdminRepositoryScope.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'اعتماد',
          icon: const Icon(Icons.check_circle_outline),
          color: Theme.of(context).extension<AppTokens>()!.brand,
          onPressed: () async {
            await repo.resolveChangeRequest(r.id, approve: true);
            if (!context.mounted) return;
            _reload();
          },
        ),
        IconButton(
          tooltip: 'رفض',
          icon: const Icon(Icons.cancel_outlined),
          color: Theme.of(context).extension<AppTokens>()!.danger,
          onPressed: () async {
            await repo.resolveChangeRequest(r.id, approve: false);
            if (!context.mounted) return;
            _reload();
          },
        ),
      ],
    );
  }

  String _fmtDateTime(DateTime d) =>
      '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

/// A tappable row with icon + title + subtitle + chevron (E7 cards).
class _TapRow extends StatelessWidget {
  const _TapRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return InkWell(
      borderRadius: BorderRadius.circular(tokens.radiusSmall),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_left, color: tokens.textMuted),
          ],
        ),
      ),
    );
  }
}
