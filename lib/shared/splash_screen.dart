import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/cubits/auth_cubit.dart';
import '../core/widgets/app_loading.dart';

/// Splash shown while the session is being restored on startup.
///
/// The loading indicator is intentionally just three calm brand-colored dots.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().restoreSession();
    });
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: AppLoadingView()),
    );
  }
}
