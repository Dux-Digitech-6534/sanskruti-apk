import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/purchase_receipt.dart';
import '../../../repositories/purchase_receipt_repository.dart';

final purchaseReceiptControllerProvider =
    NotifierProvider<PurchaseReceiptController, PurchaseReceiptListState>(
      PurchaseReceiptController.new,
    );

enum PurchaseReceiptStatusFilter {
  all('All'),
  draft('Draft'),
  completed('Completed'),
  cancelled('Cancelled');

  const PurchaseReceiptStatusFilter(this.label);

  final String label;
}

class PurchaseReceiptListState {
  const PurchaseReceiptListState({
    this.items = const [],
    this.search = '',
    this.statusFilter = PurchaseReceiptStatusFilter.all,
    this.fromDate,
    this.toDate,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
  });

  final List<PurchaseReceipt> items;
  final String search;
  final PurchaseReceiptStatusFilter statusFilter;
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;

  List<PurchaseReceipt> get visibleItems => items
      .where(_matchesSearch)
      .where(_matchesStatus)
      .where(_matchesDate)
      .toList(growable: false);

  PurchaseReceiptListState copyWith({
    List<PurchaseReceipt>? items,
    String? search,
    PurchaseReceiptStatusFilter? statusFilter,
    DateTime? fromDate,
    DateTime? toDate,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
    bool clearFromDate = false,
    bool clearToDate = false,
  }) {
    return PurchaseReceiptListState(
      items: items ?? this.items,
      search: search ?? this.search,
      statusFilter: statusFilter ?? this.statusFilter,
      fromDate: clearFromDate ? null : fromDate ?? this.fromDate,
      toDate: clearToDate ? null : toDate ?? this.toDate,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  bool _matchesSearch(PurchaseReceipt receipt) {
    final query = search.trim().toLowerCase();
    if (query.isEmpty) return true;
    return [
      receipt.name,
      receipt.supplier,
      receipt.status,
      receipt.postingDate ?? '',
      ...receipt.searchTerms,
    ].any((value) => value.toLowerCase().contains(query));
  }

  bool _matchesStatus(PurchaseReceipt receipt) {
    final status = receipt.status.trim().toLowerCase();
    return switch (statusFilter) {
      PurchaseReceiptStatusFilter.all => true,
      PurchaseReceiptStatusFilter.draft =>
        receipt.docstatus == 0 || status.contains('draft'),
      PurchaseReceiptStatusFilter.completed => status.contains('completed'),
      PurchaseReceiptStatusFilter.cancelled =>
        receipt.docstatus == 2 || status.contains('cancelled'),
    };
  }

  bool _matchesDate(PurchaseReceipt receipt) {
    if (fromDate == null && toDate == null) return true;
    final parsed = DateTime.tryParse(receipt.postingDate ?? '');
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

class PurchaseReceiptController extends Notifier<PurchaseReceiptListState> {
  static const _pageSize = 20;

  PurchaseReceiptRepository get _repository =>
      ref.read(purchaseReceiptRepositoryProvider);

  @override
  PurchaseReceiptListState build() => const PurchaseReceiptListState();

  Future<void> loadInitial() async {
    if (state.isLoading) return;
    state = state.copyWith(
      isLoading: true,
      items: const [],
      hasMore: true,
      clearError: true,
    );

    try {
      final items = await _repository.fetchPurchaseReceipts(
        limitStart: 0,
        limitPageLength: _pageSize,
        search: state.search,
      );
      state = state.copyWith(
        items: items,
        isLoading: false,
        hasMore: items.length == _pageSize,
      );
    } on Object catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final items = await _repository.fetchPurchaseReceipts(
        limitStart: state.items.length,
        limitPageLength: _pageSize,
        search: state.search,
      );
      state = state.copyWith(
        items: [...state.items, ...items],
        isLoadingMore: false,
        hasMore: items.length == _pageSize,
      );
    } on Object catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> setSearch(String value) async {
    state = state.copyWith(search: value);
    await loadInitial();
  }

  void setStatusFilter(PurchaseReceiptStatusFilter filter) {
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

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.contains('401') || message.toLowerCase().contains('session')) {
      return 'Your ERPNext session has expired. Please login again.';
    }
    if (message.toLowerCase().contains('timed out')) {
      return 'Connection timed out. Please check your network.';
    }
    return message.replaceFirst('Exception: ', '');
  }
}
