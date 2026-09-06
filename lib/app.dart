import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/config/app_config.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';

/// App dependencies shared across the tree.
class AppDependencies {
  const AppDependencies({
    required this.authRepository,
    required this.router,
  });

  final AuthRepository authRepository;
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
          create: (_) => AuthCubit(dependencies.authRepository),
        ),
      ],
      child: MaterialApp.router(
        title: 'رقيم',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        locale: const Locale(AppConfig.defaultLocale),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: appLocalizationsDelegates(),
        routerConfig: dependencies.router,
      ),
    );
  }
}