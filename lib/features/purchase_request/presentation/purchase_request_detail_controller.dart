import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../repositories/purchase_request_repository.dart';

final purchaseRequestDetailControllerProvider =
    NotifierProvider.family<
      PurchaseRequestDetailController,
      PurchaseRequestDetailState,
      String
    >((name) => PurchaseRequestDetailController(name));

class PurchaseRequestDetailState {
  const PurchaseRequestDetailState({
    this.detail,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final MaterialRequestDetail? detail;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  PurchaseRequestDetailState copyWith({
    MaterialRequestDetail? detail,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PurchaseRequestDetailState(
      detail: detail ?? this.detail,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class PurchaseRequestDetailController
    extends Notifier<PurchaseRequestDetailState> {
  PurchaseRequestDetailController(this.name);

  final String name;

  PurchaseRequestRepository get _repository =>
      ref.read(purchaseRequestRepositoryProvider);

  @override
  PurchaseRequestDetailState build() => const PurchaseRequestDetailState();

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final detail = await _repository.fetchMaterialRequestDetail(name);
      state = state.copyWith(detail: detail, isLoading: false);
    } on Object catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> submit() async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repository.submitMaterialRequest(name);
      final detail = await _repository.fetchMaterialRequestDetail(name);
      state = state.copyWith(detail: detail, isSubmitting: false);
    } on Object catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }
}
