import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';

/// E16 — Sync + kiosk.
class AdminSyncKioskScreen extends StatefulWidget {
  const AdminSyncKioskScreen({super.key});

  @override
  State<AdminSyncKioskScreen> createState() => _AdminSyncKioskScreenState();
}

class _AdminSyncKioskScreenState extends State<AdminSyncKioskScreen> {
  String _kioskMode = 'attendance';

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Scaffold(
      appBar: AppBar(title: const Text('المزامنة والكشك')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: SectionHeader(
                          icon: Icons.sync_outlined, title: 'المزامنة'),
                    ),
                    StatusBadge(label: 'متصل', color: tokens.brand),
                  ],
                ),
                const SizedBox(height: 8),
                Text('كل التغييرات مقبولة. لا تغييرات معلّقة.',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تمت المزامنة (محليًا)')),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('زامن الآن'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(
                    icon: Icons.tablet_android_outlined, title: 'وضع الكشك'),
                const SizedBox(height: 8),
                Text(
                  'يقفل التطبيق على شاشة واحدة حتى فتح PIN. مشتق من الوظيفة.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: tokens.textMuted),
                ),
                const SizedBox(height: 10),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                        value: 'attendance', label: Text('حضور')),
                    ButtonSegment(value: 'points', label: Text('نقاط')),
                  ],
                  selected: {_kioskMode},
                  onSelectionChanged: (s) =>
                      setState(() => _kioskMode = s.first),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تفعيل الكشك (تجريبي)')),
                  ),
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('تفعيل الكشك'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
