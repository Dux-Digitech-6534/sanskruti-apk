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
    this.workflowActions = const [],
    this.isLoading = false,
    this.isLoadingWorkflowActions = false,
    this.isSubmitting = false,
    this.workflowActionInProgress,
    this.errorMessage,
    this.workflowErrorMessage,
  });

  final MaterialRequestDetail? detail;
  final List<WorkflowAction> workflowActions;
  final bool isLoading;
  final bool isLoadingWorkflowActions;
  final bool isSubmitting;
  final String? workflowActionInProgress;
  final String? errorMessage;
  final String? workflowErrorMessage;

  PurchaseRequestDetailState copyWith({
    MaterialRequestDetail? detail,
    List<WorkflowAction>? workflowActions,
    bool? isLoading,
    bool? isLoadingWorkflowActions,
    bool? isSubmitting,
    String? workflowActionInProgress,
    String? errorMessage,
    String? workflowErrorMessage,
    bool clearError = false,
    bool clearWorkflowError = false,
    bool clearWorkflowAction = false,
  }) {
    return PurchaseRequestDetailState(
      detail: detail ?? this.detail,
      workflowActions: workflowActions ?? this.workflowActions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingWorkflowActions:
          isLoadingWorkflowActions ?? this.isLoadingWorkflowActions,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      workflowActionInProgress: clearWorkflowAction
          ? null
          : workflowActionInProgress ?? this.workflowActionInProgress,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      workflowErrorMessage: clearWorkflowError
          ? null
          : workflowErrorMessage ?? this.workflowErrorMessage,
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
      await loadWorkflowActions();
    } on Object catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> loadWorkflowActions() async {
    final detail = state.detail;
    if (detail == null) return;
    state = state.copyWith(
      workflowActions: const [],
      isLoadingWorkflowActions: true,
      clearWorkflowError: true,
    );
    try {
      final actions = await _repository.fetchAllowedWorkflowActions(detail);
      state = state.copyWith(
        workflowActions: actions,
        isLoadingWorkflowActions: false,
      );
    } on Object catch (error) {
      state = state.copyWith(
        workflowActions: const [],
        isLoadingWorkflowActions: false,
        workflowErrorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> applyWorkflowAction(
    String action, {
    String? rejectionRemark,
  }) async {
    final detail = state.detail;
    if (detail == null) return;
    state = state.copyWith(
      workflowActionInProgress: action,
      clearError: true,
      clearWorkflowError: true,
    );
    try {
      await _repository.applyWorkflowAction(
        detail: detail,
        action: action,
        rejectionRemark: rejectionRemark,
      );
      final updated = await _repository.fetchMaterialRequestDetail(name);
      state = state.copyWith(detail: updated, clearWorkflowAction: true);
      await loadWorkflowActions();
    } on Object catch (error) {
      state = state.copyWith(
        clearWorkflowAction: true,
        workflowErrorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }
}
