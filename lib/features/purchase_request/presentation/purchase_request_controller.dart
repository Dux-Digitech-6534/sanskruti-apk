import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/purchase_request.dart';
import '../../../repositories/purchase_request_repository.dart';

final purchaseRequestControllerProvider =
    NotifierProvider<PurchaseRequestController, PurchaseRequestListState>(
      PurchaseRequestController.new,
    );

enum PurchaseRequestStatusFilter {
  all('All'),
  pending('Pending'),
  approved('Approved'),
  rejected('Rejected');

  const PurchaseRequestStatusFilter(this.label);

  final String label;
}

class PurchaseRequestListState {
  const PurchaseRequestListState({
    this.items = const [],
    this.search = '',
    this.statusFilter = PurchaseRequestStatusFilter.all,
    this.fromDate,
    this.toDate,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
  });

  final List<PurchaseRequest> items;
  final String search;
  final PurchaseRequestStatusFilter statusFilter;
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;

  List<PurchaseRequest> get visibleItems {
    return items
        .where((request) {
          if (!_matchesSearch(request)) return false;
          return switch (statusFilter) {
            PurchaseRequestStatusFilter.all => true,
            PurchaseRequestStatusFilter.pending => _matchesAny(request, const [
              'pending',
              'draft',
            ]),
            PurchaseRequestStatusFilter.approved => _matchesAny(request, const [
              'approved',
              'ordered',
              'received',
              'issued',
              'transferred',
            ]),
            PurchaseRequestStatusFilter.rejected => _matchesAny(request, const [
              'rejected',
              'cancelled',
              'stopped',
            ]),
          };
        })
        .where(_matchesDate)
        .toList(growable: false);
  }

  PurchaseRequestListState copyWith({
    List<PurchaseRequest>? items,
    String? search,
    PurchaseRequestStatusFilter? statusFilter,
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
    return PurchaseRequestListState(
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

  bool _matchesAny(PurchaseRequest request, List<String> values) {
    final status = request.status.trim().toLowerCase();
    return values.any((value) => status.contains(value));
  }

  bool _matchesSearch(PurchaseRequest request) {
    final query = search.trim().toLowerCase();
    if (query.isEmpty) return true;
    return [
      request.name,
      request.status,
      request.site,
      request.requiredDate ?? '',
      request.requestType ?? '',
    ].any((value) => value.toLowerCase().contains(query));
  }

  bool _matchesDate(PurchaseRequest request) {
    if (fromDate == null && toDate == null) return true;
    final parsed = DateTime.tryParse(request.requiredDate ?? '');
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

class PurchaseRequestController extends Notifier<PurchaseRequestListState> {
  static const _pageSize = 20;

  PurchaseRequestRepository get _repository =>
      ref.read(purchaseRequestRepositoryProvider);

  @override
  PurchaseRequestListState build() => const PurchaseRequestListState();

  Future<void> loadInitial() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      hasMore: true,
      items: const [],
      clearError: true,
    );

    try {
      final items = await _repository.fetchMaterialRequests(
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
      final items = await _repository.fetchMaterialRequests(
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

  void setStatusFilter(PurchaseRequestStatusFilter filter) {
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
