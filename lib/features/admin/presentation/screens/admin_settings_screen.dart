import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_header.dart';

/// E17 — Settings: mosque identity · policy · full export · deletion.
class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final name = TextEditingController(text: 'جامع الفرقان');
    final code = TextEditingController(text: 'frq');
    final email = TextEditingController(text: 'info@example.com');
    final phone = TextEditingController(text: '+201000000000');
    final city = TextEditingController(text: 'الرياض');

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(
                    icon: Icons.badge_outlined, title: 'هوية المسجد'),
                const SizedBox(height: 10),
                TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'الاسم')),
                const SizedBox(height: 10),
                TextField(
                  controller: code,
                  decoration: const InputDecoration(
                    labelText: 'الرمز',
                    helperText: 'يُستخدم في الباركود (رمز المسجد + معرّف الطالب)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'البريد')),
                const SizedBox(height: 10),
                TextField(
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'الهاتف')),
                const SizedBox(height: 10),
                TextField(
                    controller: city,
                    decoration: const InputDecoration(labelText: 'المدينة')),
                const SizedBox(height: 10),
                AppButton(
                  label: 'حفظ',
                  onPressed: () => _notice(context, 'تم حفظ الهوية'),
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
                    icon: Icons.policy_outlined, title: 'سياسة الخصوصية'),
                const SizedBox(height: 8),
                Text('عرض النسخة الحالية (التعديل من المنصة).',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _notice(context, 'عرض السياسة'),
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('عرض'),
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
                    icon: Icons.file_download_outlined, title: 'تصدير كامل'),
                const SizedBox(height: 8),
                Text('مهمة تصدير xlsx برابط تنزيل لمرة واحدة.',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _notice(context, 'بدأ التصدير الكامل (تجريبي)'),
                  icon: const Icon(Icons.download),
                  label: const Text('تصدير كامل'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            borderColor: tokens.danger.withValues(alpha: 0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(
                    icon: Icons.delete_forever_outlined,
                    title: 'حذف المسجد'),
                const SizedBox(height: 8),
                Text(
                  'يبدأ طلب الحذف بمهلة 30 يومًا، وتظهر شاشة توقف لجميع المستخدمين '
                  'خلالها مع إمكانية الإلغاء في أي وقت.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                AppButton(
                  label: 'طلب حذف المسجد',
                  variant: AppButtonVariant.dangerOutline,
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _notice(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final message = TextEditingController();
    final first = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد حذف المسجد'),
        content: const Text('سيبدأ طلب الحذف بمهلة 30 يومًا. متابعة؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('متابعة')),
        ],
      ),
    );
    if (first != true || !context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 0,
          bottom: 28 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('رسالة شاشة التوقف',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: message,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'رسالة مخصّصة',
                helperText:
                    'تظهر هذه الرسالة للمستخدمين في شاشة التوقف طوال مهلة '
                    'الـ30 يومًا مع إمكانية إلغاء الحذف',
                helperMaxLines: 3,
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'تأكيد طلب الحذف',
              variant: AppButtonVariant.destructive,
              onPressed: () {
                Navigator.of(context).pop();
                _notice(context, 'تم إرسال طلب الحذف (تجريبي)');
              },
            ),
          ],
        ),
      ),
    );
  }
}
