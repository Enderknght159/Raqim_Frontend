import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/adaptive_sheet.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../shared/permissions.dart';
import '../../domain/admin_models.dart';
import 'permission_scope_picker.dart';

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
  'quranCertificates': 'شهادات القرآن',
};

const _actions = [
  ('view', 'عرض'),
  ('create', 'إضافة'),
  ('update', 'تعديل'),
  ('delete', 'حذف'),
  ('export', 'تصدير'),
];

const _abilityList = [
  ('messagesExport', 'تصدير الرسائل'),
  ('barcodeExport', 'تصدير الباركود'),
  ('phoneSearch', 'بحث الهاتف'),
  ('dataChangeApproval', 'اعتماد طلبات التغيير'),
  ('auditView', 'عرض التدقيق'),
  ('userManagement', 'إدارة المستخدمين'),
  ('permissionManagement', 'إدارة الصلاحيات'),
];

/// Opens the partial permission editor (module × action × scope) and returns
/// the edited [AdminUserPermissions], or null when cancelled.
Future<AdminUserPermissions?> showPermissionEditor(
  BuildContext context, {
  required AdminUserPermissions initial,
  String title = 'الصلاحيات',
  int? targetUserId,
}) {
  return showAppSheet<AdminUserPermissions>(
    context: context,
    maxWidth: 720,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => AdminPermissionEditor(
      initial: initial,
      title: title,
      targetUserId: targetUserId,
    ),
  );
}

class AdminPermissionEditor extends StatefulWidget {
  const AdminPermissionEditor({
    super.key,
    required this.initial,
    this.title = 'الصلاحيات',
    this.targetUserId,
    this.onSave,
  });

  final AdminUserPermissions initial;
  final String title;

  /// Account being edited; used to prevent self-demotion.
  final int? targetUserId;

  /// Test/embed hook: when provided, the result is delivered here instead of
  /// popping the current route.
  final ValueChanged<AdminUserPermissions>? onSave;

  @override
  State<AdminPermissionEditor> createState() => _AdminPermissionEditorState();
}

class _AdminPermissionEditorState extends State<AdminPermissionEditor> {
  late bool _isAdmin = widget.initial.isAdmin;
  late final Map<String, AdminModuleGrant> _modules = {
    for (final key in AdminUserPermissions.moduleKeys)
      key: widget.initial.actionsFor(key),
  };
  late final Set<String> _abilities = {...widget.initial.abilities};

  AdminModuleGrant _grant(String module) =>
      _modules[module] ?? AdminModuleGrant.none;

  void _setGrant(String module, AdminModuleGrant grant) {
    setState(() {
      // Attendance lives inside course sessions; without `courses.view` the
      // supervisor cannot reach a session screen at all. Keep it granted
      // automatically while attendance is enabled.
      if (module == 'attendance' && (grant.hasAnyAction || grant.hasAnyScope)) {
        _modules['courses'] = _grant('courses').copyWith(view: true);
      }
      if (module == 'courses' && _grant('attendance').hasAnyAction) {
        grant = grant.copyWith(view: true);
      }
      if (grant.hasAnyAction || grant.hasAnyScope) {
        _modules[module] = grant;
      } else {
        _modules.remove(module);
      }
    });
  }

  bool get _attendanceEnabled => !_isAdmin && _grant('attendance').hasAnyAction;

  bool get _coursesRequired => _attendanceEnabled;

  bool _hasFullDataAccess() {
    if (_isAdmin) return true;
    for (final module in AdminUserPermissions.moduleKeys) {
      if (module == 'imports' || module == 'quranCertificates') continue;
      final grant = _grant(module);
      if (!grant.view || grant.hasAnyScope) return false;
    }
    return true;
  }

  /// Any admin can demote another admin (verified against the live API on
  /// 2026-10-31), but never themselves.
  bool get _canChangeAdmin {
    if (!widget.initial.isAdmin) return true;
    final me = currentProfile(context);
    final target = widget.targetUserId;
    return me == null || target == null || me.id != target;
  }

  AdminUserPermissions _result() {
    if (!_isAdmin && _grant('attendance').hasAnyAction) {
      _modules['courses'] = _grant('courses').copyWith(view: true);
    }
    return AdminUserPermissions(
      isAdmin: _isAdmin,
      modules: {
        for (final entry in _modules.entries)
          if (entry.value.hasAnyAction || entry.value.hasAnyScope)
            entry.key: entry.value,
      },
      abilities: {..._abilities},
    );
  }

  void _save() {
    final result = _result();
    final onSave = widget.onSave;
    if (onSave != null) {
      onSave(result);
      return;
    }
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final hasAny = _isAdmin || _modules.values.any((g) => g.hasAnyAction);
    final canPermissionManage = _isAdmin;
    final hasFullAccess = _hasFullDataAccess();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      builder: (context, controller) => Column(
        children: [
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              children: [
                Row(
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    StatusBadge(
                      label: hasAny ? 'مشرف' : 'بلا صلاحيات',
                      color: hasAny ? tokens.info : tokens.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  key: const ValueKey('admin-switch'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('مدير عام'),
                  subtitle: Text(
                    !_canChangeAdmin
                        ? 'لا يمكنك إزالة صفة المدير من حسابك الحالي.'
                        : widget.initial.isAdmin
                        ? 'إيقافه يزيل صفة المدير وكل صلاحيات الإشراف؛ '
                              'يمكنك بعدها منحه صلاحيات مشرف جديدة.'
                        : 'عند التفعيل يمنح وصولًا كاملًا وتُقفل الوحدات.',
                    style: const TextStyle(fontSize: 12),
                  ),
                  value: _isAdmin,
                  onChanged: _canChangeAdmin
                      ? (value) => setState(() {
                          _isAdmin = value;
                          if (!value && widget.initial.isAdmin) {
                            // The server reports every module as true for an
                            // admin; do not persist that as explicit grants
                            // after demotion.
                            _modules.clear();
                            _abilities.clear();
                          }
                        })
                      : null,
                ),
                const Divider(),
                for (final module in AdminUserPermissions.moduleKeys)
                  _moduleCard(context, module, _moduleLabels[module] ?? module),
                const Divider(),
                Text(
                  'صلاحيات خاصة',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                for (final (key, label) in _abilityList)
                  _abilityTile(
                    key,
                    label,
                    canPermissionManage: canPermissionManage,
                    hasFullAccess: hasFullAccess,
                  ),
                const SizedBox(height: 8),
                Text(
                  'القاعدة: لا وصول بدون منح. الخادم هو جهة التحقق النهائية.',
                  style: TextStyle(color: tokens.textMuted, fontSize: 12),
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
                onPressed: _save,
                child: const Text('حفظ'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moduleCard(BuildContext context, String module, String label) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final lockedByAttendance = module == 'courses' && _coursesRequired;
    final rawGrant = _grant(module);
    final grant = lockedByAttendance ? rawGrant.copyWith(view: true) : rawGrant;
    final enabled = _isAdmin || grant.hasAnyAction;
    final viewLocked = lockedByAttendance;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(4, 0, 12, 8),
      decoration: BoxDecoration(
        color: tokens.surfaceSubtle.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(tokens.radiusSmall),
        border: Border.all(
          color: lockedByAttendance
              ? tokens.brandBorder
              : tokens.borderStructural,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Switch(
                key: ValueKey('module-switch-$module'),
                value: enabled,
                onChanged: _isAdmin || lockedByAttendance
                    ? null
                    : (value) => _setGrant(
                        module,
                        value
                            ? grant.copyWith(view: true)
                            : AdminModuleGrant.none,
                      ),
              ),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              if (lockedByAttendance)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 6),
                  child: StatusBadge(
                    label: 'متطلب للحضور',
                    color: tokens.brand,
                  ),
                ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  _summary(grant, enabled),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: tokens.textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
          if (enabled) ...[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final (action, actionLabel) in _actions)
                  FilterChip(
                    key: ValueKey('module-action-$module-$action'),
                    label: Text(actionLabel),
                    selected: _isAdmin || _actionValue(grant, action),
                    onSelected: _isAdmin || (viewLocked && action == 'view')
                        ? null
                        : (value) => _setGrant(
                            module,
                            _withAction(grant, action, value),
                          ),
                  ),
              ],
            ),
            if (module == 'attendance' && !_isAdmin)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'تفعيل الدورات (عرض) إلزامي ليصل المشرف إلى شاشة الجلسة.',
                  style: TextStyle(color: tokens.textMuted, fontSize: 12),
                ),
              ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                key: ValueKey('module-scope-$module'),
                onPressed: _isAdmin
                    ? null
                    : () async {
                        final updated = await showPermissionScopePicker(
                          context,
                          moduleLabel: label,
                          initial: _grant(module),
                        );
                        if (updated != null) _setGrant(module, updated);
                      },
                icon: const Icon(Icons.filter_alt_outlined, size: 18),
                label: Text(_scopeLabel(grant)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _abilityTile(
    String key,
    String label, {
    required bool canPermissionManage,
    required bool hasFullAccess,
  }) {
    final isPermissionManagement = key == 'permissionManagement';
    final needsFullAccess = key == 'messagesExport' && !hasFullAccess;
    final blocked =
        (_isAdmin || (isPermissionManagement && !canPermissionManage));
    final disabled = blocked || needsFullAccess;
    final subtitle = isPermissionManagement && !canPermissionManage
        ? 'متاحة للمدير فقط'
        : needsFullAccess
        ? 'تتطلب وصولًا كاملًا للبيانات'
        : null;
    return SwitchListTile(
      key: ValueKey('ability-$key'),
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: _isAdmin || _abilities.contains(key),
      onChanged: disabled
          ? null
          : (value) => setState(() {
              if (value) {
                _abilities.add(key);
              } else {
                _abilities.remove(key);
              }
            }),
    );
  }

  String _summary(AdminModuleGrant grant, bool enabled) {
    if (_isAdmin) return 'وصول كامل';
    if (!enabled) return 'معطّلة';
    final actions = [
      for (final (action, label) in _actions)
        if (_actionValue(grant, action)) label,
    ].join(' · ');
    return actions.isEmpty ? 'معطّلة' : actions;
  }

  String _scopeLabel(AdminModuleGrant grant) {
    final parts = <String>[];
    if (grant.courseIds.isNotEmpty) {
      parts.add('دورات: ${grant.courseIds.length}');
    }
    if (grant.teamIds.isNotEmpty) {
      parts.add('حلقات: ${grant.teamIds.length}');
    }
    return parts.isEmpty ? 'النطاق: الكل' : 'النطاق: ${parts.join(' · ')}';
  }

  bool _actionValue(AdminModuleGrant grant, String action) => switch (action) {
    'view' => grant.view,
    'create' => grant.create,
    'update' => grant.update,
    'delete' => grant.delete,
    'export' => grant.export,
    _ => false,
  };

  AdminModuleGrant _withAction(
    AdminModuleGrant grant,
    String action,
    bool value,
  ) => switch (action) {
    'view' => grant.copyWith(view: value),
    'create' => grant.copyWith(create: value),
    'update' => grant.copyWith(update: value),
    'delete' => grant.copyWith(delete: value),
    'export' => grant.copyWith(export: value),
    _ => grant,
  };
}
