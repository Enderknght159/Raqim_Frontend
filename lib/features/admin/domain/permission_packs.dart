import 'admin_models.dart';

/// The three user-facing permission strengths used by the pack editor and the
/// advanced module rows.
///
/// The invariant is intentional and enforced when a level is applied:
/// writing always includes reading, and full control always includes writing.
enum PermissionLevel {
  none('معطّلة', 0),
  read('قراءة', 1),
  write('كتابة', 2),
  full('تحكم كامل', 3);

  const PermissionLevel(this.label, this.rank);

  final String label;
  final int rank;

  bool get isEnabled => this != PermissionLevel.none;

  bool includes(PermissionLevel other) => rank >= other.rank;
}

/// A single scope applied to the whole account (courses and/or teams).
///
/// Empty lists mean "all" for that dimension. The editor applies the same scope
/// to every enabled module; the advanced section can still override one module.
class AccountScope {
  const AccountScope({
    this.courseIds = const <int>[],
    this.teamIds = const <int>[],
  });

  static const all = AccountScope();

  final List<int> courseIds;
  final List<int> teamIds;

  bool get isAll => courseIds.isEmpty && teamIds.isEmpty;

  AccountScope copyWith({List<int>? courseIds, List<int>? teamIds}) {
    return AccountScope(
      courseIds: courseIds ?? this.courseIds,
      teamIds: teamIds ?? this.teamIds,
    );
  }

  bool sameAs(AccountScope other) =>
      _sameInts(courseIds, other.courseIds) &&
      _sameInts(teamIds, other.teamIds);

  @override
  String toString() => 'AccountScope(courses: $courseIds, teams: $teamIds)';
}

/// Result of inferring a scope from a group of grants.
class AccountScopeSnapshot {
  const AccountScopeSnapshot({required this.scope, required this.mixed});

  final AccountScope scope;

  /// True when the enabled modules do not all share the same scope.
  final bool mixed;
}

/// Icon key kept in the domain so the model stays independent from Flutter.
enum PermissionPackIcon {
  attendance,
  points,
  quran,
  matn,
  students,
  teams,
  exams,
}

/// One user-facing pack. A pack is a UI projection over one or more backend
/// modules; storage remains `module × action × scope`.
class PermissionPack {
  const PermissionPack({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.coreModules,
    this.prerequisiteModules = const <String>[],
    this.writeIncludesDelete = false,
    this.fullManagesSessions = false,
    this.defaultLevel = PermissionLevel.write,
  });

  final String id;
  final String title;
  final String subtitle;
  final PermissionPackIcon icon;

  /// Modules that carry the pack's own actions.
  final List<String> coreModules;

  /// Modules granted read-only so the pack's screens can open (sessions list,
  /// reciter list). They are shown to the admin as "متطلبات تشغيلية".
  final List<String> prerequisiteModules;

  /// Attendance deliberately includes record deletion at the write level.
  final bool writeIncludesDelete;

  /// Attendance's full level additionally lets the supervisor adjust session
  /// settings (`courses.update`).
  final bool fullManagesSessions;

  final PermissionLevel defaultLevel;
}

const _daily = [
  PermissionPack(
    id: 'attendance',
    title: 'الحضور',
    subtitle: 'تسجيل الحضور والغياب وضبط الجلسة',
    icon: PermissionPackIcon.attendance,
    coreModules: ['attendance'],
    prerequisiteModules: ['courses'],
    writeIncludesDelete: true,
    fullManagesSessions: true,
  ),
  PermissionPack(
    id: 'points',
    title: 'النقاط',
    subtitle: 'المكافآت والخصومات والمعاملات',
    icon: PermissionPackIcon.points,
    coreModules: ['points'],
    prerequisiteModules: ['courses'],
  ),
  PermissionPack(
    id: 'quran',
    title: 'القرآن',
    subtitle: 'الحفظ والتلاوة والتجويد والاختبارات',
    icon: PermissionPackIcon.quran,
    coreModules: ['memorization', 'recitation'],
    prerequisiteModules: ['courses', 'teams'],
  ),
  PermissionPack(
    id: 'matn',
    title: 'المتون',
    subtitle: 'تسميع المتون ومتابعة آخر بيت',
    icon: PermissionPackIcon.matn,
    coreModules: ['matn'],
    prerequisiteModules: ['courses', 'teams'],
  ),
];

const _data = [
  PermissionPack(
    id: 'students',
    title: 'الطلاب',
    subtitle: 'ملف الطالب والبيانات والهواتف',
    icon: PermissionPackIcon.students,
    coreModules: ['students'],
  ),
  PermissionPack(
    id: 'teams',
    title: 'الحلقات والمعلمون',
    subtitle: 'إدارة الحلقات والمعلمين وأنواعها',
    icon: PermissionPackIcon.teams,
    coreModules: ['teams'],
  ),
  PermissionPack(
    id: 'exams',
    title: 'الامتحانات والشهادات',
    subtitle: 'المواد والامتحانات ودرجات الطلاب',
    icon: PermissionPackIcon.exams,
    coreModules: ['exams'],
    prerequisiteModules: ['courses'],
  ),
];

/// Packs shown in the main editor, grouped in two sections.
const permissionDailyPacks = _daily;
const permissionDataPacks = _data;
const permissionPacks = <PermissionPack>[..._daily, ..._data];

PermissionPack? permissionPackById(String id) {
  for (final pack in permissionPacks) {
    if (pack.id == id) return pack;
  }
  return null;
}

/// Modules that only appear in the advanced section. `reports` is postponed
/// until the UI has a real reports surface; the other three have no UI at all.
const permissionAdvancedOnlyModules = <String>[
  'courses',
  'reports',
  'imports',
  'distributions',
  'quranCertificates',
];

/// Modules the backend does not currently enforce (the editor keeps their
/// existing values but does not let the admin edit them).
const permissionUnsupportedModules = <String>{'quranCertificates'};

/// Modules whose UI is not shipped yet; editable but marked as deferred.
const permissionDeferredModules = <String>{'reports'};

/// Result of reading one pack out of a grant map.
class PermissionPackSnapshot {
  const PermissionPackSnapshot({
    required this.level,
    required this.partial,
    required this.scope,
    required this.scopeMixed,
  });

  static const off = PermissionPackSnapshot(
    level: PermissionLevel.none,
    partial: false,
    scope: AccountScope.all,
    scopeMixed: false,
  );

  final PermissionLevel level;

  /// True when the core modules are not all at the same canonical level.
  final bool partial;
  final AccountScope scope;
  final bool scopeMixed;

  bool get enabled => level.isEnabled;
}

/// Infers the most representative account scope and whether modules disagree.
AccountScopeSnapshot inferAccountScope(Map<String, AdminModuleGrant> modules) {
  final active = [
    for (final grant in modules.values)
      if (grant.hasAnyAction) grant,
  ];
  if (active.isEmpty) {
    return const AccountScopeSnapshot(scope: AccountScope.all, mixed: false);
  }

  final scopes = [
    for (final grant in active)
      AccountScope(courseIds: grant.courseIds, teamIds: grant.teamIds),
  ];
  final first = scopes.first;
  final mixed = scopes.any((scope) => !scope.sameAs(first));
  final restricted = scopes.where((scope) => !scope.isAll).firstOrNull;
  return AccountScopeSnapshot(scope: restricted ?? first, mixed: mixed);
}

/// Reads a pack's effective level/scope from the raw module grants.
PermissionPackSnapshot packSnapshot(
  PermissionPack pack,
  Map<String, AdminModuleGrant> modules,
) {
  final grants = [
    for (final module in pack.coreModules)
      modules[module] ?? AdminModuleGrant.none,
  ];
  final active = grants.where((grant) => grant.hasAnyAction).toList();
  if (active.isEmpty) return PermissionPackSnapshot.off;

  final sessionManaged =
      pack.fullManagesSessions && (modules['courses']?.update ?? false);
  final levels = [
    for (final grant in grants)
      _levelForGrant(grant, pack, sessionManaged: sessionManaged),
  ];

  var minRank = PermissionLevel.full.rank;
  for (final level in levels) {
    if (level.rank < minRank) minRank = level.rank;
  }
  var level = PermissionLevel.values[minRank];
  if (level == PermissionLevel.none && active.isNotEmpty) {
    level = PermissionLevel.read;
  }

  var partial = levels.any((item) => item == PermissionLevel.none);
  for (var i = 0; i < grants.length; i++) {
    if (!_matchesLevel(levels[i], grants[i], pack)) partial = true;
  }

  final scopes = [
    for (final grant in active)
      AccountScope(courseIds: grant.courseIds, teamIds: grant.teamIds),
  ];
  final firstScope = scopes.first;
  final scopeMixed = scopes.any((scope) => !scope.sameAs(firstScope));

  return PermissionPackSnapshot(
    level: level,
    partial: partial,
    scope: firstScope,
    scopeMixed: scopeMixed,
  );
}

/// Applies a pack level. Reads are always implied; attendance's write level
/// includes delete by product decision.
Map<String, AdminModuleGrant> applyPackLevel(
  Map<String, AdminModuleGrant> modules,
  PermissionPack pack,
  PermissionLevel level, {
  required AccountScope scope,
}) {
  final next = Map<String, AdminModuleGrant>.of(modules);

  if (level == PermissionLevel.none) {
    for (final module in pack.coreModules) {
      next.remove(module);
    }
  } else {
    for (final module in pack.coreModules) {
      next[module] = grantAtLevel(
        next[module] ?? AdminModuleGrant.none,
        level,
        scope,
        writeIncludesDelete: pack.writeIncludesDelete,
      );
    }
  }

  // The attendance full level is marked by courses.update. Set/clear it before
  // recomputing prerequisites so inference sees the intended level.
  if (pack.fullManagesSessions) {
    final courses = next['courses'] ?? AdminModuleGrant.none;
    if (level == PermissionLevel.full) {
      next['courses'] = courses.copyWith(
        view: true,
        update: true,
        courseIds: scope.courseIds,
        teamIds: scope.teamIds,
      );
    } else if (_isSessionManageOnly(courses)) {
      next['courses'] = courses.copyWith(update: false);
    }
  }

  return recomputePrerequisites(next, scope);
}

/// Advanced section: applies a level to one module and keeps prerequisites in
/// sync with the packs that are currently enabled.
Map<String, AdminModuleGrant> applyModuleLevel(
  Map<String, AdminModuleGrant> modules,
  String module,
  PermissionLevel level, {
  required AccountScope scope,
}) {
  final next = Map<String, AdminModuleGrant>.of(modules);
  if (level == PermissionLevel.none) {
    next.remove(module);
  } else {
    next[module] = grantAtLevel(
      next[module] ?? AdminModuleGrant.none,
      level,
      scope,
      writeIncludesDelete: module == 'attendance',
    );
  }

  // Keep the attendance pack's "full = adjust the session" marker consistent
  // even when the admin edits attendance from the advanced section.
  if (module == 'attendance') {
    final courses = next['courses'] ?? AdminModuleGrant.none;
    if (level == PermissionLevel.full) {
      next['courses'] = courses.copyWith(
        view: true,
        update: true,
        courseIds: scope.courseIds,
        teamIds: scope.teamIds,
      );
    } else if (_isSessionManageOnly(courses)) {
      next['courses'] = courses.copyWith(update: false);
    }
  }

  return recomputePrerequisites(next, scope);
}

/// Applies the global account scope to every active module.
Map<String, AdminModuleGrant> applyAccountScope(
  Map<String, AdminModuleGrant> modules,
  AccountScope scope,
) {
  return {
    for (final entry in modules.entries)
      entry.key: entry.value.hasAnyAction
          ? entry.value.copyWith(
              courseIds: scope.courseIds,
              teamIds: scope.teamIds,
            )
          : entry.value,
  };
}

/// Toggles a module's export flag. Export requires reading.
Map<String, AdminModuleGrant> toggleModuleExport(
  Map<String, AdminModuleGrant> modules,
  String module, {
  required bool enabled,
}) {
  final current = modules[module];
  if (current == null || !current.hasAnyAction) return modules;
  return {...modules, module: current.copyWith(view: true, export: enabled)};
}

/// Applies a custom scope to one module (advanced section).
Map<String, AdminModuleGrant> applyModuleScope(
  Map<String, AdminModuleGrant> modules,
  String module,
  AccountScope scope,
) {
  final current = modules[module];
  if (current == null) return modules;
  return {
    ...modules,
    module: current.copyWith(
      courseIds: scope.courseIds,
      teamIds: scope.teamIds,
    ),
  };
}

/// Ensures the "write without read" combinations can never be saved.
AdminModuleGrant normalizeGrant(AdminModuleGrant grant) {
  if (!grant.hasAnyAction) return AdminModuleGrant.none;
  return grant.copyWith(view: true);
}

/// A canonical grant for a level (used by both packs and advanced rows).
AdminModuleGrant grantAtLevel(
  AdminModuleGrant current,
  PermissionLevel level,
  AccountScope scope, {
  bool writeIncludesDelete = false,
}) {
  if (level == PermissionLevel.none) return AdminModuleGrant.none;
  final writing = level.includes(PermissionLevel.write);
  final full = level.includes(PermissionLevel.full);
  return AdminModuleGrant(
    view: true,
    create: writing,
    update: writing,
    delete: writeIncludesDelete ? writing : full,
    export: current.export,
    courseIds: scope.courseIds,
    teamIds: scope.teamIds,
  );
}

/// Reads one module's effective level for the advanced editor.
///
/// Attendance is special: a record-delete grant is the write level, while full
/// control additionally includes `courses.update` (session settings).
PermissionLevel levelForModule(
  String module,
  AdminModuleGrant grant, {
  bool sessionManaged = false,
}) {
  if (!grant.hasAnyAction) return PermissionLevel.none;
  if (module == 'attendance') {
    if (grant.view && grant.create && grant.update && grant.delete) {
      return sessionManaged ? PermissionLevel.full : PermissionLevel.write;
    }
  } else if (grant.view && grant.create && grant.update && grant.delete) {
    return PermissionLevel.full;
  }
  if (grant.view && grant.create && grant.update) {
    return PermissionLevel.write;
  }
  if (grant.view) return PermissionLevel.read;
  return PermissionLevel.read;
}

/// Adds read-only prerequisites based on the packs that are enabled, without
/// removing anything. Used when loading an existing account so the editor shows
/// a consistent, working pack state.
Map<String, AdminModuleGrant> ensurePrerequisites(
  Map<String, AdminModuleGrant> modules,
  AccountScope scope,
) {
  final next = Map<String, AdminModuleGrant>.of(modules);
  final enabled = [
    for (final pack in permissionPacks)
      if (packSnapshot(pack, next).enabled) pack,
  ];
  final needed = <String>{
    for (final pack in enabled) ...pack.prerequisiteModules,
  };
  final coreModules = <String>{for (final pack in enabled) ...pack.coreModules};
  final sessionManaged = enabled.any(
    (pack) =>
        pack.fullManagesSessions &&
        packSnapshot(pack, next).level == PermissionLevel.full,
  );

  for (final module in needed) {
    if (coreModules.contains(module)) continue;
    final current = next[module] ?? AdminModuleGrant.none;
    var grant = current.copyWith(
      view: true,
      courseIds: scope.courseIds,
      teamIds: scope.teamIds,
    );
    if (module == 'courses' && sessionManaged) {
      grant = grant.copyWith(update: true);
    }
    next[module] = grant;
  }

  return next;
}

/// Adds/removes read-only prerequisites based on the packs that are enabled.
///
/// Only auto-looking prerequisites are cleared (view-only, or courses view +
/// update); a module the admin configured further is left untouched.
Map<String, AdminModuleGrant> recomputePrerequisites(
  Map<String, AdminModuleGrant> modules,
  AccountScope scope,
) {
  final next = ensurePrerequisites(modules, scope);
  final enabled = [
    for (final pack in permissionPacks)
      if (packSnapshot(pack, next).enabled) pack,
  ];
  final needed = <String>{
    for (final pack in enabled) ...pack.prerequisiteModules,
  };
  final coreModules = <String>{for (final pack in enabled) ...pack.coreModules};

  final allPrerequisites = <String>{
    for (final pack in permissionPacks) ...pack.prerequisiteModules,
  };
  for (final module in allPrerequisites) {
    if (needed.contains(module) || coreModules.contains(module)) continue;
    final current = next[module];
    if (current == null || !current.hasAnyAction) continue;
    final viewOnly =
        current.view &&
        !current.create &&
        !current.update &&
        !current.delete &&
        !current.export;
    if (viewOnly) {
      next.remove(module);
    } else if (_isSessionManageOnly(current)) {
      next[module] = current.copyWith(update: false);
    }
  }

  return next;
}

/// Labels used by the pack cards to explain automatic prerequisites.
String permissionPrerequisiteLabel(
  String module, {
  bool sessionManage = false,
}) {
  return switch (module) {
    'courses' => sessionManage ? 'قراءة الجلسات وضبطها' : 'قراءة الجلسات',
    'teams' => 'قائمة المسمّعين',
    _ => '#$module',
  };
}

PermissionLevel _levelForGrant(
  AdminModuleGrant grant,
  PermissionPack pack, {
  required bool sessionManaged,
}) {
  if (!grant.hasAnyAction) return PermissionLevel.none;
  if (grant.view && grant.create && grant.update && grant.delete) {
    if (pack.writeIncludesDelete) {
      return pack.fullManagesSessions && sessionManaged
          ? PermissionLevel.full
          : PermissionLevel.write;
    }
    return PermissionLevel.full;
  }
  if (grant.view && grant.create && grant.update) {
    return PermissionLevel.write;
  }
  if (grant.view) return PermissionLevel.read;
  return PermissionLevel.read;
}

bool _matchesLevel(
  PermissionLevel level,
  AdminModuleGrant grant,
  PermissionPack pack,
) {
  return switch (level) {
    PermissionLevel.none => !grant.hasAnyAction,
    PermissionLevel.read =>
      grant.view && !grant.create && !grant.update && !grant.delete,
    PermissionLevel.write =>
      grant.view &&
          grant.create &&
          grant.update &&
          (pack.writeIncludesDelete ? grant.delete : !grant.delete),
    PermissionLevel.full =>
      grant.view && grant.create && grant.update && grant.delete,
  };
}

bool _isSessionManageOnly(AdminModuleGrant grant) =>
    grant.view &&
    grant.update &&
    !grant.create &&
    !grant.delete &&
    !grant.export;

bool _sameInts(List<int> a, List<int> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
