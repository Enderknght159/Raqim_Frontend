import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/presentation/cubits/auth_cubit.dart';
import '../features/auth/presentation/cubits/auth_state.dart';

/// Placeholder landing for teacher accounts (the teacher surface is planned
/// after the student/admin surfaces). Keeps a working logout path.
class TeacherSoonScreen extends StatelessWidget {
  const TeacherSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name = switch (context.watch<AuthCubit>().state) {
      AuthAuthenticated(:final profile) => profile.name,
      _ => '',
    };
    return Scaffold(
      appBar: AppBar(
        title: const Text('واجهة المعلم'),
        actions: [
          IconButton(
            tooltip: 'تسجيل الخروج',
            onPressed: () => context.read<AuthCubit>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction, size: 56),
              const SizedBox(height: 12),
              Text(
                name.isEmpty ? 'واجهة المعلم قريباً' : 'أهلاً $name',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'حسابك مرتبط بملف معلم. واجهة المعلم ستُضاف في مرحلة لاحقة.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
