import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_card.dart';

/// Card showing the first [limit] rows + a "عرض المزيد" button which
/// navigates to a full screen (or opens a sheet) via [onShowAll].
class PreviewListCard extends StatelessWidget {
  const PreviewListCard({
    super.key,
    required this.children,
    this.limit = 3,
    this.onShowAll,
    this.showMoreLabel = 'عرض المزيد',
    this.title,
    this.icon,
  });

  final List<Widget> children;
  final int limit;
  final VoidCallback? onShowAll;
  final String showMoreLabel;
  final String? title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final preview = children.take(limit).toList();
    return AppCard(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: tokens.brand),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          for (final child in preview) child,
          if (children.length > limit)
            TextButton(
              onPressed: onShowAll,
              child: Text('$showMoreLabel (${children.length})',
                  style: TextStyle(color: tokens.brandText)),
            ),
        ],
      ),
    );
  }
}