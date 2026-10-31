import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:raqim/core/theme/app_theme.dart';
import 'package:raqim/features/admin/data/admin_local_repository.dart';
import 'package:raqim/features/admin/domain/admin_models.dart';
import 'package:raqim/features/admin/presentation/admin_shell.dart';
import 'package:raqim/features/admin/presentation/screens/admin_user_detail_screen.dart';
import 'package:raqim/features/admin/presentation/screens/admin_user_teaching_screen.dart';
import 'package:raqim/features/student/data/local/demo_seed.dart';
import 'package:raqim/features/student/data/local/student_database.dart';

class _TeachingRepo extends AdminLocalRepository {
  // ignore: use_super_parameters
  _TeachingRepo(StudentDatabase db) : super(db);

  AdminUserRow? row;
  AdminTeacherDetail? detail;
  final createdNames = <String>[];
  final links = <(int, int)>[];
  final deletedTeachers = <int>[];
  final removedTeams = <int>[];

  @override
  Future<AdminUserRow?> user(int userId) async => row;

  @override
  Future<AdminUserPermissions> userPermissions(int userId) async =>
      const AdminUserPermissions(isAdmin: false);

  @override
  Future<AdminTeacherDetail?> teacherDetail(int teacherId) async => detail;

  @override
  Future<int> createTeacher(String name) async {
    createdNames.add(name);
    return 77;
  }

  @override
  Future<void> linkTeacherToUser(int userId, int teacherId) async {
    links.add((userId, teacherId));
    final current = row;
    if (current != null) {
      row = AdminUserRow(
        id: current.id,
        name: current.name,
        username: current.username,
        active: current.active,
        isAdmin: current.isAdmin,
        isSupervisor: current.isSupervisor,
        isTeacher: true,
        isStudent: current.isStudent,
        studentId: current.studentId,
        teacherId: teacherId,
        teamNames: current.teamNames,
      );
    }
    detail = AdminTeacherDetail(
      id: teacherId,
      name: createdNames.isEmpty ? 'معلم' : createdNames.last,
      userId: userId,
    );
  }

  @override
  Future<void> deleteTeacher(int teacherId) async {
    deletedTeachers.add(teacherId);
    detail = null;
    final current = row;
    if (current != null) {
      row = AdminUserRow(
        id: current.id,
        name: current.name,
        username: current.username,
        active: current.active,
        isAdmin: current.isAdmin,
        isSupervisor: current.isSupervisor,
        isTeacher: false,
        isStudent: current.isStudent,
        studentId: current.studentId,
        teacherId: null,
        teamNames: const [],
      );
    }
  }

  @override
  Future<void> removeTeamTeacher(int teamId) async {
    removedTeams.add(teamId);
    final current = detail;
    if (current == null) return;
    detail = AdminTeacherDetail(
      id: current.id,
      name: current.name,
      userId: current.userId,
      teams: current.teams.where((team) => team.id != teamId).toList(),
    );
  }
}

const _studentRow = AdminUserRow(
  id: 5,
  name: 'أ. أحمد',
  username: 'ahmad',
  active: true,
  isAdmin: false,
  isSupervisor: false,
  isTeacher: false,
  isStudent: true,
);

Future<_TeachingRepo> _repo() async {
  final db = StudentDatabase.forTesting(NativeDatabase.memory());
  await seedDemoDataIfNeeded(db);
  return _TeachingRepo(db);
}

Widget _wrap(_TeachingRepo repo, Widget child) {
  return AdminRepositoryScope(
    repository: repo,
    child: MaterialApp(theme: AppTheme.light(), home: child),
  );
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('detail screen separates supervision from teaching', (
    tester,
  ) async {
    final repo = await _repo();
    repo.row = _studentRow;

    await tester.pumpWidget(
      _wrap(
        repo,
        const AdminUserDetailScreen(
          userId: 5,
          name: 'أ. أحمد',
          kind: AdminUserKind.student,
          username: 'ahmad',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('صلاحيات الإشراف'), findsOneWidget);
    expect(find.text('صلاحيات التدريس'), findsOneWidget);
    expect(find.text('تعديل الصلاحيات'), findsNothing);
  });

  testWidgets('teaching screen offers first-time assignment', (tester) async {
    final repo = await _repo();
    repo.row = _studentRow;

    await tester.pumpWidget(
      _wrap(
        repo,
        const AdminUserTeachingScreen(
          userId: 5,
          initialName: 'أ. أحمد',
          initialUsername: 'ahmad',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('هذا الحساب ليس مدرّسًا بعد'), findsOneWidget);
    expect(find.text('تعيين كمدرس'), findsOneWidget);
  });

  testWidgets('teaching screen shows the linked teacher teams', (tester) async {
    final repo = await _repo();
    repo.detail = const AdminTeacherDetail(
      id: 9,
      name: 'أ. أحمد',
      teams: [AdminTeamRef(id: 1, name: 'حلقة النور')],
    );

    await tester.pumpWidget(
      _wrap(
        repo,
        const AdminUserTeachingScreen(
          userId: 5,
          initialName: 'أ. أحمد',
          initialUsername: 'ahmad',
          initialTeacherId: 9,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('حلقة النور'), findsOneWidget);
    expect(find.text('إسناد لحلقة'), findsOneWidget);
  });

  testWidgets('first-time assignment creates then links a teacher', (
    tester,
  ) async {
    final repo = await _repo();
    repo.row = _studentRow;

    await tester.pumpWidget(
      _wrap(
        repo,
        const AdminUserTeachingScreen(
          userId: 5,
          initialName: 'أ. أحمد',
          initialUsername: 'ahmad',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('تعيين كمدرس'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'أ. أحمد');
    await tester.tap(find.widgetWithText(FilledButton, 'تعيين'));
    await tester.pumpAndSettle();

    expect(repo.createdNames, ['أ. أحمد']);
    expect(repo.links, [(5, 77)]);
    expect(find.text('مدرّس'), findsOneWidget);
  });

  testWidgets('teaching page removes a team assignment (unlink only)', (
    tester,
  ) async {
    final repo = await _repo();
    repo.row = _studentRow;
    repo.detail = const AdminTeacherDetail(
      id: 9,
      name: 'أ. أحمد',
      userId: 5,
      teams: [AdminTeamRef(id: 1, name: 'حلقة النور')],
    );

    await tester.pumpWidget(
      _wrap(
        repo,
        const AdminUserTeachingScreen(
          userId: 5,
          initialName: 'أ. أحمد',
          initialUsername: 'ahmad',
          initialTeacherId: 9,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'إزالة'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('إزالة'),
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.removedTeams, [1]);
    expect(repo.deletedTeachers, isEmpty);
  });

  testWidgets('teaching page soft-deletes the teacher record', (tester) async {
    final repo = await _repo();
    repo.row = _studentRow;
    repo.detail = const AdminTeacherDetail(
      id: 9,
      name: 'أ. أحمد',
      userId: 5,
      teams: [AdminTeamRef(id: 1, name: 'حلقة النور')],
    );

    await tester.pumpWidget(
      _wrap(
        repo,
        const AdminUserTeachingScreen(
          userId: 5,
          initialName: 'أ. أحمد',
          initialUsername: 'ahmad',
          initialTeacherId: 9,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('إزالة حساب المدرس'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('إزالة'),
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.deletedTeachers, [9]);
    expect(find.text('غير مدرّس'), findsOneWidget);
  });
}
