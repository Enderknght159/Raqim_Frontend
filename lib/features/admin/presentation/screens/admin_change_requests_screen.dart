import 'package:flutter/material.dart';

import '../../../../core/state/section_loader.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/responsive_grid.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../domain/admin_models.dart';
import '../admin_shell.dart';

/// E14 — Change requests: approve/reject student edit requests.
class AdminChangeRequestsScreen extends StatefulWidget {
  const AdminChangeRequestsScreen({super.key});

  @override
  State<AdminChangeRequestsScreen> createState() =>
      _AdminChangeRequestsScreenState();
}

class _AdminChangeRequestsScreenState extends State<AdminChangeRequestsScreen> {
  /// Bumped after every approve/reject so the list refetches.
  int _revision = 0;

  void _reload() {
    if (!mounted) return;
    setState(() => _revision++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلبات التغيير')),
      body: AsyncSection<List<AdminChangeRequest>>(
        cacheKey: 'admin-change-requests',
        revision: _revision,
        skeleton: const _RequestsSkeleton(),
        errorBuilder: (context, retry) => Padding(
          padding: const EdgeInsets.all(16),
          child: SectionError(
            onRetry: retry,
            message: 'تعذر تحميل طلبات التغيير',
          ),
        ),
        load: () => AdminRepositoryScope.of(context).changeRequests(),
        builder: (context, requests) {
          if (requests.isEmpty) {
            return const EmptyState(
              title: 'لا طلبات',
              icon: Icons.rule_folder_outlined,
              message: 'لا توجد طلبات تعديل حالياً',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ResponsiveGrid(
                minItemWidth: 360,
                maxColumns: 2,
                children: [
                  for (final request in requests)
                    _RequestCard(request: request, onResolved: _reload),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RequestsSkeleton extends StatelessWidget {
  const _RequestsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionSkeleton(height: 64, lines: 2),
          SizedBox(height: 10),
          SectionSkeleton(height: 64, lines: 2),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.onResolved});

  final AdminChangeRequest request;
  final VoidCallback onResolved;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.studentName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                StatusBadge(
                  label: _statusLabel(request.status),
                  color: switch (request.status) {
                    'approved' => tokens.brand,
                    'rejected' => tokens.danger,
                    _ => tokens.reward,
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              request.fieldLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: tokens.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Flexible(
                  child: Text(
                    request.currentValue ?? '—',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: tokens.textMuted,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.arrow_back,
                    size: 16,
                    color: tokens.textMuted,
                  ),
                ),
                Flexible(
                  child: Text(
                    request.requestedValue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              formatDate(request.createdAt),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
            ),
            if (request.status == 'pending') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await AdminRepositoryScope.of(
                          context,
                        ).resolveChangeRequest(request.id, approve: true);
                        onResolved();
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('اعتماد'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: tokens.dangerText,
                      ),
                      onPressed: () async {
                        await AdminRepositoryScope.of(
                          context,
                        ).resolveChangeRequest(request.id, approve: false);
                        onResolved();
                      },
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('رفض'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statusLabel(String status) => switch (status) {
    'approved' => 'مقبول',
    'rejected' => 'مرفوض',
    _ => 'معلّق',
  };
}
