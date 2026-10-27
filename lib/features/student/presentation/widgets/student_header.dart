import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/student_models.dart';

/// Student header used on the profile (B5): photo placeholder, name, id,
/// mosque name and relative "آخر ظهور".
class StudentHeader extends StatelessWidget {
  const StudentHeader({super.key, required this.profile, this.mosqueName});

  final StudentProfileModel profile;

  /// Mosque (tenant) name shown under the student's identity.
  final String? mosqueName;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: tokens.brandTint,
          child: Icon(Icons.face, size: 36, color: tokens.brand),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '#${profile.barcode}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
              ),
              if (mosqueName != null && mosqueName!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.mosque_outlined, size: 13, color: tokens.info),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        mosqueName!,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: tokens.info),
                      ),
                    ),
                  ],
                ),
              ],
              if (profile.lastSeenAt != null) ...[
                const SizedBox(height: 2),
                Text(
                  'آخر ظهور: ${_relative(profile.lastSeenAt!)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.brandText),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _relative(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 30) return 'منذ ${diff.inDays} يوم';
    return 'منذ ${(diff.inDays / 30).round()} شهر';
  }
}
