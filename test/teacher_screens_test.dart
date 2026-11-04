import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:raqim/core/theme/app_theme.dart';
import 'package:raqim/features/admin/data/admin_local_repository.dart';
import 'package:raqim/features/admin/domain/admin_models.dart';
import 'package:raqim/features/admin/presentation/admin_shell.dart';
import 'package:raqim/features/student/data/local/demo_seed.dart';
import 'package:raqim/features/student/data/local/student_database.dart';
import 'package:raqim/features/teacher/domain/teacher_models.dart';
import 'package:raqim/features/teacher/presentation/screens/teacher_students_screen.dart';
import 'package:raqim/features/teacher/presentation/screens/teacher_today_screen.dart';
import 'package:raqim/features/teacher/presentation/teacher_shell.dart';

class _Repos {
  _Repos(this.admin);
  final AdminLocalRepository admin;
}

Future<_Repos> _repos() async {
  final db = StudentDatabase.forTesting(NativeDatabase.memory());
  await seedDemoDataIfNeeded(db);
  return _Repos(AdminLocalRepository(db));
}

Widget _wrap(_Repos repos, Widget child) {
  return AdminRepositoryScope(
    repository: repos.admin,
    child: MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('Teacher shell shows the 3 flat tabs', (tester) async {
    final repos = await _repos();
    await tester.pumpWidget(
      _wrap(repos, const TeacherShell(child: TeacherTodayScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('اليوم'), findsWidgets);
    expect(find.text('طلابي'), findsWidgets);
    expect(find.text('حسابي'), findsWidgets);
  });

  testWidgets('Teacher today starts with course/session selection', (
    tester,
  ) async {
    final repos = await _repos();
    await tester.pumpWidget(_wrap(repos, const TeacherTodayScreen()));
    await tester.pumpAndSettle();

    expect(find.text('ابدأ باختيار الدورة والجلسة'), findsOneWidget);
    expect(find.text('اختر الدورة والجلسة'), findsWidgets);
  });

  testWidgets('Teacher students screen renders search + roster', (
    tester,
  ) async {
    final repos = await _repos();
    await tester.pumpWidget(_wrap(repos, const TeacherStudentsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('ابحث بالاسم أو المعرّف أو الباركود'), findsOneWidget);
    expect(find.text('لا حلقات مرتبطة بك'), findsNothing);
  });

  test('TeacherRosterEntry unions team-type switches', () {
    final entry = TeacherRosterEntry(
      student: const AdminStudentRow(
        id: 1,
        name: 'أحمد',
        teamNames: 'حلقة القرآن',
      ),
      teams: const [
        AdminTeamRow(
          id: 10,
          name: 'حلقة القرآن',
          typeName: 'القرآن الكريم',
          teacherName: 'أ. محمود',
          studentsCount: 1,
          typePermissions: TeamTypePermissions(
            quranTasmi: true,
            attendance: true,
            points: true,
          ),
        ),
        AdminTeamRow(
          id: 11,
          name: 'حلقة العلوم',
          typeName: 'العلوم الشرعية',
          teacherName: 'أ. محمود',
          studentsCount: 1,
          typePermissions: TeamTypePermissions(matn: true, attendance: true),
        ),
      ],
    );

    expect(entry.quranTasmiAllowed, isTrue);
    expect(entry.matnAllowed, isTrue);
    expect(entry.pointsAllowed, isTrue);
    expect(entry.attendanceAllowed, isTrue);
    expect(entry.recordKinds, contains(TeacherRecordKind.quranTasmi));
    expect(entry.recordKinds, contains(TeacherRecordKind.matn));
    expect(entry.recordKinds, contains(TeacherRecordKind.points));
    expect(entry.recordKinds, isNot(contains(TeacherRecordKind.attendance)));
  });
}
