import 'package:flutter_test/flutter_test.dart';

import 'package:raqim/features/admin/domain/admin_models.dart';
import 'package:raqim/features/admin/domain/permission_packs.dart';

AdminModuleGrant _grant({
  bool view = false,
  bool create = false,
  bool update = false,
  bool delete = false,
  bool export = false,
  List<int> courseIds = const [],
  List<int> teamIds = const [],
}) {
  return AdminModuleGrant(
    view: view,
    create: create,
    update: update,
    delete: delete,
    export: export,
    courseIds: courseIds,
    teamIds: teamIds,
  );
}

PermissionPack _pack(String id) => permissionPackById(id)!;

void main() {
  group('three-level grant expansion', () {
    test('read implies view only', () {
      final grant = grantAtLevel(
        AdminModuleGrant.none,
        PermissionLevel.read,
        AccountScope.all,
      );
      expect(grant.view, isTrue);
      expect(grant.create, isFalse);
      expect(grant.update, isFalse);
      expect(grant.delete, isFalse);
    });

    test('write implies read and edit, but not delete', () {
      final grant = grantAtLevel(
        AdminModuleGrant.none,
        PermissionLevel.write,
        AccountScope.all,
      );
      expect(grant.view, isTrue);
      expect(grant.create, isTrue);
      expect(grant.update, isTrue);
      expect(grant.delete, isFalse);
    });

    test('full implies delete', () {
      final grant = grantAtLevel(
        AdminModuleGrant.none,
        PermissionLevel.full,
        AccountScope.all,
      );
      expect(grant.delete, isTrue);
    });

    test('attendance write includes delete by product decision', () {
      final grant = grantAtLevel(
        AdminModuleGrant.none,
        PermissionLevel.write,
        AccountScope.all,
        writeIncludesDelete: true,
      );
      expect(grant.delete, isTrue);
    });

    test('export is preserved when a level is applied', () {
      final grant = grantAtLevel(
        _grant(view: true, export: true),
        PermissionLevel.write,
        AccountScope.all,
      );
      expect(grant.export, isTrue);
    });

    test('attendance full is detected through courses.update', () {
      final modules = applyPackLevel(
        const {},
        _pack('attendance'),
        PermissionLevel.full,
        scope: AccountScope.all,
      );
      expect(modules['courses']!.update, isTrue);
      expect(
        packSnapshot(_pack('attendance'), modules).level,
        PermissionLevel.full,
      );
    });
  });

  group('pack expansion', () {
    test('attendance write grants attendance + courses read only', () {
      final modules = applyPackLevel(
        const {},
        _pack('attendance'),
        PermissionLevel.write,
        scope: AccountScope.all,
      );
      final attendance = modules['attendance']!;
      expect(attendance.view, isTrue);
      expect(attendance.create, isTrue);
      expect(attendance.update, isTrue);
      expect(attendance.delete, isTrue);
      expect(modules['courses']!.view, isTrue);
      expect(modules['courses']!.update, isFalse);
      expect(modules.containsKey('students'), isFalse);
      expect(modules.containsKey('points'), isFalse);
    });

    test('attendance full adds session management', () {
      final modules = applyPackLevel(
        const {},
        _pack('attendance'),
        PermissionLevel.full,
        scope: AccountScope.all,
      );
      expect(modules['courses']!.update, isTrue);
      expect(modules['attendance']!.delete, isTrue);
    });

    test('points does not leak into attendance or students', () {
      final modules = applyPackLevel(
        const {},
        _pack('points'),
        PermissionLevel.write,
        scope: AccountScope.all,
      );
      expect(modules['points']!.view, isTrue);
      expect(modules['points']!.create, isTrue);
      expect(modules['points']!.update, isTrue);
      expect(modules['points']!.delete, isFalse);
      expect(modules['courses']!.view, isTrue);
      expect(modules.containsKey('attendance'), isFalse);
      expect(modules.containsKey('students'), isFalse);
    });

    test('quran pack is memorization + recitation only', () {
      final modules = applyPackLevel(
        const {},
        _pack('quran'),
        PermissionLevel.write,
        scope: AccountScope.all,
      );
      expect(modules['memorization']!.create, isTrue);
      expect(modules['recitation']!.create, isTrue);
      expect(modules.containsKey('matn'), isFalse);
      expect(modules.containsKey('students'), isFalse);
      expect(modules['courses']!.view, isTrue);
      expect(modules['teams']!.view, isTrue);
    });

    test('matn pack is separate from quran', () {
      final modules = applyPackLevel(
        const {},
        _pack('matn'),
        PermissionLevel.write,
        scope: AccountScope.all,
      );
      expect(modules['matn']!.create, isTrue);
      expect(modules.containsKey('memorization'), isFalse);
      expect(modules.containsKey('recitation'), isFalse);
      expect(modules['teams']!.view, isTrue);
    });

    test('students pack does not add operational prerequisites', () {
      final modules = applyPackLevel(
        const {},
        _pack('students'),
        PermissionLevel.read,
        scope: AccountScope.all,
      );
      expect(modules['students']!.view, isTrue);
      expect(modules.containsKey('courses'), isFalse);
      expect(modules.containsKey('teams'), isFalse);
    });

    test('exams pack includes courses read only', () {
      final modules = applyPackLevel(
        const {},
        _pack('exams'),
        PermissionLevel.write,
        scope: AccountScope.all,
      );
      expect(modules['exams']!.create, isTrue);
      expect(modules['courses']!.view, isTrue);
      expect(modules.containsKey('students'), isFalse);
    });

    test('disabling a pack removes auto prerequisites', () {
      var modules = applyPackLevel(
        const {},
        _pack('attendance'),
        PermissionLevel.write,
        scope: AccountScope.all,
      );
      expect(modules.containsKey('courses'), isTrue);
      modules = applyPackLevel(
        modules,
        _pack('attendance'),
        PermissionLevel.none,
        scope: AccountScope.all,
      );
      expect(modules.containsKey('attendance'), isFalse);
      expect(modules.containsKey('courses'), isFalse);
    });

    test('disabling one pack keeps prerequisites needed by another', () {
      var modules = applyPackLevel(
        const {},
        _pack('quran'),
        PermissionLevel.write,
        scope: AccountScope.all,
      );
      modules = applyPackLevel(
        modules,
        _pack('matn'),
        PermissionLevel.write,
        scope: AccountScope.all,
      );
      modules = applyPackLevel(
        modules,
        _pack('quran'),
        PermissionLevel.none,
        scope: AccountScope.all,
      );
      expect(modules.containsKey('memorization'), isFalse);
      expect(modules['matn']!.view, isTrue);
      expect(modules['courses']!.view, isTrue);
      expect(modules['teams']!.view, isTrue);
    });
  });

  group('inference', () {
    test('attendance view-only is the read level', () {
      final modules = {'attendance': _grant(view: true)};
      final snapshot = packSnapshot(_pack('attendance'), modules);
      expect(snapshot.enabled, isTrue);
      expect(snapshot.level, PermissionLevel.read);
      expect(snapshot.partial, isFalse);
    });

    test('attendance write with delete is the write level', () {
      final modules = {
        'attendance': _grant(
          view: true,
          create: true,
          update: true,
          delete: true,
        ),
      };
      final snapshot = packSnapshot(_pack('attendance'), modules);
      expect(snapshot.level, PermissionLevel.write);
    });

    test('a partial grant is flagged without being overstated', () {
      final modules = {'attendance': _grant(view: true, create: true)};
      final snapshot = packSnapshot(_pack('attendance'), modules);
      expect(snapshot.level, PermissionLevel.read);
      expect(snapshot.partial, isTrue);
    });

    test('multi-module pack is partial when one module is missing', () {
      final modules = {
        'memorization': _grant(view: true, create: true, update: true),
        'courses': _grant(view: true),
        'teams': _grant(view: true),
      };
      final snapshot = packSnapshot(_pack('quran'), modules);
      expect(snapshot.enabled, isTrue);
      expect(snapshot.level, PermissionLevel.read);
      expect(snapshot.partial, isTrue);
    });
  });

  group('account scope', () {
    test('infers a single team scope', () {
      final modules = {
        'attendance': _grant(view: true, teamIds: [7]),
        'courses': _grant(view: true, teamIds: [7]),
      };
      final inferred = inferAccountScope(modules);
      expect(inferred.mixed, isFalse);
      expect(inferred.scope.teamIds, [7]);
    });

    test('flags mixed scopes', () {
      final modules = {
        'attendance': _grant(view: true, teamIds: [7]),
        'courses': _grant(view: true),
      };
      final inferred = inferAccountScope(modules);
      expect(inferred.mixed, isTrue);
    });

    test('applies the scope to every active module', () {
      final modules = {
        'attendance': _grant(view: true),
        'students': _grant(view: true, teamIds: [3]),
        'points': _grant(),
      };
      final scoped = applyAccountScope(
        modules,
        const AccountScope(courseIds: [3], teamIds: [7]),
      );
      expect(scoped['attendance']!.courseIds, [3]);
      expect(scoped['attendance']!.teamIds, [7]);
      expect(scoped['students']!.teamIds, [7]);
      expect(scoped['points']!.hasAnyAction, isFalse);
    });
  });

  group('advanced helpers', () {
    test('normalizeGrant enforces read with every action', () {
      final grant = normalizeGrant(_grant(create: true, update: true));
      expect(grant.view, isTrue);
      expect(grant.create, isTrue);
      expect(grant.update, isTrue);
    });

    test('toggle export requires an active module', () {
      final modules = {'points': _grant(view: true)};
      final enabled = toggleModuleExport(modules, 'points', enabled: true);
      expect(enabled['points']!.export, isTrue);
      expect(enabled['points']!.view, isTrue);
    });

    test('levelForModule reads attendance full via session management', () {
      final grant = _grant(
        view: true,
        create: true,
        update: true,
        delete: true,
      );
      expect(levelForModule('attendance', grant), PermissionLevel.write);
      expect(
        levelForModule('attendance', grant, sessionManaged: true),
        PermissionLevel.full,
      );
      expect(levelForModule('points', grant), PermissionLevel.full);
    });

    test('module scope is applied without changing actions', () {
      final modules = {'matn': _grant(view: true, create: true)};
      final scoped = applyModuleScope(
        modules,
        'matn',
        const AccountScope(teamIds: [9]),
      );
      expect(scoped['matn']!.teamIds, [9]);
      expect(scoped['matn']!.create, isTrue);
    });
  });
}
