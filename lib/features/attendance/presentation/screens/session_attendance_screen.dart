import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/responsive_scope.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../admin/domain/admin_models.dart';
import '../../../admin/presentation/admin_shell.dart';
import '../cubits/session_attendance_cubit.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

/// Unified session attendance: camera scan + tolerant auto-search in the same
/// page. Tap a name = register attendance; the undo snackbar offers «تراجع»
/// and «ضبط الزمن»; long-press opens time adjust / remove with undo window.
class SessionAttendanceScreen extends StatelessWidget {
  const SessionAttendanceScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SessionAttendanceCubit(
        AdminRepositoryScope.of(context),
        sessionId: sessionId,
      )..load(),
      child: const _SessionAttendanceView(),
    );
  }
}

class _SessionAttendanceView extends StatefulWidget {
  const _SessionAttendanceView();

  @override
  State<_SessionAttendanceView> createState() => _SessionAttendanceViewState();
}

class _SessionAttendanceViewState extends State<_SessionAttendanceView> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final _search = TextEditingController();
  Timer? _bannerTimer;
  String? _bannerMessage;
  List<({String label, VoidCallback onTap})> _bannerActions = const [];
  int _lastEventId = 0;

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _controller.dispose();
    _search.dispose();
    super.dispose();
  }

  SessionAttendanceCubit get _cubit => context.read<SessionAttendanceCubit>();

  void _onEvent(SessionAttendanceState state) {
    final event = state.event;
    if (event == null || state.eventId == _lastEventId) return;
    _lastEventId = state.eventId;
    final member = _memberFor(state, event);
    switch (event.kind) {
      case AttendanceEventKind.registered:
        _showBanner('سُجّل حضور ${event.studentName}', [
          (
            label: 'تراجع',
            onTap: () => _cubit.undo(event.studentId, previousTime: event.time),
          ),
          (
            label: 'ضبط الزمن',
            onTap: () => _pickTime(state, member, current: event.time),
          ),
        ]);
      case AttendanceEventKind.duplicate:
        _showBanner('${event.studentName} مسجّل مسبقًا', [
          (
            label: 'ضبط الزمن',
            onTap: () => _pickTime(state, member, current: event.time),
          ),
        ]);
      case AttendanceEventKind.removed:
        _showBanner('أُزيل حضور ${event.studentName}', [
          (
            label: 'تراجع',
            onTap: () => _cubit.register(member, at: event.time),
          ),
        ]);
      case AttendanceEventKind.failed:
        _hideBanner();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(event.message ?? 'تعذر تسجيل الحضور')),
          );
    }
  }

  AdminSessionMember _memberFor(
    SessionAttendanceState state,
    AttendanceEvent event,
  ) {
    return state.roster
            .where((m) => m.studentId == event.studentId)
            .firstOrNull ??
        AdminSessionMember(
          studentId: event.studentId,
          name: event.studentName,
          arrivalTime: event.time,
        );
  }

  void _showBanner(
    String message,
    List<({String label, VoidCallback onTap})> actions,
  ) {
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
    return BlocListener<SessionAttendanceCubit, SessionAttendanceState>(
      listener: (context, state) => _onEvent(state),
      child: BlocBuilder<SessionAttendanceCubit, SessionAttendanceState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text(
              state.session == null
                  ? 'الحضور'
                  : 'جلسة #${state.session!.index} — '
                        '${formatDate(state.session!.date)}',
            ),
          ),
          body: Stack(
            children: [
              _body(context, state),
              if (_bannerMessage != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: _banner(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _banner(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      color: tokens.infoTint,
      borderColor: tokens.infoLight,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 18, color: tokens.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _bannerMessage!,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          for (final action in _bannerActions)
            TextButton(onPressed: action.onTap, child: Text(action.label)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, SessionAttendanceState state) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    if (state.loading) return const AppLoadingView();
    if (state.error != null) {
      return AppErrorView(error: state.error, onRetry: _cubit.load);
    }
    final data = ResponsiveScope.of(context);
    final camera = _cameraPanel(tokens, state);
    final list = _listPane(context, tokens, state);

    if (data.isCompact) {
      return Column(
        children: [
          SizedBox(height: data.dense ? 150 : 190, child: camera),
          Expanded(child: list),
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: 5, child: camera),
        VerticalDivider(width: 1, thickness: 1, color: tokens.borderStructural),
        Expanded(flex: 6, child: list),
      ],
    );
  }

  Widget _cameraPanel(AppTokens tokens, SessionAttendanceState state) {
    return Stack(
      alignment: Alignment.center,
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            final barcode = capture.barcodes.firstOrNull;
            final value = barcode?.rawValue;
            if (value != null) _cubit.handleScan(value);
          },
          errorBuilder: (context, error) => Container(
            color: tokens.surfaceSubtle,
            alignment: Alignment.center,
            child: Text(
              'الكاميرا غير متاحة — استخدم البحث',
              textAlign: TextAlign.center,
              style: TextStyle(color: tokens.textMuted),
            ),
          ),
        ),
        if (state.lastScan != null && state.lastScan!.isNotEmpty)
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Container(
                key: ValueKey('${state.lastScan}-${state.lastScanOk}'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: state.lastScanOk ? tokens.brand : tokens.danger,
                  borderRadius: BorderRadius.circular(tokens.radiusSmall),
                ),
                child: Text(
                  state.lastScanOk
                      ? 'سُجّل: ${state.lastScan}'
                      : 'غير موجود: ${state.lastScan}',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _listPane(
    BuildContext context,
    AppTokens tokens,
    SessionAttendanceState state,
  ) {
    final compact = ResponsiveScope.of(context).isCompact;
    final results = state.visible;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: TextField(
            controller: _search,
            onChanged: (value) {
              setState(() {});
              _cubit.setQuery(value);
            },
            decoration: InputDecoration(
              hintText: 'بحث: اسم / معرّف',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'مسح',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _search.clear();
                        _cubit.setQuery('');
                      },
                    ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  '${results.length} طالب · سُجّل ${state.registered.length}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
              ),
              if (!compact) ...[
                const Spacer(),
                Flexible(
                  child: Text(
                    'اضغط للتسجيل · اضغط مطولًا للزمن',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: results.isEmpty
              ? const EmptyState(
                  title: 'لا نتائج',
                  icon: Icons.person_search_outlined,
                  message: 'جرّب الاسم أو الباركود',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: results.length,
                  itemBuilder: (context, i) => _row(tokens, state, results[i]),
                ),
        ),
      ],
    );
  }

  Widget _row(
    AppTokens tokens,
    SessionAttendanceState state,
    AdminSessionMember member,
  ) {
    final time = state.registered[member.studentId];
    final registered = time != null;
    final pending = state.pending.contains(member.studentId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        color: registered ? tokens.brandTint : null,
        borderColor: registered ? tokens.brandBorder : null,
        onTap: registered || pending ? null : () => _cubit.register(member),
        onLongPress: pending ? null : () => _longPress(member),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: registered ? tokens.brand : tokens.brandTint,
              child: pending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
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
                  Text(
                    member.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    member.studentId.toString(),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                  ),
                ],
              ),
            ),
            if (pending)
              Text(
                'جارٍ التسجيل…',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
              )
            else if (registered) ...[
              Text(
                formatTime(time),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
              ),
              const SizedBox(width: 8),
              const StatusBadge(label: 'حاضر', color: Color(0xFF00A572)),
            ] else
              Icon(Icons.add_circle_outline, color: tokens.brandText),
          ],
        ),
      ),
    );
  }

  Future<void> _longPress(AdminSessionMember member) async {
    final state = context.read<SessionAttendanceCubit>().state;
    final registered = state.registered.containsKey(member.studentId);
    await showAppSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(member.name),
              subtitle: Text(
                registered
                    ? 'مسجّل ${formatTime(state.registered[member.studentId]!)}'
                    : 'غير مسجّل',
              ),
            ),
            const Divider(height: 1),
            if (registered) ...[
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('ضبط زمن التسجيل'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickTime(
                    state,
                    member,
                    current: state.registered[member.studentId],
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).extension<AppTokens>()!.dangerText,
                ),
                title: const Text('إزالة الحضور'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _remove(member);
                },
              ),
            ] else
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('تسجيل حضور بزمن مخصّص'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickTime(state, member);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime(
    SessionAttendanceState state,
    AdminSessionMember member, {
    DateTime? current,
  }) async {
    final session = state.session;
    if (session == null) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: current == null
          ? TimeOfDay.now()
          : TimeOfDay.fromDateTime(current),
    );
    if (picked == null || !mounted) return;
    final at = DateTime(
      session.date.year,
      session.date.month,
      session.date.day,
      picked.hour,
      picked.minute,
    );
    await _cubit.adjustTime(member, at);
  }

  Future<void> _remove(AdminSessionMember member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إزالة الحضور'),
        content: Text('إزالة تسجيل حضور ${member.name} من هذه الجلسة؟'),
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
    await _cubit.remove(member);
  }
}
