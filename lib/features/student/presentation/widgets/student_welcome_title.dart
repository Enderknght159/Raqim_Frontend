import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= StudentRepositoryScope.of(context).profile();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return FutureBuilder<StudentProfileModel>(
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
