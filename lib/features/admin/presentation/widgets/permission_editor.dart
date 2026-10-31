import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/adaptive_sheet.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../shared/permissions.dart';
import '../../domain/admin_models.dart';
import '../../domain/permission_packs.dart';
import 'permission_level_selector.dart';
import 'permission_pack_card.dart';
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

const _abilityList = [
  (
    'messagesExport',
    'تصدير الرسائل',
    'رسائل اليوم والدورة (xlsx). يتطلب وصولًا كاملًا للبيانات.',
  ),
  (
    'barcodeExport',
    'تصدير الباركود',
    'بطاقات/ملصقات الباركود PDF للطلاب المحددين.',
  ),
  ('phoneSearch', 'بحث الهاتف', 'البحث عن الطالب برقم الهاتف.'),
  (
    'dataChangeApproval',
    'اعتماد طلبات التغيير',
    'مراجعة طلبات تعديل بيانات الطلاب واعتمادها أو رفضها.',
  ),
  ('auditView', 'عرض التدقيق', 'سجل التدقيق والإشعارات الإدارية.'),
  (
    'userManagement',
    'إدارة المستخدمين',
    'إنشاء الحسابات وتعديلها وتعطيلها وإعادة تعيين كلمات المرور.',
  ),
];

/// Opens the permission editor (packs + three-level control + advanced modules)
/// and returns the edited [AdminUserPermissions], or null when cancelled.
Future<AdminUserPermissions?> showPermissionEditor(
  BuildContext context, {
  required AdminUserPermissions initial,
  String title = 'الصلاحيات',
  int? targetUserId,
}) {
  return showAppSheet<AdminUserPermissions>(
    context: context,
    maxWidth: 760,
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
  late bool _isAdmin;
  late Map<String, AdminModuleGrant> _modules;
  late Set<String> _abilities;
  late AccountScope _scope;
  bool _scopeMixed = false;

  Map<String, AdminModuleGrant> _initialModules() {
    final modules = <String, AdminModuleGrant>{
      for (final entry in widget.initial.modules.entries)
        if (entry.value.hasAnyAction) entry.key: entry.value,
    };
    final inferred = inferAccountScope(_scopedModules(modules));
    return _isAdmin ? modules : ensurePrerequisites(modules, inferred.scope);
  }

  Map<String, AdminModuleGrant> _scopedModules(
    Map<String, AdminModuleGrant> modules,
  ) {
    return {
      for (final entry in modules.entries)
        if (!permissionUnsupportedModules.contains(entry.key))
          entry.key: entry.value,
    };
  }

  @override
  void initState() {
    super.initState();
    _isAdmin = widget.initial.isAdmin;
    _modules = _initialModules();
    _abilities = {...widget.initial.abilities}..remove('permissionManagement');
    final inferred = inferAccountScope(_scopedModules(_modules));
    _scope = inferred.scope;
    _scopeMixed = inferred.mixed;
  }

  void _update(Map<String, AdminModuleGrant> next) {
    final inferred = inferAccountScope(_scopedModules(next));
    setState(() {
      _modules = next;
      _scope = inferred.scope;
      _scopeMixed = inferred.mixed;
    });
  }

  bool get _canChangeAdmin {
    if (!widget.initial.isAdmin) return true;
    final me = currentProfile(context);
    final target = widget.targetUserId;
    return me == null || target == null || me.id != target;
  }

  void _setAdmin(bool value) {
    setState(() {
      _isAdmin = value;
      if (!value && widget.initial.isAdmin) {
        // The server reports every module as true for an admin; do not persist
        // that as explicit grants after demotion.
        _modules.clear();
        _abilities.clear();
        _scope = AccountScope.all;
        _scopeMixed = false;
      }
    });
  }

  void _togglePack(PermissionPack pack, bool enabled) {
    _update(
      applyPackLevel(
        _modules,
        pack,
        enabled ? pack.defaultLevel : PermissionLevel.none,
        scope: _scope,
      ),
    );
  }

  void _setPackLevel(PermissionPack pack, PermissionLevel level) {
    final snapshot = packSnapshot(pack, _modules);
    final scope = snapshot.enabled && !snapshot.scopeMixed
        ? snapshot.scope
        : _scope;
    _update(applyPackLevel(_modules, pack, level, scope: scope));
  }

  Future<void> _pickAccountScope() async {
    final result = await showAccountScopePicker(context, initial: _scope);
    if (result == null) return;
    final next = applyAccountScope(_scopedModules(_modules), result);
    for (final module in permissionUnsupportedModules) {
      final existing = _modules[module];
      if (existing != null) next[module] = existing;
    }
    _update(next);
  }

  void _setModuleLevel(String module, PermissionLevel level) {
    final current = _modules[module];
    final scope = current == null
        ? _scope
        : AccountScope(courseIds: current.courseIds, teamIds: current.teamIds);
    _update(applyModuleLevel(_modules, module, level, scope: scope));
  }

  void _toggleExport(String module) {
    final current = _modules[module];
    if (current == null) return;
    _update(toggleModuleExport(_modules, module, enabled: !current.export));
  }

  Future<void> _pickModuleScope(String module) async {
    final current = _modules[module];
    if (current == null) return;
    final updated = await showPermissionScopePicker(
      context,
      moduleLabel: _moduleLabels[module] ?? module,
      initial: current,
    );
    if (updated == null) return;
    _update(
      applyModuleScope(
        _modules,
        module,
        AccountScope(courseIds: updated.courseIds, teamIds: updated.teamIds),
      ),
    );
  }

  AdminUserPermissions _result() {
    final modules = <String, AdminModuleGrant>{};
    for (final entry in _modules.entries) {
      final grant = normalizeGrant(entry.value);
      if (grant.hasAnyAction) modules[entry.key] = grant;
    }
    final abilities = {..._abilities}..remove('permissionManagement');
    return AdminUserPermissions(
      isAdmin: _isAdmin,
      modules: modules,
      abilities: abilities,
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

  String _accessSummary() {
    if (_isAdmin) return 'وصول كامل';
    final packs = permissionPacks
        .where((pack) => packSnapshot(pack, _modules).enabled)
        .length;
    if (packs == 0 && _abilities.isEmpty) return 'بلا صلاحيات';
    final abilityPart = _abilities.isEmpty
        ? ''
        : ' · ${_abilities.length} خاصة';
    return '$packs حزمة$abilityPart';
  }

  String _scopeLabel(AccountScope scope, {required bool mixed}) {
    if (mixed) return 'نطاق مخصص';
    if (scope.isAll) return 'كل الدورات والحلقات';
    final parts = <String>[];
    if (scope.courseIds.isNotEmpty) {
      parts.add('دورات: ${scope.courseIds.length}');
    }
    if (scope.teamIds.isNotEmpty) {
      parts.add('حلقات: ${scope.teamIds.length}');
    }
    return parts.isEmpty ? 'كل الدورات والحلقات' : parts.join(' · ');
  }

  bool _hasFullDataAccess() {
    if (_isAdmin) return true;
    const required = [
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
    ];
    for (final module in required) {
      final grant = _modules[module];
      if (grant == null || !grant.view || grant.hasAnyScope) return false;
    }
    return true;
  }

  bool get _needsStudentsCompat {
    if (_isAdmin) return false;
    if (_modules['students']?.view ?? false) return false;
    const writable = {
      'attendance',
      'points',
      'memorization',
      'recitation',
      'matn',
      'exams',
    };
    return permissionPacks.any((pack) {
      if (!pack.coreModules.any(writable.contains)) return false;
      return packSnapshot(pack, _modules).level.includes(PermissionLevel.write);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final summaryColor = _isAdmin || _accessSummary() != 'بلا صلاحيات'
        ? tokens.info
        : tokens.textMuted;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      builder: (context, controller) => Column(
        children: [
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              children: [
                _header(context, summaryColor),
                const SizedBox(height: 10),
                _adminCard(context),
                const SizedBox(height: 10),
                _scopeCard(context),
                if (_needsStudentsCompat) ...[
                  const SizedBox(height: 10),
                  _compatNotice(context),
                ],
                const SizedBox(height: 16),
                _sectionTitle(context, 'الحزم اليومية', Icons.bolt_outlined),
                const SizedBox(height: 8),
                for (final pack in permissionDailyPacks) ...[
                  _packCard(context, pack),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 8),
                _sectionTitle(
                  context,
                  'البيانات والإدارة',
                  Icons.folder_open_outlined,
                ),
                const SizedBox(height: 8),
                for (final pack in permissionDataPacks) ...[
                  _packCard(context, pack),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 8),
                _sectionTitle(context, 'صلاحيات خاصة', Icons.vpn_key_outlined),
                const SizedBox(height: 4),
                for (final (key, label, description) in _abilityList)
                  _abilityTile(
                    key,
                    label,
                    description,
                    hasFullAccess: _hasFullDataAccess(),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 4),
                  child: Text(
                    'التقارير مؤجلة إلى مرحلة لاحقة (لا شاشة بعد)، وإدارة صلاحيات '
                    'الآخرين متاحة للمدير العام فقط حاليًا.',
                    style: TextStyle(color: tokens.textMuted, fontSize: 11.5),
                  ),
                ),
                const SizedBox(height: 8),
                _advancedSection(context),
                const SizedBox(height: 10),
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
                child: const Text('حفظ الصلاحيات'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, Color summaryColor) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(label: _accessSummary(), color: summaryColor),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          'اختر الحزم التي يحتاجها الحساب. كل مستوى يشمل ما قبله تلقائيًا.',
          style: TextStyle(color: tokens.textMuted, fontSize: 12.5),
        ),
      ],
    );
  }

  Widget _adminCard(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final subtitle = !_canChangeAdmin
        ? 'لا يمكنك إزالة صفة المدير من حسابك الحالي.'
        : widget.initial.isAdmin
        ? 'إيقافه يزيل صفة المدير وكل صلاحيات الإشراف؛ يمكنك بعدها منحه حزمًا جديدة.'
        : 'عند التفعيل يمنح وصولًا كاملًا وتُقفل كل الخيارات.';
    return Container(
      decoration: BoxDecoration(
        color: _isAdmin
            ? tokens.brandTint.withValues(alpha: 0.45)
            : tokens.surfaceSubtle.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(tokens.radiusSmall),
        border: Border.all(
          color: _isAdmin ? tokens.brandBorder : tokens.borderStructural,
        ),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 8, 4),
      child: Row(
        children: [
          Icon(
            Icons.admin_panel_settings_outlined,
            color: _isAdmin ? tokens.brandText : tokens.textMuted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'مدير عام',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    if (_isAdmin)
                      StatusBadge(label: 'وصول كامل', color: tokens.brand),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: TextStyle(color: tokens.textMuted, fontSize: 11.5),
                ),
              ],
            ),
          ),
          Switch(
            key: const ValueKey('admin-switch'),
            value: _isAdmin,
            onChanged: _canChangeAdmin ? _setAdmin : null,
          ),
        ],
      ),
    );
  }

  Widget _scopeCard(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Container(
      decoration: BoxDecoration(
        color: tokens.surfaceSubtle.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(tokens.radiusSmall),
        border: Border.all(color: tokens.borderStructural),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 10),
      child: Row(
        children: [
          Icon(Icons.filter_alt_outlined, color: tokens.brandText),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'نطاق الحساب',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    if (_scopeMixed)
                      StatusBadge(label: 'مخصص', color: tokens.danger),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  '${_scopeLabel(_scope, mixed: _scopeMixed)} · يُطبق على كل الحزم.',
                  style: TextStyle(color: tokens.textMuted, fontSize: 11.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          TextButton(
            key: const ValueKey('account-scope'),
            onPressed: _isAdmin ? null : _pickAccountScope,
            child: const Text('تغيير'),
          ),
        ],
      ),
    );
  }

  Widget _compatNotice(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Container(
      decoration: BoxDecoration(
        color: tokens.danger.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(tokens.radiusSmall),
        border: Border.all(color: tokens.danger.withValues(alpha: 0.35)),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: tokens.dangerText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'توافق الخادم الحالي: الخادم يرفض كتابة السجلات دون صلاحية '
              '«عرض الطلاب» (مخالفة للخطة). أُرسل طلب الإصلاح للباك؛ حتى يصل، '
              'أضف حزمة «الطلاب» بوضع القراءة أو استخدم التحكم المتقدم.',
              style: TextStyle(color: tokens.dangerText, fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Row(
      children: [
        Icon(icon, size: 18, color: tokens.brandText),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
      ],
    );
  }

  Widget _packCard(BuildContext context, PermissionPack pack) {
    final snapshot = packSnapshot(pack, _modules);
    return PermissionPackCard(
      pack: pack,
      snapshot: snapshot,
      scopeLabel: snapshot.scopeMixed
          ? 'نطاق مخصص'
          : _scopeLabel(snapshot.scope, mixed: false),
      locked: _isAdmin,
      onToggle: (value) => _togglePack(pack, value),
      onLevel: (level) => _setPackLevel(pack, level),
      onScope: _pickAccountScope,
    );
  }

  Widget _abilityTile(
    String key,
    String label,
    String description, {
    required bool hasFullAccess,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final needsFullAccess = key == 'messagesExport' && !hasFullAccess;
    final disabled = _isAdmin || needsFullAccess;
    final subtitle = needsFullAccess
        ? '$description (يتطلب كل الوحدات بلا نطاق)'
        : description;
    return SwitchListTile(
      key: ValueKey('ability-$key'),
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: tokens.textMuted, fontSize: 11.5),
      ),
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

  Widget _advancedSection(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final hasCustom = permissionAdvancedOnlyModules.any(
      (module) => _modules[module]?.hasAnyAction ?? false,
    );
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: const ValueKey('advanced-permissions'),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 2),
        leading: Icon(Icons.tune, color: tokens.textMuted),
        title: Row(
          children: [
            const Text(
              'تحكم متقدم',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            if (hasCustom) ...[
              const SizedBox(width: 6),
              StatusBadge(label: 'مخصص', color: tokens.info),
            ],
          ],
        ),
        subtitle: Text(
          'وحدات وإجراءات ونطاقات دقيقة للحالات الاستثنائية.',
          style: TextStyle(color: tokens.textMuted, fontSize: 11.5),
        ),
        children: [
          for (final module in AdminUserPermissions.moduleKeys) ...[
            _advancedModuleRow(context, module),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }

  Widget _advancedModuleRow(BuildContext context, String module) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final grant = _modules[module] ?? AdminModuleGrant.none;
    final unsupported = permissionUnsupportedModules.contains(module);
    final deferred = permissionDeferredModules.contains(module);
    final lockedModule = unsupported || deferred;
    final level = levelForModule(
      module,
      grant,
      sessionManaged: _modules['courses']?.update ?? false,
    );
    final enabled = level.isEnabled;
    return Container(
      key: ValueKey('advanced-module-$module'),
      decoration: BoxDecoration(
        color: tokens.surfaceSubtle.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(tokens.radiusSmall),
        border: Border.all(color: tokens.borderStructural),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      _moduleLabels[module] ?? module,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (unsupported)
                      StatusBadge(label: 'غير مدعوم', color: tokens.danger),
                    if (deferred)
                      StatusBadge(label: 'مؤجل', color: tokens.textMuted),
                  ],
                ),
              ),
              if (!lockedModule)
                FilterChip(
                  key: ValueKey('advanced-export-$module'),
                  visualDensity: VisualDensity.compact,
                  label: const Text('تصدير'),
                  avatar: Icon(
                    Icons.file_download_outlined,
                    size: 15,
                    color: enabled ? tokens.brandText : tokens.textMuted,
                  ),
                  selected: grant.export,
                  onSelected: _isAdmin || !enabled
                      ? null
                      : (_) => _toggleExport(module),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PermissionLevelSelector(
                value: level,
                keyPrefix: 'advanced-level-$module',
                compact: true,
                onChanged: _isAdmin || lockedModule
                    ? null
                    : (value) => _setModuleLevel(module, value),
              ),
              if (enabled)
                _AdvancedScopeChip(
                  key: ValueKey('advanced-scope-$module'),
                  label: _scopeLabel(
                    AccountScope(
                      courseIds: grant.courseIds,
                      teamIds: grant.teamIds,
                    ),
                    mixed: false,
                  ),
                  enabled: !_isAdmin && !lockedModule,
                  onTap: () => _pickModuleScope(module),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdvancedScopeChip extends StatelessWidget {
  const _AdvancedScopeChip({
    super.key,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(9, 5, 10, 5),
          decoration: BoxDecoration(
            color: tokens.surfaceSubtle,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: tokens.borderStructural),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.filter_alt_outlined,
                size: 14,
                color: enabled ? tokens.brandText : tokens.textMuted,
              ),
              const SizedBox(width: 5),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 190),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: enabled ? tokens.textPrimary : tokens.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
