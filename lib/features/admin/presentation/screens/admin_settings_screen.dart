import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/section_header.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

import '../../domain/admin_models.dart';
import '../admin_shell.dart';

/// E17 — Settings: mosque identity · policy · full export · deletion.
class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  bool _saving = false;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  late Future<({MosqueInfo mosque, MosqueDeletionState state})> _future;

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _email.dispose();
    _phone.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<({MosqueInfo mosque, MosqueDeletionState state})> _load() async {
    final repo = AdminRepositoryScope.of(context);
    final mosqueF = repo.mosque();
    final stateF = repo.mosqueDeletionState();
    final mosque = await mosqueF;
    final state = await stateF;
    _name.text = mosque.name;
    _code.text = mosque.code;
    _email.text = mosque.contactEmail ?? '';
    _phone.text = mosque.contactPhone ?? '';
    _city.text = mosque.city ?? '';
    return (mosque: mosque, state: state);
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: AsyncView<({MosqueInfo mosque, MosqueDeletionState state})>(
        future: _future,
        builder: (context, data) => ResponsivePage(
          maxWidth: 720,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader(
                      icon: Icons.badge_outlined,
                      title: 'هوية المسجد',
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'الاسم'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _code,
                      decoration: const InputDecoration(
                        labelText: 'الرمز',
                        helperText:
                            'يُستخدم في الباركود (رمز المسجد + معرّف الطالب)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'البريد'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'الهاتف'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _city,
                      decoration: const InputDecoration(labelText: 'المدينة'),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: _saving ? 'جارٍ الحفظ…' : 'حفظ',
                      loading: _saving,
                      onPressed: _saving ? null : () => _save(data.mosque),
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
                      icon: Icons.policy_outlined,
                      title: 'سياسة الخصوصية',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'النسخة الحالية: ${data.mosque.status ?? '—'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () =>
                          _notice(this.context, 'تُدار السياسة من لوحة المنصة'),
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
                      icon: Icons.file_download_outlined,
                      title: 'تصدير كامل',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'مهمة تصدير xlsx برابط تنزيل لمرة واحدة.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _exporting ? null : () => _export(context),
                      icon: const Icon(Icons.download),
                      label: Text(
                        _exporting ? 'جارٍ إنشاء التصدير…' : 'تصدير كامل',
                      ),
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
                      title: 'حذف المسجد',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.state.isDeleting
                          ? 'طلب الحذف نشط. يمكنك إلغاؤه قبل انتهاء المهلة.'
                          : 'يبدأ طلب الحذف بمهلة 30 يومًا، وتظهر شاشة توقف '
                                'لجميع المستخدمين خلالها مع إمكانية الإلغاء.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (data.state.deletionMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        data.state.deletionMessage!,
                        style: TextStyle(color: tokens.dangerText),
                      ),
                    ],
                    const SizedBox(height: 10),
                    if (data.state.isDeleting)
                      AppButton(
                        label: 'إلغاء طلب الحذف',
                        variant: AppButtonVariant.secondary,
                        onPressed: () => _cancelDeletion(context),
                      )
                    else
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
        ),
      ),
    );
  }

  Future<void> _save(MosqueInfo mosque) async {
    setState(() => _saving = true);
    try {
      await AdminRepositoryScope.of(context).updateMosque(
        name: _name.text,
        code: _code.text,
        contactEmail: _email.text,
        contactPhone: _phone.text,
        city: _city.text,
      );
      if (!mounted) return;
      _notice(context, 'تم حفظ هوية المسجد');
      _reload();
    } catch (error) {
      if (!mounted) return;
      _notice(context, 'تعذّر الحفظ: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _export(BuildContext context) async {
    setState(() => _exporting = true);
    try {
      final id = await AdminRepositoryScope.of(context).requestFullExport();
      if (!mounted) return;
      _notice(
        this.context,
        id == null ? 'بدأ التصدير الكامل' : 'بدأ التصدير الكامل (#$id)',
      );
    } catch (error) {
      if (!mounted) return;
      _notice(this.context, 'تعذّر بدء التصدير: $error');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _cancelDeletion(BuildContext context) async {
    try {
      await AdminRepositoryScope.of(context).cancelMosqueDeletion();
      if (!mounted) return;
      _notice(this.context, 'تم إلغاء طلب الحذف');
      _reload();
    } catch (error) {
      if (!mounted) return;
      _notice(this.context, 'تعذّر إلغاء الطلب: $error');
    }
  }

  void _notice(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('متابعة'),
          ),
        ],
      ),
    );
    if (first != true || !context.mounted) return;
    await showAppSheet<void>(
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
            Text(
              'رسالة شاشة التوقف',
              style: Theme.of(context).textTheme.titleMedium,
            ),
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
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await AdminRepositoryScope.of(
                    context,
                  ).requestMosqueDeletion(message: message.text);
                  if (!mounted) return;
                  _notice(this.context, 'تم إرسال طلب الحذف');
                  _reload();
                } catch (error) {
                  if (!mounted) return;
                  _notice(this.context, 'تعذّر إرسال الطلب: $error');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
