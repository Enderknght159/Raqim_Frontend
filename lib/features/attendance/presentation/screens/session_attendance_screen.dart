import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../admin/domain/admin_models.dart';
import '../../../admin/presentation/admin_shell.dart';

/// Unified session attendance: camera scan + tolerant auto-search in the same
/// page. Tap a name = register attendance; the undo snackbar offers «تراجع»
/// and «ضبط الزمن»; long-press opens time adjust / remove with undo window.
class SessionAttendanceScreen extends StatefulWidget {
  const SessionAttendanceScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  State<SessionAttendanceScreen> createState() =>
      _SessionAttendanceScreenState();
}

class _SessionAttendanceScreenState extends State<SessionAttendanceScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final _search = TextEditingController();
  List<AdminStudentRow> _students = const [];
  Map<int, DateTime> _registered = {};
  String _sessionTitle = '';
  bool _loading = true;
  bool _busy = false;
  String? _lastScan;
  bool _lastScanOk = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _controller.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = AdminRepositoryScope.of(context);
    final students = await repo.students();
    final attendance = await repo.sessionAttendance(widget.sessionId);
    final session = await repo.sessionRow(widget.sessionId);
    if (!mounted) return;
    setState(() {
      _students = students;
      _registered = {
        for (final a in attendance)
          if (a.arrivalTime != null) a.studentId: a.arrivalTime!,
      };
      _sessionTitle = 'جلسة #${session.index} — ${formatDate(session.date)}';
      _loading = false;
    });
  }

  List<AdminStudentRow> get _results {
    final q = _search.text;
    if (q.trim().isEmpty) return _students;
    return _students.where((s) => studentMatchesQuery(s, q)).toList();
  }

  Future<void> _register(AdminStudentRow student, {DateTime? at}) async {
    final repo = AdminRepositoryScope.of(context);
    final prev = _registered[student.id];
    final time = at ?? DateTime.now();
    await repo.addManualAttendance(widget.sessionId, student.id);
    if (prev != null) {
      await repo.updateAttendanceTime(widget.sessionId, student.id, time);
    }
    if (!mounted) return;
    setState(() => _registered = {..._registered, student.id: time});
    HapticFeedback.lightImpact();
    _snack('سُجّل حضور ${student.name}',
        undoable: true,
        student: student,
        onAdjust: () => _adjustTime(student));
  }

  Future<void> _handleCode(String code) async {
    final value = code.trim();
    if (_busy || value.isEmpty || !mounted) return;
    _busy = true;
    final student = _students
        .where((s) => s.barcode.toLowerCase() == value.toLowerCase())
        .firstOrNull;
    if (student == null) {
      setState(() {
        _lastScan = value;
        _lastScanOk = false;
      });
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.alert);
      _snack('لا يوجد طالب بالباركود $value');
      _busy = false;
      return;
    }
    await _register(student);
    if (!mounted) return;
    setState(() {
      _lastScan = student.name;
      _lastScanOk = true;
      _busy = false;
    });
  }

  Future<void> _undo(AdminStudentRow student) async {
    final prev = _registered[student.id];
    await AdminRepositoryScope.of(context)
        .removeAttendance(widget.sessionId, student.id);
    if (!mounted) return;
    setState(() {
      final next = {..._registered}..remove(student.id);
      _registered = next;
    });
    HapticFeedback.selectionClick();
    _snack('أُلغي تسجيل ${student.name}',
        restore: () => _register(student, at: prev));
  }

  Future<void> _adjustTime(AdminStudentRow student) async {
    final current = _registered[student.id];
    final picked = await showTimePicker(
      context: context,
      initialTime: current == null
          ? TimeOfDay.now()
          : TimeOfDay.fromDateTime(current),
    );
    if (picked == null || !mounted) return;
    final repo = AdminRepositoryScope.of(context);
    final session = await repo.sessionRow(widget.sessionId);
    final newTime = DateTime(
      session.date.year,
      session.date.month,
      session.date.day,
      picked.hour,
      picked.minute,
    );
    await repo.updateAttendanceTime(widget.sessionId, student.id, newTime);
    if (!mounted) return;
    setState(() => _registered = {..._registered, student.id: newTime});
    _snack('حُدّث زمن ${student.name} إلى ${formatTime(newTime)}',
        restore: () => _register(student, at: current));
  }

  Future<void> _remove(AdminStudentRow student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إزالة الحضور'),
        content: Text('إزالة تسجيل حضور ${student.name} من هذه الجلسة؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('إزالة')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final prev = _registered[student.id];
    await AdminRepositoryScope.of(context)
        .removeAttendance(widget.sessionId, student.id);
    if (!mounted) return;
    setState(() {
      final next = {..._registered}..remove(student.id);
      _registered = next;
    });
    _snack('أُزيل حضور ${student.name}',
        restore: () => _register(student, at: prev));
  }

  /// Long-press actions: adjust time / remove attendance.
  Future<void> _longPress(AdminStudentRow student) async {
    final registered = _registered.containsKey(student.id);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(student.name),
              subtitle: Text(registered
                  ? 'مسجّل ${formatTime(_registered[student.id]!)}'
                  : 'غير مسجّل'),
            ),
            const Divider(height: 1),
            if (registered) ...[
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('ضبط زمن التسجيل'),
                onTap: () {
                  Navigator.of(context).pop();
                  _adjustTime(student);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline,
                    color:
                        Theme.of(context).extension<AppTokens>()!.dangerText),
                title: const Text('إزالة الحضور'),
                onTap: () {
                  Navigator.of(context).pop();
                  _remove(student);
                },
              ),
            ] else
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('تسجيل حضور بزمن مخصّص'),
                onTap: () {
                  Navigator.of(context).pop();
                  _adjustTime(student);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _snack(String message,
      {bool undoable = false,
      AdminStudentRow? student,
      void Function()? restore,
      void Function()? onAdjust}) {
    final actions = <({String label, VoidCallback onTap})>[
      if (undoable || restore != null)
        (
          label: 'تراجع',
          onTap: () {
            _hideBanner();
            if (restore != null) {
              restore();
            } else if (student != null) {
              _undo(student);
            }
          },
        ),
      if (onAdjust != null)
        (
          label: 'ضبط الزمن',
          onTap: () {
            _hideBanner();
            onAdjust();
          },
        ),
    ];
    if (actions.isEmpty) {
      // Plain transient feedback via the snack bar.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text(message), duration: const Duration(seconds: 3)));
      return;
    }
    _showBanner(message, actions);
  }

  // ── Temporary in-page bar with two actions (undo + adjust time) ──────────

  String? _bannerMessage;
  List<({String label, VoidCallback onTap})> _bannerActions = const [];
  Timer? _bannerTimer;

  void _showBanner(
      String message, List<({String label, VoidCallback onTap})> actions) {
    _bannerTimer?.cancel();
    setState(() {
      _bannerMessage = message;
      _bannerActions = actions;
    });
    _bannerTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) _hideBanner();
    });
  }

  void _hideBanner() {
    _bannerTimer?.cancel();
    if (!mounted || _bannerMessage == null) return;
    setState(() {
      _bannerMessage = null;
      _bannerActions = const [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Scaffold(
      appBar: AppBar(title: Text(_loading ? 'الحضور' : _sessionTitle)),
      body: Stack(
        children: [
          _body(context, tokens),
          if (_bannerMessage != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _banner(context, tokens),
            ),
        ],
      ),
    );
  }

  /// Temporary bar with «تراجع» / «ضبط الزمن» actions.
  Widget _banner(BuildContext context, AppTokens tokens) {
    return AppCard(
      color: tokens.infoTint,
      borderColor: tokens.infoLight,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 18, color: tokens.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_bannerMessage!,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          for (final action in _bannerActions)
            TextButton(
              onPressed: action.onTap,
              child: Text(action.label),
            ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, AppTokens tokens) {
    return Column(
        children: [
          // Camera (compact, scan-only area).
          SizedBox(
            height: 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: (capture) {
                    final barcode = capture.barcodes.firstOrNull;
                    final value = barcode?.rawValue;
                    if (value != null) _handleCode(value);
                  },
                  errorBuilder: (context, error) => Container(
                    color: tokens.surfaceSubtle,
                    alignment: Alignment.center,
                    child: Text('الكاميرا غير متاحة — استخدم البحث أدناه',
                        style: TextStyle(color: tokens.textMuted)),
                  ),
                ),
                if (_lastScan != null)
                  Positioned(
                    bottom: 10,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        key: ValueKey('$_lastScan-$_lastScanOk'),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _lastScanOk
                              ? tokens.brand
                              : tokens.danger,
                          borderRadius:
                              BorderRadius.circular(tokens.radiusSmall),
                        ),
                        child: Text(
                          _lastScanOk
                              ? 'سُجّل: $_lastScan'
                              : 'غير موجود: $_lastScan',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Search (always visible — no separate manual mode).
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'بحث: اسم / معرّف / باركود / حلقة',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'مسح',
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(_search.clear),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_results.length} طالب · سُجّل ${_registered.length}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: tokens.textMuted),
                ),
                const Spacer(),
                Text(
                  'اضغط للتسجيل · اضغط مطولًا للزمن',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? const EmptyState(
                        title: 'لا نتائج',
                        icon: Icons.person_search_outlined,
                        message: 'جرّب الاسم أو الباركود',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: _results.length,
                        itemBuilder: (context, i) =>
                            _row(tokens, _results[i]),
                      ),
          ),
        ],
    );
  }

  Widget _row(AppTokens tokens, AdminStudentRow student) {
    final time = _registered[student.id];
    final registered = time != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        color: registered ? tokens.brandTint : null,
        borderColor: registered ? tokens.brandBorder : null,
        onTap: registered ? null : () => _register(student),
        onLongPress: () => _longPress(student),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  registered ? tokens.brand : tokens.brandTint,
              child: Icon(
                registered ? Icons.check : Icons.person,
                size: 18,
                color: registered ? Colors.white : tokens.brandText,
              ),
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
                      student.barcode,
                    ].join(' · '),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: tokens.textMuted),
                  ),
                ],
              ),
            ),
            if (registered) ...[
              Text(formatTime(time),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: tokens.textMuted)),
              const SizedBox(width: 8),
              const StatusBadge(label: 'حاضر', color: Color(0xFF00A572)),
            ] else
              Icon(Icons.add_circle_outline, color: tokens.brandText),
          ],
        ),
      ),
    );
  }
}
