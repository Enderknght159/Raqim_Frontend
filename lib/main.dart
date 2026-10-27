import 'package:flutter/material.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/secure_storage.dart';
import 'features/admin/data/admin_api_repository.dart';
import 'features/auth/data/auth_remote_data_source.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/domain/auth_session.dart';
import 'features/student/data/student_api_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Storage + API client.
  final secureStorage = SecureStorage();
  final apiClient = await ApiClient.init(secureStorage);

  // Holds the real `/me` profile so the API repositories know the linked
  // student/teacher ids (no hardcoded demo ids).
  final session = ApiSession();

  // Auth feature.
  final authRepository = AuthRepository(
    remote: AuthRemoteDataSource(dio: apiClient.dio),
    storage: secureStorage,
    session: session,
  );

  // Both shells are backed by the live Laravel API through the shared Dio
  // client. The local drift repositories remain available for tests/offline
  // fallback but are no longer the source of truth.
  final studentRepository = StudentApiRepository(apiClient.dio, session);
  final adminRepository = AdminApiRepository(apiClient.dio, session);

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
