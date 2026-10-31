import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:raqim/features/admin/data/admin_local_repository.dart';
import 'package:raqim/features/admin/domain/admin_models.dart';
import 'package:raqim/features/student/data/local/demo_seed.dart';
import 'package:raqim/features/student/data/local/student_database.dart';

const _fullPayload = <String, dynamic>{
  'isAdmin': false,
  'modules': {
    'attendance': {
      'view': true,
      'create': false,
      'update': false,
      'delete': false,
      'export': false,
      'scope': {
        'courseIds': <int>[],
        'teamIds': [7],
      },
    },
    'students': {
      'view': true,
      'create': false,
      'update': false,
      'delete': false,
      'export': false,
      'scope': {
        'courseIds': [3],
        'teamIds': <int>[],
      },
    },
    'quranCertificates': {
      'view': false,
      'create': false,
      'update': false,
      'delete': false,
      'export': true,
      'scope': {'courseIds': <int>[], 'teamIds': <int>[]},
    },
  },
  'specialAbilities': ['auditView', 'phoneSearch'],
};

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('AdminUserPermissions contract', () {
    test('parses the full module × action × scope payload', () {
      final permissions = AdminUserPermissions.fromJson(_fullPayload);

      expect(permissions.isAdmin, isFalse);
      expect(permissions.modules.keys, containsAll(['attendance', 'students']));
      expect(permissions.abilities, {'auditView', 'phoneSearch'});
      expect(permissions.isSupervisor, isTrue);

      final attendance = permissions.actionsFor('attendance');
      expect(attendance.view, isTrue);
      expect(attendance.create, isFalse);
      expect(attendance.teamIds, [7]);
      expect(attendance.courseIds, isEmpty);
      expect(attendance.hasAnyAction, isTrue);

      expect(permissions.viewEnabled('attendance'), isTrue);
      expect(permissions.viewEnabled('points'), isFalse);
      expect(permissions.actionsFor('points').hasAnyAction, isFalse);

      final certificates = permissions.actionsFor('quranCertificates');
      expect(certificates.export, isTrue);
      expect(certificates.view, isFalse);
    });

    test('round-trips actions and scopes without loss', () {
      final permissions = AdminUserPermissions.fromJson(_fullPayload);
      final rebuilt = AdminUserPermissions.fromJson({
        'isAdmin': permissions.isAdmin,
        'modules': {
          for (final entry in permissions.modules.entries)
            entry.key: entry.value.toJson(),
        },
        'specialAbilities': permissions.abilities.toList(),
      });

      expect(rebuilt.modules.length, permissions.modules.length);
      expect(
        rebuilt.actionsFor('attendance').toJson(),
        permissions.actionsFor('attendance').toJson(),
      );
      expect(rebuilt.actionsFor('students').courseIds, [3]);
      expect(rebuilt.actionsFor('quranCertificates').export, isTrue);
      expect(rebuilt.actionsFor('quranCertificates').view, isFalse);
      expect(rebuilt.abilities, permissions.abilities);
    });

    test('copyWith keeps untouched actions and scope', () {
      const grant = AdminModuleGrant(
        view: true,
        export: true,
        courseIds: [1, 2],
        teamIds: [9],
      );
      final updated = grant.copyWith(create: true, teamIds: const [9, 10]);

      expect(updated.view, isTrue);
      expect(updated.export, isTrue);
      expect(updated.create, isTrue);
      expect(updated.courseIds, [1, 2]);
      expect(updated.teamIds, [9, 10]);
    });

    test('empty grants are not supervisors', () {
      const permissions = AdminUserPermissions(isAdmin: false);
      expect(permissions.isSupervisor, isFalse);
      expect(permissions.viewEnabled('students'), isFalse);
    });
  });

  group('usersPage contract', () {
    test('keeps local pagination + search behavior', () async {
      final db = StudentDatabase.forTesting(NativeDatabase.memory());
      await seedDemoDataIfNeeded(db);
      final repo = AdminLocalRepository(db);

      final all = await repo.usersPage(pageSize: 5);
      expect(all.items, hasLength(5));
      expect(all.total, greaterThan(5));
      expect(all.hasMore, isTrue);

      final search = await repo.usersPage(query: 'admin', pageSize: 30);
      expect(search.items, isNotEmpty);
      expect(
        search.items.any((row) => row.username.toLowerCase().contains('admin')),
        isTrue,
      );
    });
  });
}
