import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/blueprint_background.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/dashboard_card.dart';
import '../../../core/widgets/list_filter_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../../repositories/purchase_order_repository.dart';
import 'purchase_order_controller.dart';

class PurchaseOrderListScreen extends ConsumerStatefulWidget {
  const PurchaseOrderListScreen({this.initialPendingOnly = false, super.key});

  final bool initialPendingOnly;

  @override
  ConsumerState<PurchaseOrderListScreen> createState() =>
      _PurchaseOrderListScreenState();
}

class _PurchaseOrderListScreenState
    extends ConsumerState<PurchaseOrderListScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final controller = ref.read(purchaseOrderControllerProvider.notifier);
      _searchController.clear();
      controller.setStatusFilter(
        widget.initialPendingOnly
            ? PurchaseOrderStatusFilter.approvalPending
            : PurchaseOrderStatusFilter.all,
      );
      await controller.clearSearchAndRefresh();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      ref.read(purchaseOrderControllerProvider.notifier).setSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(purchaseOrderControllerProvider);
    final controller = ref.read(purchaseOrderControllerProvider.notifier);
    final visibleItems = state.visibleItems;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: CustomAppBar(
        title: context.l10n.t('purchase_orders'),
        showMenuButton: true,
      ),
      body: BlueprintBackground(
        child: RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: DashboardCard(
                      title: context.l10n.t('loaded_po'),
                      value: state.items.length.toString(),
                      icon: Icons.description_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DashboardCard(
                      title: context.l10n.t('filtered'),
                      value: visibleItems.length.toString(),
                      icon: Icons.filter_alt_outlined,
                      tint: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: AppTextField(
                      controller: _searchController,
                      hintText: context.l10n.t('search_purchase_orders'),
                      prefixIcon: Icons.search,
                      textInputAction: TextInputAction.search,
                      onChanged: _onSearchChanged,
                      onFieldSubmitted: controller.setSearch,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ListFilterButton(
                      label: context.l10n.t('order_date'),
                      fromDate: state.fromDate,
                      toDate: state.toDate,
                      onChanged: controller.setDateFilter,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _StatusTabs(
                selected: state.statusFilter,
                onChanged: controller.setStatusFilter,
              ),
              const SizedBox(height: 16),
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.errorMessage != null)
                _MessageState(
                  message: state.errorMessage!,
                  onRetry: controller.load,
                )
              else if (visibleItems.isEmpty)
                _MessageState(
                  message: context.l10n.t('no_purchase_orders_found'),
                  onRetry: controller.load,
                )
              else
                ...visibleItems.map(
                  (order) => _PurchaseOrderCard(
                    order,
                    statusFilter: state.statusFilter,
                    onTap: () async {
                      await context.push(
                        '/purchase-order-detail/${Uri.encodeComponent(order.name)}',
                      );
                      if (!context.mounted) return;
                      _searchController.clear();
                      await ref
                          .read(purchaseOrderControllerProvider.notifier)
                          .clearSearchAndRefresh();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusTabs extends StatelessWidget {
  const _StatusTabs({required this.selected, required this.onChanged});

  final PurchaseOrderStatusFilter selected;
  final ValueChanged<PurchaseOrderStatusFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final filter = PurchaseOrderStatusFilter.values[index];
          final isSelected = filter == selected;
          return ChoiceChip(
            label: Text(context.l10n.t(_filterLabelKey(filter))),
            selected: isSelected,
            showCheckmark: false,
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
            onSelected: (_) => onChanged(filter),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemCount: PurchaseOrderStatusFilter.values.length,
      ),
    );
  }

  String _filterLabelKey(PurchaseOrderStatusFilter filter) {
    return switch (filter) {
      PurchaseOrderStatusFilter.all => 'all',
      PurchaseOrderStatusFilter.approvalPending => 'approval_pending',
      PurchaseOrderStatusFilter.approved => 'approved',
    };
  }
}

class _PurchaseOrderCard extends StatelessWidget {
  const _PurchaseOrderCard(
    this.order, {
    required this.statusFilter,
    required this.onTap,
  });

  final PurchaseOrderSummary order;
  final PurchaseOrderStatusFilter statusFilter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displayStatus = _poDisplayStatus(order, statusFilter);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: .05),
              offset: const Offset(0, 12),
              blurRadius: 24,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.assignment_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.name,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${context.l10n.t('supplier')}: ${order.supplier}',
                    style: const TextStyle(color: AppColors.mutedText),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _MetaText(
                        icon: Icons.calendar_today_outlined,
                        value: Formatters.dateString(order.transactionDate),
                      ),
                      if (order.grandTotal > 0)
                        _MetaText(
                          icon: Icons.currency_rupee,
                          value: Formatters.currency(order.grandTotal),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            StatusBadge(label: displayStatus),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.mutedText),
          ],
        ),
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.mutedText),
        const SizedBox(width: 5),
        Text(value, style: const TextStyle(color: AppColors.mutedText)),
      ],
    );
  }
}

String _poDisplayStatus(
  PurchaseOrderSummary order,
  PurchaseOrderStatusFilter statusFilter,
) {
  final status = order.status.trim().toLowerCase();
  if (order.docstatus == 0 || status.contains('draft')) return 'Draft';
  if (status == 'pending') return 'Pending';
  if (order.docstatus == 2 || status.contains('cancel')) return 'Cancelled';
  if (statusFilter == PurchaseOrderStatusFilter.approved ||
      _isApprovedPurchaseOrderDisplayStatus(status)) {
    return 'Approved';
  }
  final trimmed = order.status.trim();
  if (trimmed.isNotEmpty) return trimmed;
  return order.docstatus == 1 ? 'Approved' : 'Pending';
}

bool _isApprovedPurchaseOrderDisplayStatus(String status) {
  return status == 'to bill' ||
      status == 'to receive and bill' ||
      status == 'to receive' ||
      status == 'completed';
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Column(
        children: [
          Text(context.l10n.message(message), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: Text(context.l10n.t('retry'))),
        ],
      ),
    );
  }
}
