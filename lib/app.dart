import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/config/app_config.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/data/admin_repository.dart';
import 'features/admin/presentation/admin_shell.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/domain/models/user_profile.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';
import 'features/student/data/student_repository.dart';
import 'features/student/presentation/student_shell.dart';

/// App dependencies shared across the tree.
class AppDependencies {
  const AppDependencies({
    required this.authRepository,
    required this.studentRepository,
    required this.adminRepository,
    required this.warmCache,
    required this.sessionTick,
    required this.router,
  });

  final AuthRepository authRepository;
  final StudentRepository studentRepository;
  final AdminRepository adminRepository;
  final Future<void> Function(UserProfile profile) warmCache;
  final ValueNotifier<int> sessionTick;
  final GoRouter router;
}

/// Root widget: theme, localization, router and global providers.
class RaqimApp extends StatelessWidget {
  const RaqimApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(
            dependencies.authRepository,
            onAuthChanged: () => dependencies.sessionTick.value++,
            onAuthenticated: dependencies.warmCache,
          ),
        ),
      ],
      child: AdminRepositoryScope(
        repository: dependencies.adminRepository,
        child: StudentRepositoryScope(
          repository: dependencies.studentRepository,
          child: _AuthLifecycle(
            child: MaterialApp.router(
              title: 'رقيم',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: ThemeMode.light,
              locale: const Locale(AppConfig.defaultLocale),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: appLocalizationsDelegates(),
              routerConfig: dependencies.router,
            ),
          ),
        ),
      ),
    );
  }
}

/// Refreshes `/me` when the app returns to the foreground, so grants revoked
/// or added while the app was in the background take effect immediately.
class _AuthLifecycle extends StatefulWidget {
  const _AuthLifecycle({required this.child});

  final Widget child;

  @override
  State<_AuthLifecycle> createState() => _AuthLifecycleState();
}

class _AuthLifecycleState extends State<_AuthLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    try {
      context.read<AuthCubit>().refreshProfile();
    } catch (_) {
      // Tests may mount the app without an AuthCubit.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
