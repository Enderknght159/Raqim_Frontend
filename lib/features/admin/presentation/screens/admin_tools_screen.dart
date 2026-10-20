import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/section_header.dart';

/// E15 — Tools: contextual export · barcode PDF · tasmi' sheets.
class AdminToolsScreen extends StatelessWidget {
  const AdminToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Scaffold(
      appBar: AppBar(title: const Text('الأدوات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(icon: Icons.file_download_outlined, title: 'التصدير'),
          const SizedBox(height: 6),
          Text(
            'التصدير سياقي: يظهر زر «تصدير» داخل كل قائمة/تقرير لتنزيل النتائج المفلترة (xlsx).',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: tokens.textMuted),
          ),
          const SizedBox(height: 16),
          const SectionHeader(icon: Icons.qr_code_2, title: 'باركود PDF'),
          const SizedBox(height: 6),
          Text('اختيار طلاب → PDF/طباعة (يتطلب الخادم).',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: tokens.textMuted)),
          const SizedBox(height: 16),
          const SectionHeader(icon: Icons.description_outlined, title: 'أوراق التسميع'),
          const SizedBox(height: 6),
          Text('اختيار نوع الحلقة → أوراق A5 مُعبّأة بآخر وصول (يتطلب الخادم).',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: tokens.textMuted)),
        ],
      ),
    );
  }
}
