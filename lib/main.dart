import 'package:flutter/material.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/secure_storage.dart';
import 'features/admin/data/admin_local_repository.dart';
import 'features/auth/data/auth_remote_data_source.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/student/data/local/demo_seed.dart';
import 'features/student/data/local/student_database.dart';
import 'features/student/data/student_local_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Storage + API client.
  final secureStorage = SecureStorage();
  final apiClient = await ApiClient.init(secureStorage);

  // Auth feature.
  final authRepository = AuthRepository(
    remote: AuthRemoteDataSource(dio: apiClient.dio),
    storage: secureStorage,
  );

  // Local DB (drift, seeded once) — powers the trial build until the backend
  // is ready. Both the student and admin repositories share it.
  final database = await _openDb();
  final studentRepository = StudentLocalRepository(database);
  final adminRepository = AdminLocalRepository(database);

  // Bumped on every auth-state change so go_router re-runs its redirects.
  final sessionTick = ValueNotifier<int>(0);

  // Router (guards read the AuthCubit via context).
  final router = createAppRouter(refreshListenable: sessionTick);

  runApp(
    RaqimApp(
      dependencies: AppDependencies(
        authRepository: authRepository,
        studentRepository: studentRepository,
        adminRepository: adminRepository,
        sessionTick: sessionTick,
        router: router,
      ),
    ),
  );
}

Future<StudentDatabase> _openDb() async {
  final database = StudentDatabase();
  await seedDemoDataIfNeeded(database);
  return database;
}