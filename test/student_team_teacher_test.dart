import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:raqim/core/network/api_mappers.dart';
import 'package:raqim/core/theme/app_theme.dart';
import 'package:raqim/features/student/data/local/demo_seed.dart';
import 'package:raqim/features/student/data/local/student_database.dart' as db;
import 'package:raqim/features/student/data/student_local_repository.dart';
import 'package:raqim/features/student/domain/models/student_models.dart';
import 'package:raqim/features/student/presentation/screens/my_teams_screen.dart';
import 'package:raqim/features/student/presentation/student_shell.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('mapTeam resolves the teacher name', () {
    test('reads name from a teacher object', () {
      final team = mapTeam({
        'id': 8,
        'name': 'حلقة',
        'type': null,
        'teacher': {'id': 8, 'name': 'أ. محمود'},
      });

      expect(team.teacherName, 'أ. محمود');
      expect(team.teacherId, 8);
      expect(team.teacherDisplayName, 'أ. محمود');
    });

    test('accepts a plain teacherName string', () {
      final team = mapTeam({'id': 9, 'name': 'حلقة', 'teacherName': 'أ. سامي'});

      expect(team.teacherName, 'أ. سامي');
      expect(team.teacherDisplayName, 'أ. سامي');
    });

    test('never uses a numeric teacher id as a name', () {
      final team = mapTeam({'id': 10, 'name': 'حلقة', 'teacher': 42});

      expect(team.teacherName, isEmpty);
      expect(team.teacherId, 42);
      expect(team.teacherDisplayName, Team.fallbackTeacherName);
      expect(team.teacherDisplayName, isNot('42'));
    });

    test('never uses a numeric string as a name', () {
      final team = mapTeam({'id': 11, 'name': 'حلقة', 'teacher': '42'});

      expect(team.teacherName, isEmpty);
      expect(team.teacherId, 42);
      expect(team.teacherDisplayName, Team.fallbackTeacherName);
    });

    test('missing teacher yields no teacher name', () {
      final team = mapTeam({'id': 12, 'name': 'حلقة', 'teacher': null});

      expect(team.teacherName, isEmpty);
      expect(team.teacherId, isNull);
      expect(team.teacherDisplayName, isEmpty);
    });
  });

  testWidgets('team card shows a fallback label instead of a raw id', (
    tester,
  ) async {
    final database = db.StudentDatabase.forTesting(NativeDatabase.memory());
    await seedDemoDataIfNeeded(database);
    await database
        .into(database.teams)
        .insert(
          db.TeamsCompanion.insert(
            id: const Value(900),
            name: 'حلقة مجهولة المعلم',
            typeName: 'عام',
            teacherName: const Value('8'),
          ),
        );
    await database
        .into(database.studentTeams)
        .insert(
          db.StudentTeamsCompanion.insert(
            id: const Value(9001),
            studentId: 1,
            teamId: 900,
          ),
        );

    final repo = StudentLocalRepository(database);
    await tester.pumpWidget(
      StudentRepositoryScope(
        repository: repo,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const MyTeamsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('حلقة مجهولة المعلم'), findsOneWidget);
    expect(find.text(Team.fallbackTeacherName), findsOneWidget);
    expect(find.text('8'), findsNothing);
  });
}
