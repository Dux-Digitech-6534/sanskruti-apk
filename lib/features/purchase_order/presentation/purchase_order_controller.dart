import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../repositories/purchase_order_repository.dart';

final purchaseOrderControllerProvider =
    NotifierProvider<PurchaseOrderController, PurchaseOrderState>(
      PurchaseOrderController.new,
    );

enum PurchaseOrderStatusFilter {
  all('All'),
  pending('Pending'),
  completed('Completed'),
  cancelled('Cancelled');

  const PurchaseOrderStatusFilter(this.label);

  final String label;
}

class PurchaseOrderState {
  const PurchaseOrderState({
    this.items = const [],
    this.search = '',
    this.statusFilter = PurchaseOrderStatusFilter.all,
    this.fromDate,
    this.toDate,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<PurchaseOrderSummary> items;
  final String search;
  final PurchaseOrderStatusFilter statusFilter;
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool isLoading;
  final String? errorMessage;

  List<PurchaseOrderSummary> get visibleItems => items
      .where(_matchesSearch)
      .where(_matchesStatus)
      .where(_matchesDate)
      .toList(growable: false);

  PurchaseOrderState copyWith({
    List<PurchaseOrderSummary>? items,
    String? search,
    PurchaseOrderStatusFilter? statusFilter,
    DateTime? fromDate,
    DateTime? toDate,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool clearFromDate = false,
    bool clearToDate = false,
  }) {
    return PurchaseOrderState(
      items: items ?? this.items,
      search: search ?? this.search,
      statusFilter: statusFilter ?? this.statusFilter,
      fromDate: clearFromDate ? null : fromDate ?? this.fromDate,
      toDate: clearToDate ? null : toDate ?? this.toDate,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  bool _matchesSearch(PurchaseOrderSummary order) {
    final query = search.trim().toLowerCase();
    if (query.isEmpty) return true;
    return [
      order.name,
      order.supplier,
      order.status,
      order.transactionDate ?? '',
    ].any((value) => value.toLowerCase().contains(query));
  }

  bool _matchesStatus(PurchaseOrderSummary order) {
    final status = order.status.trim().toLowerCase();
    return switch (statusFilter) {
      PurchaseOrderStatusFilter.all => true,
      PurchaseOrderStatusFilter.pending =>
        status.isEmpty || !status.contains('completed'),
      PurchaseOrderStatusFilter.completed => status.contains('completed'),
      PurchaseOrderStatusFilter.cancelled =>
        status.contains('cancel') || order.docstatus == 2,
    };
  }

  bool _matchesDate(PurchaseOrderSummary order) {
    if (fromDate == null && toDate == null) return true;
    final parsed = DateTime.tryParse(order.transactionDate ?? '');
    if (parsed == null) return false;
    final day = DateTime(parsed.year, parsed.month, parsed.day);
    if (fromDate != null) {
      final from = DateTime(fromDate!.year, fromDate!.month, fromDate!.day);
      if (day.isBefore(from)) return false;
    }
    if (toDate != null) {
      final to = DateTime(toDate!.year, toDate!.month, toDate!.day);
      if (day.isAfter(to)) return false;
    }
    return true;
  }
}

class PurchaseOrderController extends Notifier<PurchaseOrderState> {
  PurchaseOrderRepository get _repository =>
      ref.read(purchaseOrderRepositoryProvider);

  @override
  PurchaseOrderState build() => const PurchaseOrderState();

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _repository.fetchPurchaseOrders(search: state.search);
      state = state.copyWith(items: items, isLoading: false);
    } on Object catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> setSearch(String value) async {
    state = state.copyWith(search: value);
    await load();
  }

  void setStatusFilter(PurchaseOrderStatusFilter filter) {
    state = state.copyWith(statusFilter: filter);
  }

  void setDateFilter(DateTime? from, DateTime? to) {
    state = state.copyWith(
      fromDate: from,
      toDate: to,
      clearFromDate: from == null,
      clearToDate: to == null,
    );
  }
}
