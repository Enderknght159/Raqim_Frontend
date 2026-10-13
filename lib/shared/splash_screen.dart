import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/widgets/raqim_logo.dart';
import '../../features/auth/presentation/cubits/auth_cubit.dart';

/// Splash shown while the session is being restored on startup.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger the restore in a post-frame callback so it happens once.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().restoreSession();
    });
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const RaqimLogo(size: 280),
            const SizedBox(height: 40),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}