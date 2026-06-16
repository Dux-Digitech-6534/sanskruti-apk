import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/purchase_request_form_models.dart';
import '../../../repositories/purchase_receipt_repository.dart';
import '../../../repositories/purchase_receipt_tolerance_settings_repository.dart';

final createPurchaseReceiptControllerProvider =
    NotifierProvider<
      CreatePurchaseReceiptController,
      CreatePurchaseReceiptState
    >(CreatePurchaseReceiptController.new);

enum PurchaseReceiptAttachmentType { material, invoice }

class CreatePurchaseReceiptState {
  const CreatePurchaseReceiptState({
    this.suppliers = const [],
    this.poItemSelections = const [],
    this.receiptItems = const [],
    this.selectedSupplier,
    this.selectedPoItem,
    this.selectedPurchaseOrder,
    this.supplierFields = const PurchaseReceiptSupplierFields(
      supplierName: '',
      supplierAddress: '',
      addressDisplay: '',
      contactPerson: '',
      contactDisplay: '',
      contactMobile: '',
      contactEmail: '',
    ),
    this.supplierDeliveryNote = '',
    this.materialAttachmentDraft,
    this.invoiceAttachmentDraft,
    this.savedName,
    this.isSaved = false,
    this.isSubmitted = false,
    this.isLoadingLookups = false,
    this.isFetchingPoItems = false,
    this.isFetchingDetails = false,
    this.isUploadingMaterial = false,
    this.isUploadingInvoice = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final List<LookupOption> suppliers;
  final List<PurchaseOrderItemSelection> poItemSelections;
  final List<ReceiptDraftItem> receiptItems;
  final String? selectedSupplier;
  final PurchaseOrderItemSelection? selectedPoItem;
  final PendingPurchaseOrder? selectedPurchaseOrder;
  final PurchaseReceiptSupplierFields supplierFields;
  final String supplierDeliveryNote;
  final ReceiptAttachmentDraft? materialAttachmentDraft;
  final ReceiptAttachmentDraft? invoiceAttachmentDraft;
  final String? savedName;
  final bool isSaved;
  final bool isSubmitted;
  final bool isLoadingLookups;
  final bool isFetchingPoItems;
  final bool isFetchingDetails;
  final bool isUploadingMaterial;
  final bool isUploadingInvoice;
  final bool isSubmitting;
  final String? errorMessage;

  bool get hasReceiptItems => receiptItems.isNotEmpty;
  bool get isUploadingAttachment => isUploadingMaterial || isUploadingInvoice;

  CreatePurchaseReceiptState copyWith({
    List<LookupOption>? suppliers,
    List<PurchaseOrderItemSelection>? poItemSelections,
    List<ReceiptDraftItem>? receiptItems,
    String? selectedSupplier,
    PurchaseOrderItemSelection? selectedPoItem,
    PendingPurchaseOrder? selectedPurchaseOrder,
    PurchaseReceiptSupplierFields? supplierFields,
    String? supplierDeliveryNote,
    ReceiptAttachmentDraft? materialAttachmentDraft,
    ReceiptAttachmentDraft? invoiceAttachmentDraft,
    String? savedName,
    bool? isSaved,
    bool? isSubmitted,
    bool? isLoadingLookups,
    bool? isFetchingPoItems,
    bool? isFetchingDetails,
    bool? isUploadingMaterial,
    bool? isUploadingInvoice,
    bool? isSubmitting,
    String? errorMessage,
    bool clearSupplier = false,
    bool clearPoItem = false,
    bool clearPurchaseOrder = false,
    bool clearMaterialAttachment = false,
    bool clearInvoiceAttachment = false,
    bool clearError = false,
  }) {
    return CreatePurchaseReceiptState(
      suppliers: suppliers ?? this.suppliers,
      poItemSelections: poItemSelections ?? this.poItemSelections,
      receiptItems: receiptItems ?? this.receiptItems,
      selectedSupplier: clearSupplier
          ? null
          : selectedSupplier ?? this.selectedSupplier,
      selectedPoItem: clearPoItem
          ? null
          : selectedPoItem ?? this.selectedPoItem,
      selectedPurchaseOrder: clearPurchaseOrder
          ? null
          : selectedPurchaseOrder ?? this.selectedPurchaseOrder,
      supplierFields: clearPurchaseOrder
          ? PurchaseReceiptSupplierFields.empty()
          : supplierFields ?? this.supplierFields,
      supplierDeliveryNote: supplierDeliveryNote ?? this.supplierDeliveryNote,
      materialAttachmentDraft: clearMaterialAttachment
          ? null
          : materialAttachmentDraft ?? this.materialAttachmentDraft,
      invoiceAttachmentDraft: clearInvoiceAttachment
          ? null
          : invoiceAttachmentDraft ?? this.invoiceAttachmentDraft,
      savedName: savedName ?? this.savedName,
      isSaved: isSaved ?? this.isSaved,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isLoadingLookups: isLoadingLookups ?? this.isLoadingLookups,
      isFetchingPoItems: isFetchingPoItems ?? this.isFetchingPoItems,
      isFetchingDetails: isFetchingDetails ?? this.isFetchingDetails,
      isUploadingMaterial: isUploadingMaterial ?? this.isUploadingMaterial,
      isUploadingInvoice: isUploadingInvoice ?? this.isUploadingInvoice,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ReceiptAttachmentDraft {
  const ReceiptAttachmentDraft({
    required this.filePath,
    required this.fileName,
    required this.capturedAt,
  });

  final String filePath;
  final String fileName;
  final DateTime capturedAt;
}

class ReceiptDraftItem {
  const ReceiptDraftItem({
    required this.itemCode,
    required this.itemName,
    required this.uom,
    required this.orderedQty,
    required this.receivedQty,
    required this.pendingQty,
    required this.receiveQty,
    required this.warehouse,
    required this.purchaseOrderItem,
    required this.rate,
    required this.tolerancePercentage,
    required this.remark,
  });

  final String itemCode;
  final String itemName;
  final String uom;
  final double orderedQty;
  final double receivedQty;
  final double pendingQty;
  final double receiveQty;
  final String warehouse;
  final String purchaseOrderItem;
  final double rate;
  final double tolerancePercentage;
  final String remark;

  double get maxAllowedReceivedQty {
    return orderedQty + (orderedQty * tolerancePercentage / 100);
  }

  double get maxReceiveQty {
    final allowed = maxAllowedReceivedQty - receivedQty;
    return allowed > 0 ? allowed : 0;
  }

  ReceiptDraftItem copyWith({double? receiveQty, String? remark}) {
    return ReceiptDraftItem(
      itemCode: itemCode,
      itemName: itemName,
      uom: uom,
      orderedQty: orderedQty,
      receivedQty: receivedQty,
      pendingQty: pendingQty,
      receiveQty: receiveQty ?? this.receiveQty,
      warehouse: warehouse,
      purchaseOrderItem: purchaseOrderItem,
      rate: rate,
      tolerancePercentage: tolerancePercentage,
      remark: remark ?? this.remark,
    );
  }

  factory ReceiptDraftItem.fromPoItem(
    PurchaseOrderReceiptItem item,
    PurchaseReceiptToleranceRule toleranceRule,
  ) {
    return ReceiptDraftItem(
      itemCode: item.itemCode,
      itemName: item.itemName,
      uom: item.uom,
      orderedQty: item.qty,
      receivedQty: item.receivedQty,
      pendingQty: item.pendingQty,
      receiveQty: item.pendingQty,
      warehouse: item.warehouse,
      purchaseOrderItem: item.rowName,
      rate: item.rate,
      tolerancePercentage: toleranceRule.percentageFor(item.itemCode),
      remark: item.remark,
    );
  }
}

class CreatePurchaseReceiptController
    extends Notifier<CreatePurchaseReceiptState> {
  PurchaseReceiptRepository get _repository =>
      ref.read(purchaseReceiptRepositoryProvider);

  @override
  CreatePurchaseReceiptState build() => const CreatePurchaseReceiptState();

  void reset() {
    state = const CreatePurchaseReceiptState();
  }

  Future<void> loadLookups() async {
    if (state.isLoadingLookups || state.suppliers.isNotEmpty) return;
    state = state.copyWith(isLoadingLookups: true, clearError: true);
    try {
      final suppliers = await _repository.fetchSuppliers();
      state = state.copyWith(suppliers: suppliers, isLoadingLookups: false);
    } on Object catch (error) {
      state = state.copyWith(
        isLoadingLookups: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  void setSupplier(String? value) {
    state = state.copyWith(
      selectedSupplier: value,
      poItemSelections: const [],
      receiptItems: const [],
      clearSupplier: value == null,
      clearPoItem: true,
      clearPurchaseOrder: true,
      clearError: true,
    );
  }

  void setSupplierDeliveryNote(String value) {
    state = state.copyWith(supplierDeliveryNote: value, clearError: true);
  }

  Future<bool> fetchPurchaseOrderItemSelections() async {
    final supplier = state.selectedSupplier?.trim() ?? '';
    if (supplier.isEmpty) {
      state = state.copyWith(errorMessage: 'Supplier is required.');
      return false;
    }

    state = state.copyWith(isFetchingPoItems: true, clearError: true);
    try {
      final rows = await _repository.fetchPurchaseOrderItemSelections(
        supplier: supplier,
      );
      state = state.copyWith(
        poItemSelections: rows,
        isFetchingPoItems: false,
        clearPoItem: true,
      );
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        isFetchingPoItems: false,
        errorMessage: _friendlyError(error),
      );
      return false;
    }
  }

  Future<bool> selectPurchaseOrderItem(PurchaseOrderItemSelection row) async {
    state = state.copyWith(
      selectedPoItem: row,
      selectedPurchaseOrder: PendingPurchaseOrder(
        name: row.purchaseOrder,
        supplier: state.selectedSupplier ?? '',
        transactionDate: null,
      ),
      receiptItems: const [],
      isFetchingDetails: true,
      clearError: true,
    );

    try {
      final detail = await _repository.fetchPurchaseOrderDetail(
        row.purchaseOrder,
      );
      final toleranceRule = await ref
          .read(purchaseReceiptToleranceSettingsRepositoryProvider)
          .fetchRule();
      final pendingItems = detail.items
          .where((item) => item.pendingQty > 0)
          .map((item) => ReceiptDraftItem.fromPoItem(item, toleranceRule))
          .toList();

      if (pendingItems.isEmpty) {
        state = state.copyWith(
          isFetchingDetails: false,
          errorMessage: 'No pending items found for this Purchase Order.',
        );
        return false;
      }

      state = state.copyWith(
        selectedSupplier: detail.supplier,
        supplierFields: detail.supplierFields,
        selectedPurchaseOrder: PendingPurchaseOrder(
          name: detail.name,
          supplier: detail.supplier,
          transactionDate: detail.transactionDate,
        ),
        receiptItems: pendingItems,
        isFetchingDetails: false,
      );
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        isFetchingDetails: false,
        errorMessage: _friendlyError(error),
      );
      return false;
    }
  }

  void updateReceiveQty(int index, String value) {
    final parsed = double.tryParse(value.trim());
    final nextItems = [...state.receiptItems];
    if (index < 0 || index >= nextItems.length) return;
    nextItems[index] = nextItems[index].copyWith(receiveQty: parsed ?? 0);
    state = state.copyWith(receiptItems: nextItems, clearError: true);
  }

  void updateRemark(int index, String value) {
    final nextItems = [...state.receiptItems];
    if (index < 0 || index >= nextItems.length) return;
    nextItems[index] = nextItems[index].copyWith(remark: value);
    state = state.copyWith(receiptItems: nextItems, clearError: true);
  }

  void removeReceiptItem(int index) {
    if (index < 0 || index >= state.receiptItems.length) return;
    final nextItems = [...state.receiptItems]..removeAt(index);
    state = state.copyWith(receiptItems: nextItems, clearError: true);
  }

  void captureAttachment({
    required PurchaseReceiptAttachmentType type,
    required String filePath,
    required String fileName,
  }) {
    final draft = ReceiptAttachmentDraft(
      filePath: filePath,
      fileName: fileName,
      capturedAt: DateTime.now(),
    );
    state = type == PurchaseReceiptAttachmentType.material
        ? state.copyWith(materialAttachmentDraft: draft, clearError: true)
        : state.copyWith(invoiceAttachmentDraft: draft, clearError: true);
  }

  Future<String> createAndSubmit() async {
    if (state.isSubmitted && state.savedName != null) return state.savedName!;
    final validation = _submitValidation();
    if (validation != null) {
      state = state.copyWith(errorMessage: validation);
      throw validation;
    }

    final po = state.selectedPurchaseOrder!;
    await _validateCurrentPendingQuantities(po.name);
    final items = state.receiptItems
        .where((item) => item.receiveQty > 0)
        .map(
          (item) => PurchaseReceiptSubmitItem(
            itemCode: item.itemCode,
            qty: item.receiveQty,
            warehouse: item.warehouse,
            purchaseOrderItem: item.purchaseOrderItem,
            rate: item.rate,
            remark: item.remark,
          ),
        )
        .toList();

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final receiptName = await _repository
          .createPurchaseReceiptFromPurchaseOrder(
            supplier: state.selectedSupplier!,
            postingDate: DateTime.now(),
            purchaseOrder: po.name,
            supplierDeliveryNote: state.supplierDeliveryNote,
            supplierFields: state.supplierFields,
            items: items,
          );
      await _uploadCapturedAttachments(receiptName);
      state = state.copyWith(savedName: receiptName, isSaved: true);
      await _repository.submitPurchaseReceipt(receiptName);
      state = state.copyWith(isSubmitting: false, isSubmitted: true);
      return receiptName;
    } on Object catch (error) {
      final message = error is String ? error : _friendlyError(error);
      state = state.copyWith(isSubmitting: false, errorMessage: message);
      throw message;
    }
  }

  Future<void> _uploadCapturedAttachments(String docName) async {
    final material = state.materialAttachmentDraft;
    final invoice = state.invoiceAttachmentDraft;
    if (material != null) {
      state = state.copyWith(isUploadingMaterial: true);
      try {
        final uploaded = await _repository.uploadAttachment(
          filePath: material.filePath,
          fileName: material.fileName,
          docName: docName,
        );
        await _repository.updateAttachmentFields(
          name: docName,
          materialReceiptUrl: uploaded.fileUrl,
          materialReceiptCapturedAt: material.capturedAt,
        );
      } finally {
        state = state.copyWith(isUploadingMaterial: false);
      }
    }
    if (invoice != null) {
      state = state.copyWith(isUploadingInvoice: true);
      try {
        final uploaded = await _repository.uploadAttachment(
          filePath: invoice.filePath,
          fileName: invoice.fileName,
          docName: docName,
        );
        await _repository.updateAttachmentFields(
          name: docName,
          invoiceReceiptUrl: uploaded.fileUrl,
          invoiceReceiptCapturedAt: invoice.capturedAt,
        );
      } finally {
        state = state.copyWith(isUploadingInvoice: false);
      }
    }
  }

  String? _submitValidation() {
    if (state.selectedPurchaseOrder == null) {
      return 'Purchase Order is required.';
    }
    if (state.selectedSupplier == null || state.selectedSupplier!.isEmpty) {
      return 'Supplier is required.';
    }
    if (state.receiptItems.isEmpty) {
      return 'No pending Purchase Order items to receive.';
    }
    final receivableItems = state.receiptItems.where(
      (item) => item.receiveQty > 0,
    );
    if (receivableItems.isEmpty) {
      return 'Enter receive quantity for at least one item.';
    }
    for (final item in receivableItems) {
      if (item.receiveQty > item.maxReceiveQty) {
        return _toleranceMessage(item);
      }
      if (item.warehouse.isEmpty) {
        return '${item.itemCode} warehouse is required.';
      }
    }
    return null;
  }

  Future<void> _validateCurrentPendingQuantities(String purchaseOrder) async {
    final detail = await _repository.fetchPurchaseOrderDetail(purchaseOrder);
    final pendingByRow = <String, PurchaseOrderReceiptItem>{};
    final pendingByCode = <String, PurchaseOrderReceiptItem>{};
    for (final item in detail.items.where((item) => item.pendingQty > 0)) {
      if (item.rowName.isNotEmpty) pendingByRow[item.rowName] = item;
      pendingByCode.putIfAbsent(item.itemCode, () => item);
    }

    if (pendingByRow.isEmpty && pendingByCode.isEmpty) {
      const message =
          'This Purchase Order is fully received and cannot be received again.';
      state = state.copyWith(errorMessage: message);
      throw message;
    }

    for (final item in state.receiptItems.where(
      (item) => item.receiveQty > 0,
    )) {
      final current = item.purchaseOrderItem.isNotEmpty
          ? pendingByRow[item.purchaseOrderItem]
          : pendingByCode[item.itemCode];
      if (current == null || current.pendingQty <= 0) {
        final message = '${item.itemCode} is fully received.';
        state = state.copyWith(errorMessage: message);
        throw message;
      }
      final maxReceiveQty =
          current.qty * (1 + item.tolerancePercentage / 100) -
          current.receivedQty;
      if (item.receiveQty > maxReceiveQty) {
        final message = _toleranceMessage(item, currentMax: maxReceiveQty);
        state = state.copyWith(errorMessage: message);
        throw message;
      }
    }
  }

  String _toleranceMessage(ReceiptDraftItem item, {double? currentMax}) {
    final maxQty = currentMax ?? item.maxReceiveQty;
    return '${item.itemCode} receive qty cannot exceed allowed tolerance qty ${_formatQty(maxQty)}.';
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

String _formatQty(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2);
}
