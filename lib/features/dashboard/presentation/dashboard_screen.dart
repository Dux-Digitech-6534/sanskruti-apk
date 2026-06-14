import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/dashboard_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/dashboard_data.dart';
import '../../../models/purchase_receipt.dart';
import '../../../models/purchase_request_summary.dart';
import '../../../repositories/dashboard_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final displayName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : 'User';
    final dashboard = ref.watch(dashboardDataProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: context.l10n.t('menu'),
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(context.l10n.t('dashboard')),
      ),
      body: dashboard.when(
        loading: () => const _DashboardLoading(),
        error: (error, stackTrace) => _DashboardError(
          message: error.toString(),
          onRetry: () => ref.invalidate(dashboardDataProvider),
        ),
        data: (data) => _DashboardContent(
          data: data,
          displayName: displayName,
          onRefresh: () async => ref.refresh(dashboardDataProvider.future),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.data,
    required this.displayName,
    required this.onRefresh,
  });

  final DashboardData data;
  final String displayName;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            context.l10n.hello(displayName),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: context.l10n.t('overview')),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DashboardCard(
                  title: context.l10n.t('pending_requests'),
                  value: data.pendingRequestsCount.toString(),
                  icon: Icons.assignment_outlined,
                  onTap: () => context.push('/purchase-request?status=pending'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DashboardCard(
                  title: context.l10n.t('pending_po'),
                  value: data.pendingPurchaseOrdersCount.toString(),
                  icon: Icons.description_outlined,
                  tint: AppColors.warning,
                  onTap: () => context.push('/purchase-order?status=pending'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SectionHeader(title: context.l10n.t('quick_actions')),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.05,
            children: [
              _QuickAction(
                icon: Icons.add_box_outlined,
                label: context.l10n.t('create_material_request'),
                route: '/create-purchase-request',
              ),
              _QuickAction(
                icon: Icons.feed_outlined,
                label: context.l10n.t('view_po'),
                route: '/purchase-order',
              ),
              _QuickAction(
                icon: Icons.receipt_long_outlined,
                label: context.l10n.t('create_purchase_receipt'),
                route: '/create-purchase-receipt',
              ),
              _QuickAction(
                icon: Icons.show_chart,
                label: context.l10n.t('stock_report'),
                route: '/stock',
              ),
            ],
          ),
          const SizedBox(height: 20),
          SectionHeader(
            title: context.l10n.t('recent_requests'),
            actionLabel: context.l10n.t('view_all'),
          ),
          const SizedBox(height: 10),
          if (data.recentRequests.isEmpty)
            const _EmptyRecentRequests()
          else
            ...data.recentRequests.map(
              (request) => _RecentRequest(
                request,
                onTap: () => context.go(
                  '/purchase-request-detail/${Uri.encodeComponent(request.name)}',
                ),
              ),
            ),
          const SizedBox(height: 20),
          SectionHeader(
            title: context.l10n.t('recent_receipts'),
            actionLabel: context.l10n.t('view_all'),
          ),
          const SizedBox(height: 10),
          if (data.recentReceipts.isEmpty)
            const _EmptyRecentReceipts()
          else
            ...data.recentReceipts.map(
              (receipt) => _RecentReceipt(
                receipt,
                onTap: () => context.go(
                  '/purchase-receipt-detail/${Uri.encodeComponent(receipt.name)}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        debugPrint('[Dashboard] Quick Action tapped: $label -> $route');
        context.push(route);
      },
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        maxLines: 2,
        softWrap: true,
        overflow: TextOverflow.visible,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _RecentRequest extends StatelessWidget {
  const _RecentRequest(this.request, {required this.onTap});

  final PurchaseRequestSummary request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    request.site,
                    style: const TextStyle(color: AppColors.mutedText),
                  ),
                ],
              ),
            ),
            StatusBadge(label: request.displayStatus),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.mutedText),
          ],
        ),
      ),
    );
  }
}

class _RecentReceipt extends StatelessWidget {
  const _RecentReceipt(this.receipt, {required this.onTap});

  final PurchaseReceipt receipt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receipt.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    receipt.supplier,
                    style: const TextStyle(color: AppColors.mutedText),
                  ),
                ],
              ),
            ),
            StatusBadge(label: receipt.status),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.mutedText),
          ],
        ),
      ),
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, color: AppColors.mutedText),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: Text(context.l10n.t('retry')),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRecentRequests extends StatelessWidget {
  const _EmptyRecentRequests();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        context.l10n.t('no_recent_material_requests_found'),
        style: const TextStyle(color: AppColors.mutedText),
      ),
    );
  }
}

class _EmptyRecentReceipts extends StatelessWidget {
  const _EmptyRecentReceipts();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        context.l10n.t('no_recent_purchase_receipts_found'),
        style: const TextStyle(color: AppColors.mutedText),
      ),
    );
  }
}
