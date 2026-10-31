import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/cubits/auth_state.dart';
import '../../domain/models/student_models.dart';
import '../student_shell.dart';

/// Compact student identity used as the AppBar title on all student tabs:
/// avatar + name (the current page title is shown below the AppBar).
class StudentWelcomeTitle extends StatefulWidget {
  const StudentWelcomeTitle({super.key});

  @override
  State<StudentWelcomeTitle> createState() => _StudentWelcomeTitleState();
}

class _StudentWelcomeTitleState extends State<StudentWelcomeTitle> {
  Future<StudentProfileModel>? _future;
  int? _userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= StudentRepositoryScope.of(context).profile();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    int? userId;
    try {
      final auth = context.watch<AuthCubit>().state;
      userId = auth is AuthAuthenticated ? auth.profile.id : null;
    } catch (_) {
      // The widget is also used in isolated shell tests without an AuthCubit.
    }
    if (userId != _userId) {
      _userId = userId;
      _future = StudentRepositoryScope.of(context).profile();
    }
    return FutureBuilder<StudentProfileModel>(
      key: ValueKey(userId),
      future: _future,
      builder: (context, snapshot) {
        final profile = snapshot.data;
        if (profile == null) return const SizedBox.shrink();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: tokens.brandTint,
              child: Text(
                profile.name.characters.first,
                style: TextStyle(
                  color: tokens.brandText,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                profile.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: tokens.textPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
