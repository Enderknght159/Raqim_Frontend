import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/section_header.dart';

/// E12 — Import wizard (stepper). Server processes the file; here we show the
/// full flow and confirm the selected file (trial: no backend).
class AdminImportScreen extends StatefulWidget {
  const AdminImportScreen({super.key});

  @override
  State<AdminImportScreen> createState() => _AdminImportScreenState();
}

class _AdminImportScreenState extends State<AdminImportScreen> {
  String _entity = 'students';
  String? _fileName;

  static const _entities = [
    ('students', 'طلاب'),
    ('attendance', 'حضور'),
    ('memorization', 'حفظ'),
    ('transactions', 'معاملات'),
    ('exams', 'امتحانات'),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Scaffold(
      appBar: AppBar(title: const Text('الاستيراد')),
      body: ResponsivePage(
        maxWidth: 900,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(icon: Icons.filter_1, title: 'الكيان'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _entity,
                    decoration: const InputDecoration(
                      labelText: 'نوع البيانات',
                    ),
                    items: [
                      for (final (value, label) in _entities)
                        DropdownMenuItem(value: value, child: Text(label)),
                    ],
                    onChanged: (v) => setState(() => _entity = v ?? _entity),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    icon: Icons.upload_file,
                    title: 'رفع ملف xlsx',
                  ),
                  const SizedBox(height: 8),
                  if (_fileName != null)
                    Text(
                      'الملف: $_fileName',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 8),
                  AppButton(
                    label: 'اختر ملفًا',
                    variant: AppButtonVariant.secondary,
                    icon: Icons.folder_open,
                    onPressed: _pickFile,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    icon: Icons.checklist,
                    title: 'التحقق والاستيراد',
                  ),
                  const SizedBox(height: 8),
                  for (final step in const [
                    'تطابق الأعمدة + معاينة',
                    'تحقق صفّي (الأخطاء بالأسباب)',
                    'استيراد جزئي + ملف الأخطاء',
                    'تراجع (أدمن فقط)',
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: tokens.brandBorder,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(step)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'المعالجة تتم على الخادم (غير مفعّلة في النسخة التجريبية).',
                    style: TextStyle(color: tokens.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );
      if (result != null && result.files.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _fileName = result.files.first.name;
        });
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختيار الملف غير متاح على هذه المنصة')),
      );
    }
  }
}
