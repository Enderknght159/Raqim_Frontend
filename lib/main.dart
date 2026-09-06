import 'package:flutter/material.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/secure_storage.dart';
import 'features/auth/data/auth_remote_data_source.dart';
import 'features/auth/data/auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Storage + API client.
  final secureStorage = SecureStorage();
  final apiClient = await ApiClient.init(secureStorage);

  // Auth feature.
  final authRepository = AuthRepository(
    remote: AuthRemoteDataSource(apiClient: apiClient),
    storage: secureStorage,
  );

  // Router (guards read the AuthCubit via context).
  final router = createAppRouter();

  runApp(
    RaqimApp(
      dependencies: AppDependencies(
        authRepository: authRepository,
        router: router,
      ),
    ),
  );
}