import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/status_badge.dart';

/// Result of the permission editor for one account.
class AdminPermissionResult {
  const AdminPermissionResult({
    required this.isAdmin,
    required this.granted,
    required this.abilities,
    this.isTeacher = false,
  });

  final bool isAdmin;
  final Set<String> granted;
  final Set<String> abilities;
  final bool isTeacher;

  bool get isSupervisor =>
      isAdmin || granted.isNotEmpty || abilities.isNotEmpty;
}

const _modules = [
  'students',
  'attendance',
  'memorization',
  'recitation',
  'matn',
  'points',
  'exams',
  'distributions',
  'teams',
  'courses',
  'reports',
  'imports',
];

const _moduleLabels = {
  'students': 'الطلاب',
  'attendance': 'الحضور',
  'memorization': 'الحفظ',
  'recitation': 'التلاوة',
  'matn': 'المتون',
  'points': 'النقاط',
  'exams': 'الامتحانات',
  'distributions': 'التوزيعات',
  'teams': 'الحلقات',
  'courses': 'الدورات',
  'reports': 'التقارير',
  'imports': 'الاستيراد',
};

const _abilityList = [
  ('messagesExport', 'تصدير الرسائل'),
  ('barcodeExport', 'تصدير الباركود'),
  ('phoneSearch', 'بحث الهاتف'),
  ('dataChangeApproval', 'اعتماد طلبات التغيير'),
  ('auditView', 'عرض التدقيق'),
  ('userManagement', 'إدارة المستخدمين'),
  ('permissionManagement', 'إدارة الصلاحيات'),
];

/// Opens the unit-level permission editor (1/0 toggles + master admin +
/// teacher flag + a shortcut to the teacher's teams when [teacherTeams] is
/// provided). Returns the new permissions or null when cancelled.
Future<AdminPermissionResult?> showPermissionEditor(
  BuildContext context, {
  required AdminPermissionResult initial,
  String title = 'الصلاحيات',
  List<String> teacherTeams = const [],
  VoidCallback? onViewTeams,
}) {
  return showModalBottomSheet<AdminPermissionResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => AdminPermissionEditor(
      initial: initial,
      title: title,
      teacherTeams: teacherTeams,
      onViewTeams: onViewTeams,
    ),
  );
}

class AdminPermissionEditor extends StatefulWidget {
  const AdminPermissionEditor({
    super.key,
    required this.initial,
    this.title = 'الصلاحيات',
    this.teacherTeams = const [],
    this.onViewTeams,
  });

  final AdminPermissionResult initial;
  final String title;
  final List<String> teacherTeams;
  final VoidCallback? onViewTeams;

  @override
  State<AdminPermissionEditor> createState() => _AdminPermissionEditorState();
}

class _AdminPermissionEditorState extends State<AdminPermissionEditor> {
  late bool _isAdmin = widget.initial.isAdmin;
  late final Set<String> _granted = {...widget.initial.granted};
  late final Set<String> _abilities = {...widget.initial.abilities};
  late final bool _isTeacher = widget.initial.isTeacher;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final hasAny = _isAdmin ||
        _granted.isNotEmpty ||
        _abilities.isNotEmpty;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Row(
            children: [
              Text(widget.title,
                  style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              StatusBadge(
                label: hasAny ? 'مشرف' : 'بلا صلاحيات',
                color: hasAny ? tokens.info : tokens.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('مشرف عام (أدمن)'),
            subtitle: const Text('عند التفعيل تُقفل الوحدات فعليةً'),
            value: _isAdmin,
            onChanged: (v) => setState(() => _isAdmin = v),
          ),
          const Divider(),
          for (final m in _modules)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(_moduleLabels[m] ?? m),
              value: _isAdmin || _granted.contains(m),
              onChanged: _isAdmin
                  ? null
                  : (v) => setState(() {
                        if (v) {
                          _granted.add(m);
                        } else {
                          _granted.remove(m);
                        }
                      }),
            ),
          const Divider(),
          Text('صلاحيات خاصة', style: Theme.of(context).textTheme.titleMedium),
          for (final (key, label) in _abilityList)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(label),
              value: _isAdmin || _abilities.contains(key),
              onChanged: _isAdmin
                  ? null
                  : (v) => setState(() {
                        if (v) {
                          _abilities.add(key);
                        } else {
                          _abilities.remove(key);
                        }
                      }),
            ),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('حساب مدرّس'),
            subtitle: const Text('مؤشر فقط — يُحسب من الباك'),
            value: _isTeacher,
            // The teacher flag is derived from the backend (indicator only).
            onChanged: null,
          ),
          if (widget.teacherTeams.isNotEmpty)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.hub_outlined, color: tokens.accentMatn),
              title: const Text('حلقاته'),
              subtitle: Text(widget.teacherTeams.join(' · ')),
              trailing: widget.onViewTeams == null
                  ? null
                  : Icon(Icons.chevron_left, color: tokens.borderStructural),
              onTap: widget.onViewTeams,
            ),
          const SizedBox(height: 8),
          Text(
            'تُحفظ الصلاحيات على الخادم (غير مفعّل في النسخة التجريبية)',
            style: TextStyle(color: tokens.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.radiusSmall),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(
              AdminPermissionResult(
                isAdmin: _isAdmin,
                granted: _granted,
                abilities: _abilities,
                isTeacher: _isTeacher,
              ),
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
