import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../shared/account_switcher.dart';
import '../../../admin/domain/admin_models.dart';
import '../../../admin/presentation/admin_shell.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../auth/presentation/cubits/auth_state.dart';

class TeacherAccountScreen extends StatefulWidget {
  const TeacherAccountScreen({super.key});

  @override
  State<TeacherAccountScreen> createState() => _TeacherAccountScreenState();
}

class _TeacherAccountScreenState extends State<TeacherAccountScreen> {
  List<AdminTeamRow> _teams = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTeams());
  }

  Future<void> _loadTeams() async {
    try {
      final teams = await AdminRepositoryScope.of(context).teams();
      if (!mounted) return;
      setState(() {
        _teams = teams;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final auth = context.watch<AuthCubit>().state;
    final profile = auth is AuthAuthenticated ? auth.profile : null;

    return ResponsivePage(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: tokens.brandTint,
                  child: Text(
                    (profile?.name.trim().isNotEmpty ?? false)
                        ? profile!.name.characters.first
                        : '?',
                    style: TextStyle(
                      color: tokens.brandText,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.name ?? 'معلم',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile?.mosqueName ?? '—',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textMuted,
                        ),
                      ),
                      if ((profile?.username ?? '').isNotEmpty)
                        Text(
                          '@${profile!.username}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: tokens.textMuted),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            icon: Icons.groups_outlined,
            title: 'حلقاتي ونوعها',
          ),
          const SizedBox(height: 8),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_teams.isEmpty)
            AppCard(
              child: Text(
                'لا حلقات مرتبطة بحسابك حاليًا.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
              ),
            )
          else
            for (final team in _teams) ...[
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      team.typeName.isEmpty ? 'نوع غير محدد' : team.typeName,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (team.typePermissions.quranTasmi)
                          AppChip(
                            label: 'تسميع',
                            icon: Icons.auto_stories_outlined,
                            color: tokens.brand,
                          ),
                        if (team.typePermissions.matn)
                          AppChip(
                            label: 'متون',
                            icon: Icons.menu_book_outlined,
                            color: tokens.accentMatn,
                          ),
                        if (team.typePermissions.attendance)
                          AppChip(
                            label: 'حضور',
                            icon: Icons.how_to_reg_outlined,
                            color: tokens.info,
                          ),
                        if (team.typePermissions.points)
                          AppChip(
                            label: 'نقاط',
                            icon: Icons.stars_outlined,
                            color: tokens.reward,
                          ),
                        if (!team.typePermissions.any)
                          AppChip(label: 'قراءة فقط', color: tokens.textMuted),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          const SizedBox(height: 16),
          const SectionHeader(
            icon: Icons.manage_accounts_outlined,
            title: 'الحساب',
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'تبديل الحساب',
            icon: Icons.swap_horiz,
            variant: AppButtonVariant.secondary,
            onPressed: () => showAccountSwitcher(context),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'خروج',
            icon: Icons.logout,
            variant: AppButtonVariant.destructive,
            onPressed: _confirmLogout,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
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
            child: const Text('خروج'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final next = await context.read<AuthCubit>().logout();
    if (!mounted) return;
    context.go(next == null ? '/welcome' : '/');
  }
}
