import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../repositories/stock_repository.dart';

final stockControllerProvider = NotifierProvider<StockController, StockState>(
  StockController.new,
);

class StockState {
  const StockState({
    this.items = const [],
    this.search = '',
    this.isLoading = false,
    this.errorMessage,
  });

  final List<StockBin> items;
  final String search;
  final bool isLoading;
  final String? errorMessage;

  List<StockBin> get visibleItems {
    final query = search.trim().toLowerCase();
    if (query.isEmpty) return items;
    return items
        .where(
          (item) =>
              item.itemCode.toLowerCase().contains(query) ||
              item.warehouse.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  StockState copyWith({
    List<StockBin>? items,
    String? search,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StockState(
      items: items ?? this.items,
      search: search ?? this.search,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class StockController extends Notifier<StockState> {
  StockRepository get _repository => ref.read(stockRepositoryProvider);

  @override
  StockState build() => const StockState();

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _repository.fetchStockBins();
      state = state.copyWith(items: items, isLoading: false);
    } on Object catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void setSearch(String value) {
    state = state.copyWith(search: value);
  }

  Future<void> clearSearchAndRefresh() async {
    state = state.copyWith(search: '');
    await load();
  }
}
