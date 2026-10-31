import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';
import '../widgets/admin_role_badges.dart';
import 'admin_user_detail_screen.dart';

/// E11 - Users + permissions. Server-paginated/searchable account list.
/// Permissions are loaded/saved from `/admin/users/{id}/permissions`.
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;
  final _items = <AdminUserRow>[];
  final _snapshot = <AdminUserRow>[];
  String _filter = 'all';
  int _page = 1;
  int _requestId = 0;
  bool _hasMore = true;
  bool _loading = true;
  bool _loadingMore = false;
  bool _refreshing = false;
  Object? _error;
  Object? _loadMoreError;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({required bool reset}) async {
    final requestId = ++_requestId;
    if (!mounted) return;
    if (reset) {
      setState(() {
        _loading = _items.isEmpty;
        _refreshing = _items.isNotEmpty;
        _error = null;
        _loadMoreError = null;
        _page = 1;
        _hasMore = true;
      });
    } else {
      if (_loadingMore || !_hasMore) return;
      setState(() {
        _loadingMore = true;
        _loadMoreError = null;
      });
    }

    final repo = AdminRepositoryScope.of(context);
    final fetchPage = reset ? 1 : _page;
    if (reset) {
      try {
        final cached = await repo.usersPageCached(
          query: _search.text,
          filter: _filter,
          page: 1,
          pageSize: 30,
        );
        if (!mounted || requestId != _requestId) return;
        if (cached != null && cached.items.isNotEmpty) {
          setState(() {
            _items
              ..clear()
              ..addAll(cached.items);
            _hasMore = cached.hasMore;
            _loading = false;
            _refreshing = true;
          });
        }
      } catch (_) {
        // A cache miss is normal.
      }
    }

    try {
      final result = await repo
          .usersPage(
            query: _search.text,
            filter: _filter,
            page: fetchPage,
            pageSize: 30,
          )
          .timeout(const Duration(seconds: 20));
      if (!mounted || requestId != _requestId) return;
      var items = result.items;
      var hasMore = result.hasMore;
      final query = _search.text.trim();
      if (reset && query.isEmpty) {
        _snapshot
          ..clear()
          ..addAll(items);
      } else if (reset && items.isEmpty && _snapshot.isNotEmpty) {
        // The server only searches name/username/email. Student accounts often
        // have an empty name, so an id/username/display-name match can miss.
        // Fall back to the rows already loaded on this page.
        items = _snapshot.where((row) => _matchesPage(row, query)).toList();
        hasMore = false;
      }
      setState(() {
        if (reset) {
          _items
            ..clear()
            ..addAll(items);
        } else {
          _items.addAll(items);
        }
        _hasMore = hasMore;
        _page = result.page + 1;
        _loading = false;
        _loadingMore = false;
        _refreshing = false;
        _error = null;
        _loadMoreError = null;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _refreshing = false;
        if (reset && _items.isEmpty) {
          _error = error;
        } else if (reset) {
          _loadMoreError = error;
        } else {
          _loadMoreError = error;
        }
      });
    }
  }

  void _onScroll() {
    if (!_scroll.hasClients || _loadingMore || !_hasMore) return;
    if (_loadMoreError != null) return;
    if (_scroll.position.maxScrollExtent <= 0) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 240) {
      _load(reset: false);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _load(reset: true);
    });
  }

  void _setFilter(String filter) {
    if (_filter == filter) return;
    setState(() => _filter = filter);
    _load(reset: true);
  }

  bool _matchesPage(AdminUserRow row, String query) {
    final q = query.trim().toLowerCase();
    if (!_matchesFilter(row)) return false;
    if (q.isEmpty) return true;
    final username = row.username.trim().toLowerCase();
    if (row.id.toString() == q) return true;
    if (row.studentId?.toString() == q) return true;
    if (row.teacherId?.toString() == q) return true;
    return username.contains(q) ||
        row.displayName.toLowerCase().contains(q) ||
        row.teamNames.any((team) => team.toLowerCase().contains(q));
  }

  bool _matchesFilter(AdminUserRow row) {
    return switch (_filter) {
      'student' => row.isStudent,
      'teacher' => row.isTeacher,
      'supervisor' => row.isSupervisor,
      _ => true,
    };
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Scaffold(
      appBar: AppBar(title: const Text('الحسابات والصلاحيات')),
      body: ResponsivePage(
        maxWidth: 900,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _search,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'ابحث بالاسم أو اسم المستخدم',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            SizedBox(
              height: 4,
              child: _refreshing
                  ? LinearProgressIndicator(
                      minHeight: 3,
                      color: tokens.brand,
                      backgroundColor: tokens.surfaceSubtle,
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  for (final (key, label) in const [
                    ('all', 'الكل'),
                    ('student', 'الطلاب'),
                    ('teacher', 'المعلمون'),
                    ('supervisor', 'المشرفون'),
                  ])
                    ChoiceChip(
                      label: Text(label),
                      selected: _filter == key,
                      onSelected: (_) => _setFilter(key),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(child: _body(context)),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading && _items.isEmpty) return const AppLoadingView();
    if (_error != null && _items.isEmpty) {
      return AppErrorView(error: _error, onRetry: () => _load(reset: true));
    }
    if (_items.isEmpty) {
      return const EmptyState(
        title: 'لا توجد حسابات',
        icon: Icons.people_outline,
        message: 'جرّب بحثًا آخر أو غيّر التصفية.',
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _items.length + 1,
      itemBuilder: (context, i) {
        if (i >= _items.length) return _footer(context);
        return _userTile(context, _items[i]);
      },
    );
  }

  Widget _footer(BuildContext context) {
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: AppLoadingDots(size: 8, spacing: 6)),
      );
    }
    if (_loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            const Text('تعذر تحميل المزيد'),
            TextButton.icon(
              onPressed: () => _load(reset: false),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }
    if (!_hasMore) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: TextButton.icon(
          onPressed: () => _load(reset: false),
          icon: const Icon(Icons.expand_more, size: 18),
          label: const Text('تحميل المزيد'),
        ),
      ),
    );
  }

  Widget _userTile(BuildContext context, AdminUserRow row) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final kind = row.isAdmin
        ? AdminUserKind.admin
        : row.isTeacher
        ? AdminUserKind.teacher
        : AdminUserKind.student;
    final subtitle = [
      if (row.usernameLabel.isNotEmpty) row.usernameLabel,
      row.roleLabel,
      if (row.teamNames.isNotEmpty) row.teamNames.join(' • '),
    ].join(' • ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        onTap: () => _openDetail(context, row, kind),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: switch (kind) {
                AdminUserKind.admin => tokens.infoTint,
                AdminUserKind.teacher => tokens.accentMatn.withValues(
                  alpha: 0.15,
                ),
                AdminUserKind.student => tokens.brandTint,
              },
              child: Icon(
                switch (kind) {
                  AdminUserKind.admin => Icons.admin_panel_settings,
                  AdminUserKind.teacher => Icons.school,
                  AdminUserKind.student => Icons.person,
                },
                size: 19,
                color: switch (kind) {
                  AdminUserKind.admin => tokens.info,
                  AdminUserKind.teacher => tokens.accentMatn,
                  AdminUserKind.student => tokens.brandText,
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.displayName,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 2,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                  ),
                ],
              ),
            ),
            AdminRoleBadges.fromRow(row),
            if (!row.active) ...[
              const SizedBox(width: 6),
              Text(
                'موقوف',
                style: TextStyle(color: tokens.dangerText, fontSize: 12),
              ),
            ],
            const SizedBox(width: 6),
            Icon(Icons.chevron_left, color: tokens.borderStructural),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetail(
    BuildContext context,
    AdminUserRow row,
    AdminUserKind kind,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AdminUserDetailScreen(
          userId: row.id,
          name: row.displayName,
          kind: kind,
          isTeacher: row.isTeacher,
          teacherId: row.teacherId,
          studentId: row.studentId,
          username: row.username,
          teams: row.teamNames,
        ),
      ),
    );
    if (!mounted) return;
    _load(reset: true);
  }
}
