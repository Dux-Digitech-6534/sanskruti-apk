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
import '../../../models/purchase_receipt.dart';
import 'purchase_receipt_controller.dart';

class PurchaseReceiptListScreen extends ConsumerStatefulWidget {
  const PurchaseReceiptListScreen({super.key});

  @override
  ConsumerState<PurchaseReceiptListScreen> createState() =>
      _PurchaseReceiptListScreenState();
}

class _PurchaseReceiptListScreenState
    extends ConsumerState<PurchaseReceiptListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(
      () => ref.read(purchaseReceiptControllerProvider.notifier).loadInitial(),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 220) {
      ref.read(purchaseReceiptControllerProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      ref.read(purchaseReceiptControllerProvider.notifier).setSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(purchaseReceiptControllerProvider);
    final controller = ref.read(purchaseReceiptControllerProvider.notifier);
    final visibleItems = state.visibleItems;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: CustomAppBar(
        title: context.l10n.t('purchase_receipts'),
        showMenuButton: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () async {
          final created = await context.push<bool>('/create-purchase-receipt');
          if (!context.mounted || created != true) return;
          await controller.loadInitial();
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadInitial,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: DashboardCard(
                    title: context.l10n.t('loaded_receipts'),
                    value: state.items.length.toString(),
                    icon: Icons.receipt_long_outlined,
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
              hintText: context.l10n.t('search_receipts'),
              prefixIcon: Icons.search,
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
              onFieldSubmitted: controller.setSearch,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: ListFilterButton(
                label: context.l10n.t('posting_date'),
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
              const _LoadingList()
            else if (state.errorMessage != null)
              _ErrorState(
                message: state.errorMessage!,
                onRetry: controller.loadInitial,
              )
            else if (visibleItems.isEmpty)
              const _EmptyState()
            else
              ...visibleItems.map(
                (receipt) => _PurchaseReceiptCard(
                  receipt,
                  onTap: () => context.push(
                    '/purchase-receipt-detail/${Uri.encodeComponent(receipt.name)}',
                  ),
                ),
              ),
            if (state.isLoadingMore) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
            if (!state.hasMore && visibleItems.isNotEmpty) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(
                  context.l10n.t('no_more_receipts'),
                  style: const TextStyle(color: AppColors.mutedText),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusTabs extends StatelessWidget {
  const _StatusTabs({required this.selected, required this.onChanged});

  final PurchaseReceiptStatusFilter selected;
  final ValueChanged<PurchaseReceiptStatusFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final filter = PurchaseReceiptStatusFilter.values[index];
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
        itemCount: PurchaseReceiptStatusFilter.values.length,
      ),
    );
  }
}

class _PurchaseReceiptCard extends StatelessWidget {
  const _PurchaseReceiptCard(this.receipt, {required this.onTap});

  final PurchaseReceipt receipt;
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .03),
              offset: const Offset(0, 6),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receipt.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${context.l10n.t('supplier')}: ${receipt.supplier}',
                    style: const TextStyle(color: AppColors.mutedText),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${context.l10n.t('posting_date')}: ${Formatters.dateString(receipt.postingDate)}',
                    style: const TextStyle(color: AppColors.mutedText),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            StatusBadge(label: receipt.status),
          ],
        ),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, color: AppColors.mutedText),
          const SizedBox(height: 12),
          Text(context.l10n.message(message), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: Text(context.l10n.t('retry'))),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        context.l10n.t('no_purchase_receipts_found'),
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.mutedText),
      ),
    );
  }
}
