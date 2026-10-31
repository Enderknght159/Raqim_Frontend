import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../core/widgets/adaptive_sheet.dart';
import '../core/widgets/app_button.dart';
import '../core/widgets/app_card.dart';
import '../features/auth/domain/models/stored_account.dart';
import '../features/auth/presentation/cubits/auth_cubit.dart';
import '../features/auth/presentation/cubits/auth_state.dart';

/// Shows saved accounts and lets the user switch or add one **without**
/// logging out the current account.
Future<void> showAccountSwitcher(BuildContext context) async {
  final switched = await showAppSheet<bool>(
    context: context,
    builder: (sheetContext) => const _AccountSwitcherSheet(),
  );
  if (switched == true && context.mounted) context.go('/');
}

class _AccountSwitcherSheet extends StatefulWidget {
  const _AccountSwitcherSheet();

  @override
  State<_AccountSwitcherSheet> createState() => _AccountSwitcherSheetState();
}

class _AccountSwitcherSheetState extends State<_AccountSwitcherSheet> {
  late Future<List<StoredAccount>> _future;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _future = context.read<AuthCubit>().accountsWithNames();
  }

  Future<void> _switch(StoredAccount account) async {
    if (_busy) return;
    final auth = context.read<AuthCubit>().state;
    if (auth is AuthAuthenticated && auth.profile.id == account.userId) {
      Navigator.of(context).pop(false);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final profile = await context.read<AuthCubit>().switchAccount(
        account.userId,
      );
      if (!mounted) return;
      if (profile == null) {
        setState(() {
          _busy = false;
          _error = 'تعذر التبديل إلى هذا الحساب';
        });
        return;
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'تعذر التبديل: $e';
      });
    }
  }

  Future<void> _addAccount() async {
    if (_busy) return;
    final added = await showDialog<bool>(
      context: context,
      builder: (_) => const _AddAccountDialog(),
    );
    if (added == true && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final auth = context.watch<AuthCubit>().state;
    final activeId = auth is AuthAuthenticated ? auth.profile.id : null;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: 24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'تبديل الحساب',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: tokens.info,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'اختر حسابًا محفوظًا أو أضف حسابًا جديدًا دون تسجيل خروج الحساب الحالي.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
            ),
            const SizedBox(height: 14),
            Flexible(
              child: FutureBuilder<List<StoredAccount>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final accounts = snapshot.data ?? const <StoredAccount>[];
                  if (accounts.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Text(
                        'لا توجد حسابات محفوظة بعد.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: accounts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      return _AccountTile(
                        account: account,
                        active: account.userId == activeId,
                        busy: _busy,
                        onTap: _busy ? null : () => _switch(account),
                      );
                    },
                  );
                },
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: tokens.dangerText, fontSize: 13),
              ),
            ],
            const SizedBox(height: 12),
            AppButton(
              label: 'إضافة حساب',
              icon: Icons.person_add_alt_1_outlined,
              variant: AppButtonVariant.secondary,
              loading: _busy,
              onPressed: _busy ? null : _addAccount,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.account,
    required this.active,
    required this.busy,
    required this.onTap,
  });

  final StoredAccount account;
  final bool active;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final initial = account.displayName.trim().isEmpty
        ? '?'
        : account.displayName.trim().substring(0, 1);
    return AppCard(
      onTap: busy ? null : onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderColor: active ? tokens.brandBorder : null,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: active ? tokens.brandTint : tokens.surfaceSubtle,
            child: Text(
              initial,
              style: TextStyle(
                color: active ? tokens.brandText : tokens.textSecondary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    account.mosqueLabel,
                    '@${account.username}',
                  ].where((e) => e.trim().isNotEmpty).join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
          if (active)
            Icon(Icons.check_circle, color: tokens.brand, size: 20)
          else
            Icon(Icons.chevron_left, color: tokens.borderStructural),
        ],
      ),
    );
  }
}

class _AddAccountDialog extends StatefulWidget {
  const _AddAccountDialog();

  @override
  State<_AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<_AddAccountDialog> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    final username = _username.text.trim();
    final password = _password.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'أدخل اسم المستخدم وكلمة المرور');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AuthCubit>().addAccount(username, password);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'تعذر الدخول: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة حساب'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _username,
            enabled: !_busy,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              labelText: 'اسم المستخدم',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            enabled: !_busy,
            obscureText: _obscure,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off,
                ),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).extension<AppTokens>()!.dangerText,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('دخول'),
        ),
      ],
    );
  }
}
