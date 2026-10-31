import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/icon_toggle_group.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../shared/account_switcher.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../data/student_repository.dart';
import '../../domain/models/student_models.dart';
import '../student_shell.dart';
import '../widgets/qr_code_view.dart';
import '../widgets/student_header.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

/// B5 — الملف: welcome header (with mosque name) + barcode + data + phones +
/// edit requests + account.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<({StudentProfileModel profile, String mosqueName})> _load(
    StudentRepository repo,
  ) async {
    final profile = await repo.profile();
    final mosque = await repo.mosqueName();
    return (profile: profile, mosqueName: mosque);
  }

  Future<({StudentProfileModel profile, String mosqueName})?> _cachedLoad(
    StudentRepository repo,
  ) async {
    final profile = await repo.cachedProfile();
    if (profile == null) return null;
    return (profile: profile, mosqueName: await repo.mosqueName());
  }

  @override
  Widget build(BuildContext context) {
    final repo = StudentRepositoryScope.of(context);
    return Scaffold(
      body: AsyncView<({StudentProfileModel profile, String mosqueName})>(
        future: _load(repo),
        cacheKey: 'student-profile',
        cached: _cachedLoad(repo),
        builder: (context, data) {
          final profile = data.profile;
          return ResponsivePage(
            maxWidth: 720,
            child: RefreshIndicator(
              onRefresh: () async {},
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  StudentHeader(profile: profile, mosqueName: data.mosqueName),
                  const SizedBox(height: 16),
                  _barcodeCard(context, profile),
                  const SizedBox(height: 16),
                  const SectionHeader(
                    icon: Icons.person_outline,
                    title: 'البيانات',
                  ),
                  const SizedBox(height: 8),
                  AppCard(
                    child: Column(
                      children: [
                        _infoRow(
                          context,
                          label: 'الاسم',
                          value: profile.name,
                          onEdit: () => _requestEdit(
                            context,
                            label: 'الاسم',
                            currentValue: profile.name,
                            kind: EditKind.text,
                            field: 'name',
                          ),
                        ),
                        _divider(),
                        _infoRow(
                          context,
                          label: 'اسم الأب',
                          value: profile.fatherName ?? '—',
                          onEdit: () => _requestEdit(
                            context,
                            label: 'اسم الأب',
                            currentValue: profile.fatherName ?? '',
                            kind: EditKind.text,
                            field: 'fatherName',
                          ),
                        ),
                        _divider(),
                        _infoRow(
                          context,
                          label: 'سنة الميلاد',
                          value: profile.yearOfBirth?.toString() ?? '—',
                          onEdit: () => _requestEdit(
                            context,
                            label: 'سنة الميلاد',
                            currentValue: profile.yearOfBirth?.toString() ?? '',
                            kind: EditKind.year,
                            field: 'yearOfBirth',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionHeader(
                    icon: Icons.phone_outlined,
                    title: 'أرقام الهاتف',
                    trailing: _iconAction(
                      context,
                      tooltip: 'إضافة رقم',
                      icon: Icons.add,
                      onPressed: () => _addOrEditPhone(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  AppCard(
                    child: Column(
                      children: [
                        if (profile.phones.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'لا أرقام مسجلة',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          )
                        else
                          for (final phone in profile.phones)
                            _phoneRow(
                              context,
                              phone,
                              onEdit: () =>
                                  _addOrEditPhone(context, editing: phone),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'تبديل الحساب',
                    variant: AppButtonVariant.secondary,
                    icon: Icons.swap_horiz,
                    onPressed: () => _switchAccount(context),
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    label: 'خروج',
                    variant: AppButtonVariant.destructive,
                    icon: Icons.logout,
                    onPressed: () => _confirmLogout(context),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Confirms before ending the session (student side).
  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).extension<AppTokens>()!.danger,
            ),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final next = await context.read<AuthCubit>().logout();
    if (!context.mounted) return;
    context.go(next == null ? '/welcome' : '/');
  }

  Widget _barcodeCard(BuildContext context, StudentProfileModel profile) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return AppCard(
      onTap: () => _showBarcode(context, profile),
      child: Row(
        children: [
          Icon(
            Icons.qr_code_2,
            size: 40,
            color: Theme.of(context).extension<AppTokens>()!.info,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.barcode,
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'اضغط للعرض الكامل',
                  style: TextStyle(color: tokens.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_left, color: tokens.borderStructural),
        ],
      ),
    );
  }

  void _showBarcode(BuildContext context, StudentProfileModel profile) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    // Scale the QR to the viewport and keep the sheet scrollable so short
    // screens never overflow (the old fixed sheet overflowed by ~81px).
    final size = MediaQuery.sizeOf(context);
    final qrSize = (size.width - 96).clamp(140.0, 220.0);
    showAppSheet<void>(
      context: context,
      maxWidth: 420,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'الباركود الخاص بك',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: tokens.info,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: QrCodeCard(code: profile.barcode, size: qrSize),
              ),
              const SizedBox(height: 12),
              Text(
                'اعرضه أمام الماسح عند بوابة الحلقة',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1);

  Widget _iconAction(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: tokens.brandText),
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(color: tokens.textMuted, fontSize: 13),
      ),
      subtitle: Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      trailing: _iconAction(
        context,
        tooltip: 'تعديل $label',
        icon: Icons.edit_outlined,
        onPressed: onEdit,
      ),
    );
  }

  Widget _phoneRow(
    BuildContext context,
    Phone phone, {
    required VoidCallback onEdit,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.phone_outlined, color: tokens.brandText),
      title: Row(
        children: [
          Expanded(child: Text(phone.phone, textDirection: TextDirection.ltr)),
          const SizedBox(width: 8),
          StatusBadge(label: phone.typeLabel, color: tokens.infoLight),
        ],
      ),
      trailing: _iconAction(
        context,
        tooltip: 'تعديل الرقم',
        icon: Icons.edit_outlined,
        onPressed: onEdit,
      ),
    );
  }

  void _requestEdit(
    BuildContext context, {
    required String label,
    required String currentValue,
    required EditKind kind,
    required String field,
  }) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final controller = TextEditingController(text: currentValue);
    var error = '';
    showAppSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
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
                'طلب تعديل — $label',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'يُرسل الطلب للموافقة من الإدارة',
                style: TextStyle(color: tokens.textMuted),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: _keyboardFor(kind),
                inputFormatters: _formattersFor(kind),
                onChanged: (_) {
                  if (error.isNotEmpty) setState(() => error = '');
                },
                decoration: InputDecoration(
                  labelText: label,
                  errorText: error.isEmpty ? null : error,
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'إرسال الطلب',
                onPressed: () async {
                  final newValue = controller.text.trim();
                  if (newValue.isEmpty || newValue == currentValue.trim()) {
                    setState(
                      () => error = 'أدخل قيمة جديدة مختلفة عن القيمة الحالية',
                    );
                    return;
                  }
                  try {
                    await StudentRepositoryScope.of(
                      context,
                    ).requestChange(field: field, requestedValue: newValue);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'تم إرسال طلب التعديل — بانتظار الموافقة',
                        ),
                      ),
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    setState(() => error = 'تعذّر الإرسال: $e');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addOrEditPhone(BuildContext context, {Phone? editing}) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final numberController = TextEditingController(text: editing?.phone ?? '');
    var type = editing?.type ?? 'parent';
    var error = '';
    showAppSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
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
                editing == null ? 'إضافة رقم هاتف' : 'تعديل رقم الهاتف',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'الأنواع: ولي الأمر · الطالب · أرضي (BR-622)',
                style: TextStyle(color: tokens.textMuted),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: numberController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                ],
                onChanged: (_) {
                  if (error.isNotEmpty) setState(() => error = '');
                },
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  errorText: error.isEmpty ? null : error,
                ),
              ),
              const SizedBox(height: 12),
              IconToggleGroup<String>(
                value: type,
                onChanged: (v) => setState(() => type = v),
                options: const [
                  IconToggleOption(
                    value: 'parent',
                    icon: Icons.family_restroom,
                    label: 'ولي الأمر',
                  ),
                  IconToggleOption(
                    value: 'student',
                    icon: Icons.person_outline,
                    label: 'الطالب',
                  ),
                  IconToggleOption(
                    value: 'landline',
                    icon: Icons.phone_in_talk_outlined,
                    label: 'هاتف أرضي',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'إرسال الطلب',
                onPressed: () async {
                  final newPhone = numberController.text.trim();
                  if (newPhone.isEmpty ||
                      (editing != null &&
                          newPhone == editing.phone.trim() &&
                          type == editing.type)) {
                    setState(
                      () => error = 'أدخل رقمًا جديدًا مختلفًا أو غيّر النوع',
                    );
                    return;
                  }
                  try {
                    await StudentRepositoryScope.of(context).requestChange(
                      field: 'phoneNumber',
                      requestedValue: newPhone,
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          editing == null
                              ? 'تم إرسال طلب إضافة الرقم'
                              : 'تم إرسال طلب تعديل الرقم',
                        ),
                      ),
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    setState(() => error = 'تعذّر الإرسال: $e');
                  }
                },
              ),
              if (editing != null) ...[
                const SizedBox(height: 8),
                AppButton(
                  label: 'إزالة هذا الرقم',
                  variant: AppButtonVariant.destructive,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إرسال طلب إزالة الرقم')),
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  TextInputType _keyboardFor(EditKind kind) => switch (kind) {
    EditKind.year => TextInputType.number,
    EditKind.text => TextInputType.text,
  };

  List<TextInputFormatter> _formattersFor(EditKind kind) => switch (kind) {
    EditKind.year => [FilteringTextInputFormatter.digitsOnly],
    EditKind.text => [],
  };

  void _switchAccount(BuildContext context) {
    showAccountSwitcher(context);
  }
}

enum EditKind { text, year }
