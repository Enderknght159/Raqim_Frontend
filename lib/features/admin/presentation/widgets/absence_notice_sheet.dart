import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/admin_local_repository.dart';
import '../../domain/admin_models.dart';

/// E3 — absence notices: pick the absent students and send each an in-app
/// notice. Returns the number of notices sent (null when cancelled).
Future<int?> showAbsenceNoticeSheet(
  BuildContext context, {
  required int sessionId,
  required List<AdminSessionMember> absentees,
  required AdminLocalRepository repository,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => AbsenceNoticeSheet(
      sessionId: sessionId,
      absentees: absentees,
      repository: repository,
    ),
  );
}

class AbsenceNoticeSheet extends StatefulWidget {
  const AbsenceNoticeSheet({
    super.key,
    required this.sessionId,
    required this.absentees,
    required this.repository,
  });

  final int sessionId;
  final List<AdminSessionMember> absentees;
  final AdminLocalRepository repository;

  @override
  State<AbsenceNoticeSheet> createState() => _AbsenceNoticeSheetState();
}

class _AbsenceNoticeSheetState extends State<AbsenceNoticeSheet> {
  late final Set<int> _selected = {
    for (final a in widget.absentees) a.studentId,
  };
  var _loading = false;

  Future<void> _send() async {
    if (_selected.isEmpty || _loading) return;
    setState(() => _loading = true);
    final count = await widget.repository.sendAbsenceNotices(
      sessionId: widget.sessionId,
      studentIds: _selected.toList(),
    );
    if (!mounted) return;
    Navigator.of(context).pop(count);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.campaign_outlined, color: tokens.info),
              const SizedBox(width: 8),
              Expanded(
                child: Text('إشعارات الغياب',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              StatusBadge(
                  label: '${widget.absentees.length} غائب',
                  color: widget.absentees.isEmpty
                      ? tokens.textMuted
                      : tokens.danger),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'يصل إشعار داخل التطبيق لكل طالب محدد.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: tokens.textMuted),
          ),
          const SizedBox(height: 8),
          if (widget.absentees.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('لا غياب في هذه الجلسة',
                  style: Theme.of(context).textTheme.bodyMedium),
            )
          else ...[
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() {
                    if (_selected.length == widget.absentees.length) {
                      _selected.clear();
                    } else {
                      _selected
                        ..clear()
                        ..addAll(widget.absentees.map((a) => a.studentId));
                    }
                  }),
                  child: Text(
                    _selected.length == widget.absentees.length
                        ? 'إلغاء تحديد الكل'
                        : 'تحديد الكل',
                  ),
                ),
                const Spacer(),
                Text('${_selected.length} محدد',
                    style: TextStyle(
                        color: tokens.textMuted, fontSize: 13)),
              ],
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.absentees.length,
                itemBuilder: (context, i) {
                  final a = widget.absentees[i];
                  return CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: _selected.contains(a.studentId),
                    title: Text(a.name),
                    onChanged: (v) => setState(() {
                      if (v == true) {
                        _selected.add(a.studentId);
                      } else {
                        _selected.remove(a.studentId);
                      }
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: _loading
                  ? 'جارِ الإرسال…'
                  : 'إرسال الإشعارات (${_selected.length})',
              icon: Icons.send_outlined,
              loading: _loading,
              onPressed: _selected.isEmpty ? null : _send,
            ),
          ],
        ],
      ),
    );
  }
}
