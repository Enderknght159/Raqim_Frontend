import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/responsive_grid.dart';
import '../../../../core/widgets/empty_state.dart';
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
  late Future<List<AdminChangeRequest>> _future;

  @override
  void initState() {
    super.initState();
    _future = AdminRepositoryScope.of(context).changeRequests();
  }

  void _reload() {
    setState(() {
      _future = AdminRepositoryScope.of(context).changeRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلبات التغيير')),
      body: AsyncView<List<AdminChangeRequest>>(
        future: _future,
        cacheKey: 'admin-change-requests',
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
              '${request.fieldLabel}: ${request.currentValue ?? '—'} → ${request.requestedValue}',
              style: Theme.of(context).textTheme.bodyMedium,
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
