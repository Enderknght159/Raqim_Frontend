import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/widgets/animated_entrance.dart';
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
      // Light-only app: keep a white surface so the dark brand mark
      // (Raqim_Logo_LTBG) keeps its contrast (A1-splash.md §5).
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedEntrance(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 60),
              child: const RaqimLogo(size: 240),
            ),
            const SizedBox(height: 40),
            AnimatedEntrance(
              duration: const Duration(milliseconds: 250),
              delay: const Duration(milliseconds: 260),
              child: const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
