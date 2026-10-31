import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:raqim/core/theme/app_theme.dart';
import 'package:raqim/features/admin/data/admin_local_repository.dart';
import 'package:raqim/features/admin/domain/admin_models.dart';
import 'package:raqim/features/admin/presentation/admin_shell.dart';
import 'package:raqim/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:raqim/features/admin/presentation/widgets/admin_role_badges.dart';
import 'package:raqim/features/student/data/local/demo_seed.dart';
import 'package:raqim/features/student/data/local/student_database.dart';

class _RecordingAdminRepository extends AdminLocalRepository {
  // The super constructor parameter is library-private, so it cannot be a
  // super parameter here.
  // ignore: use_super_parameters
  _RecordingAdminRepository(StudentDatabase db) : super(db);

  final queries = <String>[];

  String get lastQuery => queries.isEmpty ? '' : queries.last;

  @override
  Future<PagedResult<AdminUserRow>> usersPage({
    String? query,
    String filter = 'all',
    int page = 1,
    int pageSize = 30,
  }) {
    queries.add(query?.trim() ?? '');
    return super.usersPage(
      query: query,
      filter: filter,
      page: page,
      pageSize: pageSize,
    );
  }
}

Future<_RecordingAdminRepository> _repository() async {
  final db = StudentDatabase.forTesting(NativeDatabase.memory());
  await seedDemoDataIfNeeded(db);
  return _RecordingAdminRepository(db);
}

Widget _app(_RecordingAdminRepository repo, Widget child) {
  return AdminRepositoryScope(
    repository: repo,
    child: MaterialApp(theme: AppTheme.light(), home: child),
  );
}

Widget _badges({
  bool isAdmin = false,
  bool isSupervisor = false,
  bool isTeacher = false,
  bool isStudent = false,
}) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: AdminRoleBadges(
        isAdmin: isAdmin,
        isSupervisor: isSupervisor,
        isTeacher: isTeacher,
        isStudent: isStudent,
      ),
    ),
  );
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('dual-role account shows one badge per role', (tester) async {
    await tester.pumpWidget(
      _badges(isSupervisor: true, isTeacher: true, isStudent: true),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.verified_user), findsOneWidget);
    expect(find.byIcon(Icons.school), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byIcon(Icons.admin_panel_settings), findsNothing);
    expect(find.byType(Tooltip), findsNWidgets(3));
  });

  testWidgets('student-only account shows a single badge', (tester) async {
    await tester.pumpWidget(_badges(isStudent: true));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byIcon(Icons.verified_user), findsNothing);
    expect(find.byIcon(Icons.school), findsNothing);
    expect(find.byIcon(Icons.admin_panel_settings), findsNothing);
  });

  testWidgets('admin + supervisor account shows both badges', (tester) async {
    await tester.pumpWidget(_badges(isAdmin: true, isSupervisor: true));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.admin_panel_settings), findsOneWidget);
    expect(find.byIcon(Icons.verified_user), findsOneWidget);
  });

  testWidgets('search sends the term to /admin/users', (tester) async {
    final repo = await _repository();
    await tester.pumpWidget(_app(repo, const AdminUsersScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'admin');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(repo.lastQuery, 'admin');
    expect(find.text('مدير المسجد'), findsOneWidget);
  });

  testWidgets('numeric account id falls back to the loaded page', (
    tester,
  ) async {
    final repo = await _repository();
    final page = await repo.usersPage(pageSize: 30);
    final student = page.items.firstWhere((row) => row.isStudent);

    await tester.pumpWidget(_app(repo, const AdminUsersScreen()));
    await tester.pumpAndSettle();
    expect(find.text(student.displayName), findsWidgets);

    await tester.enterText(find.byType(TextField), '${student.id}');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(repo.lastQuery, '${student.id}');
    expect(find.text(student.displayName), findsOneWidget);
  });
}
