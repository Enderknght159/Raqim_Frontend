import 'package:flutter/material.dart';

/// Dismissible, tinted inline notification banner (non-blocking).
/// Used for gentle reminders (e.g. default-password warning).
class InfoBanner extends StatefulWidget {
  const InfoBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.color,
    this.dismissible = true,
  });

  final String message;
  final IconData icon;
  final Color? color;
  final bool dismissible;

  @override
  State<InfoBanner> createState() => _InfoBannerState();
}

class _InfoBannerState extends State<InfoBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    final accent = widget.color ?? Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(widget.icon, size: 20, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          if (widget.dismissible)
            IconButton(
              onPressed: () => setState(() => _dismissed = true),
              visualDensity: VisualDensity.compact,
              tooltip: 'إغلاق',
              icon: Icon(
                Icons.close,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
