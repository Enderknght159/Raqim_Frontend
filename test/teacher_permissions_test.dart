import 'package:flutter_test/flutter_test.dart';

import 'package:raqim/features/admin/domain/admin_models.dart';
import 'package:raqim/features/auth/domain/models/app_role.dart';
import 'package:raqim/features/auth/domain/models/user_profile.dart';

void main() {
  group('TeamTypePermissions', () {
    test('parses the four switches and defaults to none', () {
      final permissions = TeamTypePermissions.fromJson({
        'quranTasmi': true,
        'matn': false,
        'attendance': true,
        'points': true,
      });

      expect(permissions.quranTasmi, isTrue);
      expect(permissions.matn, isFalse);
      expect(permissions.attendance, isTrue);
      expect(permissions.points, isTrue);
      expect(permissions.any, isTrue);

      const none = TeamTypePermissions.none();
      expect(none.any, isFalse);
    });

    test('serializes back to the API shape', () {
      const permissions = TeamTypePermissions(quranTasmi: true, points: true);
      expect(permissions.toJson(), {
        'quranTasmi': true,
        'matn': false,
        'attendance': false,
        'points': true,
      });
    });
  });

  group('AdminTeamRow type metadata', () {
    test('carries the mandatory type identity and switches', () {
      const row = AdminTeamRow(
        id: 3,
        name: 'حلقة القرآن',
        typeId: 1,
        typeName: 'القرآن الكريم',
        typeKind: 'quran',
        typeIsSystem: true,
        typePermissions: TeamTypePermissions(
          quranTasmi: true,
          attendance: true,
          points: true,
        ),
        teacherName: 'أ. محمود',
        studentsCount: 12,
      );

      expect(row.typeId, 1);
      expect(row.typeKind, 'quran');
      expect(row.typeIsSystem, isTrue);
      expect(row.typePermissions.quranTasmi, isTrue);
      expect(row.typePermissions.matn, isFalse);
    });
  });

  group('UserProfile modes', () {
    final json = <String, dynamic>{
      'id': 10,
      'name': 'معلم',
      'role': 'teacher',
      'sections': ['teacher'],
      'teacher': {'id': 7},
      'capabilities': {
        'attendance': {
          'view': true,
          'create': true,
          'update': true,
          'delete': true,
          'export': false,
          'scope': {
            'courseIds': <int>[],
            'teamIds': [5],
          },
        },
      },
      'teacherCapabilities': {
        'attendance': {
          'view': true,
          'create': true,
          'update': true,
          'delete': true,
          'export': false,
          'scope': {
            'courseIds': <int>[],
            'teamIds': [5],
          },
        },
      },
      'supervisorCapabilities': {
        'students': {
          'view': true,
          'create': false,
          'update': false,
          'delete': false,
          'export': false,
          'scope': {'courseIds': <int>[], 'teamIds': <int>[]},
        },
      },
    };

    test('keeps teacher and supervisor surfaces separate', () {
      final profile = UserProfile.fromJson(json);

      expect(profile.role, AppRole.teacher);
      expect(profile.teacherId, 7);
      expect(profile.teacherCanEdit('attendance'), isTrue);
      expect(profile.teacherCapabilities['attendance']!.scopeTeamIds, [5]);
      expect(profile.supervisorCapabilities.containsKey('students'), isTrue);

      final teacherMode = profile.capabilitiesForMode(teacher: true);
      expect(teacherMode.containsKey('attendance'), isTrue);
      expect(teacherMode.containsKey('students'), isFalse);

      final supervisorMode = profile.capabilitiesForMode(teacher: false);
      expect(supervisorMode.containsKey('students'), isTrue);
      expect(supervisorMode.containsKey('attendance'), isFalse);
    });

    test('falls back to the effective map for a teacher-only account', () {
      final legacy = Map<String, dynamic>.from(json)
        ..remove('teacherCapabilities')
        ..remove('supervisorCapabilities');

      final profile = UserProfile.fromJson(legacy);
      expect(profile.teacherCapabilities, isEmpty);
      expect(
        profile.capabilitiesForMode(teacher: true).containsKey('attendance'),
        isTrue,
      );
    });

    test(
      'never leaks supervisor grants into teacher mode on a dual account',
      () {
        final dual = Map<String, dynamic>.from(json)
          ..['role'] = 'supervisor'
          ..['sections'] = ['teacher', 'supervisor']
          ..remove('teacherCapabilities');

        final profile = UserProfile.fromJson(dual);
        expect(profile.capabilitiesForMode(teacher: true), isEmpty);
        expect(profile.teacherCanEdit('attendance'), isFalse);
      },
    );
  });
}
