import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:raqim/core/theme/app_theme.dart';
import 'package:raqim/features/admin/data/admin_local_repository.dart';
import 'package:raqim/features/admin/domain/admin_models.dart';
import 'package:raqim/features/admin/presentation/admin_shell.dart';
import 'package:raqim/features/admin/presentation/widgets/permission_editor.dart';
import 'package:raqim/features/student/data/local/demo_seed.dart';
import 'package:raqim/features/student/data/local/student_database.dart';

class _ScopeRepo extends AdminLocalRepository {
  // ignore: use_super_parameters
  _ScopeRepo(StudentDatabase db) : super(db);

  @override
  Future<List<AdminCourseSummary>> courses() async => [
    AdminCourseSummary(
      id: 3,
      name: 'دورة النور',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 12, 31),
      isActive: true,
      sessionsCount: 0,
      studentsCount: 0,
      lastSessionPresent: 0,
      lastSessionTotal: 0,
      attendancePercent: 0,
      series: const [],
    ),
  ];

  @override
  Future<List<AdminTeamRow>> teams() async => const [
    AdminTeamRow(
      id: 7,
      name: 'حلقة النور',
      typeName: 'قرآن',
      teacherName: '',
      studentsCount: 0,
    ),
  ];
}

Future<_ScopeRepo> _repo() async {
  final db = StudentDatabase.forTesting(NativeDatabase.memory());
  await seedDemoDataIfNeeded(db);
  return _ScopeRepo(db);
}

Widget _editor(
  _ScopeRepo repo,
  AdminUserPermissions initial,
  ValueChanged<AdminUserPermissions> onSave,
) {
  return AdminRepositoryScope(
    repository: repo,
    child: MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: AdminPermissionEditor(initial: initial, onSave: onSave),
      ),
    ),
  );
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('attendance.view only does not grant other actions', (
    tester,
  ) async {
    final repo = await _repo();
    AdminUserPermissions? saved;
    await tester.pumpWidget(
      _editor(
        repo,
        const AdminUserPermissions(isAdmin: false),
        (permissions) => saved = permissions,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('module-switch-attendance')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    final attendance = saved!.actionsFor('attendance');
    expect(attendance.view, isTrue);
    expect(attendance.create, isFalse);
    expect(attendance.update, isFalse);
    expect(attendance.delete, isFalse);
    expect(attendance.export, isFalse);
    expect(saved!.actionsFor('students').hasAnyAction, isFalse);
    expect(saved!.actionsFor('points').hasAnyAction, isFalse);
    expect(saved!.isSupervisor, isTrue);
  });

  testWidgets('attendance automatically keeps courses.view (navigation)', (
    tester,
  ) async {
    final repo = await _repo();
    AdminUserPermissions? saved;
    await tester.pumpWidget(
      _editor(
        repo,
        const AdminUserPermissions(isAdmin: false),
        (permissions) => saved = permissions,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('module-switch-attendance')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(saved!.actionsFor('attendance').view, isTrue);
    expect(saved!.actionsFor('courses').view, isTrue);
  });

  testWidgets('demoting an admin clears the computed module grants', (
    tester,
  ) async {
    final repo = await _repo();
    AdminUserPermissions? saved;
    await tester.pumpWidget(
      _editor(
        repo,
        const AdminUserPermissions(isAdmin: true),
        (permissions) => saved = permissions,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('admin-switch')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(saved!.isAdmin, isFalse);
    expect(saved!.modules, isEmpty);
    expect(saved!.abilities, isEmpty);
  });

  testWidgets('students.view only leaves attendance without access', (
    tester,
  ) async {
    final repo = await _repo();
    AdminUserPermissions? saved;
    await tester.pumpWidget(
      _editor(
        repo,
        const AdminUserPermissions(isAdmin: false),
        (permissions) => saved = permissions,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('module-switch-students')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(saved!.actionsFor('students').view, isTrue);
    expect(saved!.actionsFor('attendance').hasAnyAction, isFalse);
  });

  testWidgets('scope picker stores team ids on the module grant', (
    tester,
  ) async {
    final repo = await _repo();
    AdminUserPermissions? saved;
    await tester.pumpWidget(
      _editor(
        repo,
        const AdminUserPermissions(isAdmin: false),
        (permissions) => saved = permissions,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('module-switch-attendance')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('module-scope-attendance')));
    await tester.pumpAndSettle();

    expect(find.text('نطاق «الحضور»'), findsOneWidget);
    await tester.tap(find.text('حلقة النور'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اعتماد النطاق'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(saved!.actionsFor('attendance').teamIds, [7]);
    expect(saved!.actionsFor('attendance').view, isTrue);
  });

  testWidgets('course scope stores course ids', (tester) async {
    final repo = await _repo();
    AdminUserPermissions? saved;
    await tester.pumpWidget(
      _editor(
        repo,
        const AdminUserPermissions(isAdmin: false),
        (permissions) => saved = permissions,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('module-switch-students')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('module-scope-students')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('دورة النور'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اعتماد النطاق'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(saved!.actionsFor('students').courseIds, [3]);
  });

  testWidgets('an admin account locks every module control', (tester) async {
    final repo = await _repo();
    await tester.pumpWidget(
      _editor(repo, const AdminUserPermissions(isAdmin: true), (_) {}),
    );
    await tester.pumpAndSettle();

    final attendanceSwitch = tester.widget<Switch>(
      find.byKey(const ValueKey('module-switch-attendance')),
    );
    expect(attendanceSwitch.onChanged, isNull);
    expect(attendanceSwitch.value, isTrue);
  });
}
