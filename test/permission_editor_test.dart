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

Future<void> _openEditor(
  WidgetTester tester,
  _ScopeRepo repo,
  AdminUserPermissions initial,
  ValueChanged<AdminUserPermissions> onSave,
) async {
  tester.view.physicalSize = const Size(1100, 3200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_editor(repo, initial, onSave));
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester) async {
  await tester.tap(find.text('حفظ الصلاحيات'));
  await tester.pumpAndSettle();
}

Future<void> _togglePack(WidgetTester tester, String pack) async {
  await tester.tap(find.byKey(ValueKey('pack-switch-$pack')));
  await tester.pumpAndSettle();
}

Future<void> _expandAdvanced(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('advanced-permissions')));
  await tester.pumpAndSettle();
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('attendance write includes delete and only needs courses read', (
    tester,
  ) async {
    final repo = await _repo();
    AdminUserPermissions? saved;
    await _openEditor(
      tester,
      repo,
      const AdminUserPermissions(isAdmin: false),
      (permissions) => saved = permissions,
    );

    await _togglePack(tester, 'attendance');
    await _save(tester);

    expect(saved, isNotNull);
    final attendance = saved!.actionsFor('attendance');
    expect(attendance.view, isTrue);
    expect(attendance.create, isTrue);
    expect(attendance.update, isTrue);
    expect(attendance.delete, isTrue);
    expect(saved!.actionsFor('courses').view, isTrue);
    expect(saved!.actionsFor('courses').update, isFalse);
    expect(saved!.actionsFor('students').hasAnyAction, isFalse);
    expect(saved!.actionsFor('points').hasAnyAction, isFalse);
    expect(saved!.abilities.contains('permissionManagement'), isFalse);
  });

  testWidgets('attendance full also grants session settings', (tester) async {
    final repo = await _repo();
    AdminUserPermissions? saved;
    await _openEditor(
      tester,
      repo,
      const AdminUserPermissions(isAdmin: false),
      (permissions) => saved = permissions,
    );

    await _togglePack(tester, 'attendance');
    await tester.tap(find.byKey(const ValueKey('pack-level-attendance-full')));
    await tester.pumpAndSettle();
    await _save(tester);

    expect(saved!.actionsFor('courses').update, isTrue);
  });

  testWidgets('demoting an admin clears the computed module grants', (
    tester,
  ) async {
    final repo = await _repo();
    AdminUserPermissions? saved;
    await _openEditor(
      tester,
      repo,
      const AdminUserPermissions(isAdmin: true),
      (permissions) => saved = permissions,
    );

    await tester.tap(find.byKey(const ValueKey('admin-switch')));
    await tester.pumpAndSettle();
    await _save(tester);

    expect(saved!.isAdmin, isFalse);
    expect(saved!.modules, isEmpty);
    expect(saved!.abilities, isEmpty);
  });

  testWidgets('students read does not grant attendance', (tester) async {
    final repo = await _repo();
    AdminUserPermissions? saved;
    await _openEditor(
      tester,
      repo,
      const AdminUserPermissions(isAdmin: false),
      (permissions) => saved = permissions,
    );

    await _togglePack(tester, 'students');
    await tester.tap(find.byKey(const ValueKey('pack-level-students-read')));
    await tester.pumpAndSettle();
    await _save(tester);

    expect(saved!.actionsFor('students').view, isTrue);
    expect(saved!.actionsFor('students').create, isFalse);
    expect(saved!.actionsFor('attendance').hasAnyAction, isFalse);
    expect(saved!.actionsFor('courses').hasAnyAction, isFalse);
  });

  testWidgets('account scope stores team ids on every pack', (tester) async {
    final repo = await _repo();
    AdminUserPermissions? saved;
    await _openEditor(
      tester,
      repo,
      const AdminUserPermissions(isAdmin: false),
      (permissions) => saved = permissions,
    );

    await _togglePack(tester, 'attendance');
    await _togglePack(tester, 'quran');
    await tester.tap(find.byKey(const ValueKey('pack-scope-attendance')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('حلقة النور'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اعتماد النطاق'));
    await tester.pumpAndSettle();
    await _save(tester);

    expect(saved!.actionsFor('attendance').teamIds, [7]);
    expect(saved!.actionsFor('memorization').teamIds, [7]);
    expect(saved!.actionsFor('recitation').teamIds, [7]);
    expect(saved!.actionsFor('courses').teamIds, [7]);
    expect(saved!.actionsFor('teams').teamIds, [7]);
  });

  testWidgets('account scope stores course ids', (tester) async {
    final repo = await _repo();
    AdminUserPermissions? saved;
    await _openEditor(
      tester,
      repo,
      const AdminUserPermissions(isAdmin: false),
      (permissions) => saved = permissions,
    );

    await _togglePack(tester, 'students');
    await tester.tap(find.byKey(const ValueKey('pack-scope-students')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('دورة النور'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اعتماد النطاق'));
    await tester.pumpAndSettle();
    await _save(tester);

    expect(saved!.actionsFor('students').courseIds, [3]);
  });

  testWidgets('quran and matn are separate packs', (tester) async {
    final repo = await _repo();
    AdminUserPermissions? saved;
    await _openEditor(
      tester,
      repo,
      const AdminUserPermissions(isAdmin: false),
      (permissions) => saved = permissions,
    );

    await _togglePack(tester, 'quran');
    await _save(tester);

    expect(saved!.actionsFor('memorization').create, isTrue);
    expect(saved!.actionsFor('recitation').create, isTrue);
    expect(saved!.actionsFor('matn').hasAnyAction, isFalse);
  });

  testWidgets('matn pack does not grant quran records', (tester) async {
    final repo = await _repo();
    AdminUserPermissions? saved;
    await _openEditor(
      tester,
      repo,
      const AdminUserPermissions(isAdmin: false),
      (permissions) => saved = permissions,
    );

    await _togglePack(tester, 'matn');
    await _save(tester);

    expect(saved!.actionsFor('matn').create, isTrue);
    expect(saved!.actionsFor('memorization').hasAnyAction, isFalse);
    expect(saved!.actionsFor('recitation').hasAnyAction, isFalse);
  });

  testWidgets('disabling attendance removes its auto prerequisites', (
    tester,
  ) async {
    final repo = await _repo();
    AdminUserPermissions? saved;
    await _openEditor(
      tester,
      repo,
      const AdminUserPermissions(isAdmin: false),
      (permissions) => saved = permissions,
    );

    await _togglePack(tester, 'attendance');
    await _togglePack(tester, 'attendance');
    await _save(tester);

    expect(saved!.actionsFor('attendance').hasAnyAction, isFalse);
    expect(saved!.actionsFor('courses').hasAnyAction, isFalse);
  });

  testWidgets('advanced write always implies read', (tester) async {
    final repo = await _repo();
    AdminUserPermissions? saved;
    await _openEditor(
      tester,
      repo,
      const AdminUserPermissions(isAdmin: false),
      (permissions) => saved = permissions,
    );

    await _expandAdvanced(tester);
    await tester.tap(find.byKey(const ValueKey('advanced-level-points-write')));
    await tester.pumpAndSettle();
    await _save(tester);

    final points = saved!.actionsFor('points');
    expect(points.view, isTrue);
    expect(points.create, isTrue);
    expect(points.update, isTrue);
    expect(points.delete, isFalse);
  });

  testWidgets('advanced full includes delete', (tester) async {
    final repo = await _repo();
    AdminUserPermissions? saved;
    await _openEditor(
      tester,
      repo,
      const AdminUserPermissions(isAdmin: false),
      (permissions) => saved = permissions,
    );

    await _expandAdvanced(tester);
    await tester.tap(find.byKey(const ValueKey('advanced-level-points-full')));
    await tester.pumpAndSettle();
    await _save(tester);

    final points = saved!.actionsFor('points');
    expect(points.view, isTrue);
    expect(points.create, isTrue);
    expect(points.update, isTrue);
    expect(points.delete, isTrue);
  });

  testWidgets('advanced export can be enabled for an active module', (
    tester,
  ) async {
    final repo = await _repo();
    AdminUserPermissions? saved;
    await _openEditor(
      tester,
      repo,
      const AdminUserPermissions(isAdmin: false),
      (permissions) => saved = permissions,
    );

    await _togglePack(tester, 'points');
    await _expandAdvanced(tester);
    await tester.tap(find.byKey(const ValueKey('advanced-export-points')));
    await tester.pumpAndSettle();
    await _save(tester);

    expect(saved!.actionsFor('points').export, isTrue);
    expect(saved!.actionsFor('points').view, isTrue);
  });

  testWidgets('an admin account locks every pack control', (tester) async {
    final repo = await _repo();
    await _openEditor(
      tester,
      repo,
      const AdminUserPermissions(isAdmin: true),
      (_) {},
    );

    final attendanceSwitch = tester.widget<Switch>(
      find.byKey(const ValueKey('pack-switch-attendance')),
    );
    expect(attendanceSwitch.onChanged, isNull);
    final adminSwitch = tester.widget<Switch>(
      find.byKey(const ValueKey('admin-switch')),
    );
    expect(adminSwitch.value, isTrue);
  });

  testWidgets('permissionManagement is not offered', (tester) async {
    final repo = await _repo();
    await _openEditor(
      tester,
      repo,
      const AdminUserPermissions(isAdmin: false),
      (_) {},
    );

    expect(
      find.byKey(const ValueKey('ability-permissionManagement')),
      findsNothing,
    );
  });

  testWidgets('quranCertificates is visible only in advanced and unsupported', (
    tester,
  ) async {
    final repo = await _repo();
    await _openEditor(
      tester,
      repo,
      const AdminUserPermissions(isAdmin: false),
      (_) {},
    );

    expect(
      find.byKey(const ValueKey('advanced-module-quranCertificates')),
      findsNothing,
    );
    await _expandAdvanced(tester);
    expect(
      find.byKey(const ValueKey('advanced-module-quranCertificates')),
      findsOneWidget,
    );
    expect(find.text('غير مدعوم'), findsOneWidget);
  });

  testWidgets('a partial grant is surfaced without being overstated', (
    tester,
  ) async {
    final repo = await _repo();
    await _openEditor(
      tester,
      repo,
      const AdminUserPermissions(
        isAdmin: false,
        modules: {'attendance': AdminModuleGrant(view: true, create: true)},
      ),
      (_) {},
    );

    expect(find.text('إعداد جزئي'), findsOneWidget);
  });

  testWidgets('the editor has no overflow on a narrow phone width', (
    tester,
  ) async {
    final repo = await _repo();
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      _editor(repo, const AdminUserPermissions(isAdmin: false), (_) {}),
    );
    await tester.pumpAndSettle();

    await _togglePack(tester, 'attendance');
    expect(tester.takeException(), isNull);
  });
}
