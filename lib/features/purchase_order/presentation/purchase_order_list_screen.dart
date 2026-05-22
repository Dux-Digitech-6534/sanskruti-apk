import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_text_field.dart';
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
  bool _appliedInitialFilter = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final controller = ref.read(purchaseOrderControllerProvider.notifier);
      if (widget.initialPendingOnly && !_appliedInitialFilter) {
        _appliedInitialFilter = true;
        controller.setStatusFilter(PurchaseOrderStatusFilter.pending);
      }
      await controller.load();
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
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          padding: const EdgeInsets.all(16),
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
            AppTextField(
              controller: _searchController,
              hintText: context.l10n.t('search_purchase_orders'),
              prefixIcon: Icons.search,
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
              onFieldSubmitted: controller.setSearch,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: ListFilterButton(
                label: context.l10n.t('order_date'),
                fromDate: state.fromDate,
                toDate: state.toDate,
                onChanged: controller.setDateFilter,
              ),
            ),
            const SizedBox(height: 12),
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
                  onTap: () => context.push(
                    '/purchase-order-detail/${Uri.encodeComponent(order.name)}',
                  ),
                ),
              ),
          ],
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
            label: Text(context.l10n.status(filter.label)),
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
}

class _PurchaseOrderCard extends StatelessWidget {
  const _PurchaseOrderCard(this.order, {required this.onTap});

  final PurchaseOrderSummary order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  Text(
                    '${context.l10n.t('date')}: ${Formatters.dateString(order.transactionDate)}',
                    style: const TextStyle(color: AppColors.mutedText),
                  ),
                  if (order.grandTotal > 0) ...[
                    const SizedBox(height: 5),
                    Text(
                      '${context.l10n.t('total')}: ${Formatters.currency(order.grandTotal)}',
                      style: const TextStyle(color: AppColors.mutedText),
                    ),
                  ],
                ],
              ),
            ),
            StatusBadge(label: order.status),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.mutedText),
          ],
        ),
      ),
    );
  }
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
