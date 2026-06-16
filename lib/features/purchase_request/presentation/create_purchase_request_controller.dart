import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/purchase_request_form_models.dart';
import '../../../repositories/purchase_request_repository.dart';

final createPurchaseRequestControllerProvider =
    NotifierProvider<
      CreatePurchaseRequestController,
      CreatePurchaseRequestState
    >(CreatePurchaseRequestController.new);

class CreatePurchaseRequestState {
  const CreatePurchaseRequestState({
    this.projects = const [],
    this.categories = const [],
    this.subCategories = const [],
    this.warehouses = const [],
    this.filteredItems = const [],
    this.items = const [],
    this.materialAttachmentDraft,
    this.selectedProject,
    this.selectedCategory,
    this.selectedSubCategory,
    this.scheduleDate,
    this.priority = 'Medium',
    this.remark = '',
    this.autoWarehouse = '',
    this.isLoading = false,
    this.isLoadingProject = false,
    this.isLoadingSubCategories = false,
    this.isLoadingItems = false,
    this.isUploadingAttachment = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  factory CreatePurchaseRequestState.initial() {
    final today = DateTime.now();
    return CreatePurchaseRequestState(
      scheduleDate: DateTime(today.year, today.month, today.day),
    );
  }

  final List<LookupOption> projects;
  final List<LookupOption> categories;
  final List<LookupOption> subCategories;
  final List<LookupOption> warehouses;
  final List<ItemLookupOption> filteredItems;
  final List<CreatePurchaseRequestItemDraft> items;
  final MaterialRequestAttachmentDraft? materialAttachmentDraft;
  final String? selectedProject;
  final String? selectedCategory;
  final String? selectedSubCategory;
  final DateTime? scheduleDate;
  final String priority;
  final String remark;
  final String autoWarehouse;
  final bool isLoading;
  final bool isLoadingProject;
  final bool isLoadingSubCategories;
  final bool isLoadingItems;
  final bool isUploadingAttachment;
  final bool isSubmitting;
  final String? errorMessage;

  CreatePurchaseRequestState copyWith({
    List<LookupOption>? projects,
    List<LookupOption>? categories,
    List<LookupOption>? subCategories,
    List<LookupOption>? warehouses,
    List<ItemLookupOption>? filteredItems,
    List<CreatePurchaseRequestItemDraft>? items,
    MaterialRequestAttachmentDraft? materialAttachmentDraft,
    String? selectedProject,
    String? selectedCategory,
    String? selectedSubCategory,
    DateTime? scheduleDate,
    String? priority,
    String? remark,
    String? autoWarehouse,
    bool? isLoading,
    bool? isLoadingProject,
    bool? isLoadingSubCategories,
    bool? isLoadingItems,
    bool? isUploadingAttachment,
    bool? isSubmitting,
    String? errorMessage,
    bool clearProject = false,
    bool clearCategory = false,
    bool clearSubCategory = false,
    bool clearMaterialAttachment = false,
    bool clearError = false,
  }) {
    return CreatePurchaseRequestState(
      projects: projects ?? this.projects,
      categories: categories ?? this.categories,
      subCategories: subCategories ?? this.subCategories,
      warehouses: warehouses ?? this.warehouses,
      filteredItems: filteredItems ?? this.filteredItems,
      items: items ?? this.items,
      materialAttachmentDraft: clearMaterialAttachment
          ? null
          : materialAttachmentDraft ?? this.materialAttachmentDraft,
      selectedProject: clearProject
          ? null
          : selectedProject ?? this.selectedProject,
      selectedCategory: clearCategory
          ? null
          : selectedCategory ?? this.selectedCategory,
      selectedSubCategory: clearSubCategory
          ? null
          : selectedSubCategory ?? this.selectedSubCategory,
      scheduleDate: scheduleDate ?? this.scheduleDate,
      priority: priority ?? this.priority,
      remark: remark ?? this.remark,
      autoWarehouse: autoWarehouse ?? this.autoWarehouse,
      isLoading: isLoading ?? this.isLoading,
      isLoadingProject: isLoadingProject ?? this.isLoadingProject,
      isLoadingSubCategories:
          isLoadingSubCategories ?? this.isLoadingSubCategories,
      isLoadingItems: isLoadingItems ?? this.isLoadingItems,
      isUploadingAttachment:
          isUploadingAttachment ?? this.isUploadingAttachment,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class MaterialRequestAttachmentDraft {
  const MaterialRequestAttachmentDraft({
    required this.filePath,
    required this.fileName,
  });

  final String filePath;
  final String fileName;
}

class CreatePurchaseRequestItemDraft {
  const CreatePurchaseRequestItemDraft({
    required this.itemCode,
    required this.itemLabel,
    required this.scheduleDate,
    required this.qty,
    required this.uom,
    required this.conversionFactor,
    required this.specification,
    required this.remark,
  });

  final String itemCode;
  final String itemLabel;
  final DateTime scheduleDate;
  final double qty;
  final String uom;
  final double conversionFactor;
  final String specification;
  final String remark;
}

class CreatePurchaseRequestController
    extends Notifier<CreatePurchaseRequestState> {
  PurchaseRequestRepository get _repository =>
      ref.read(purchaseRequestRepositoryProvider);

  @override
  CreatePurchaseRequestState build() => CreatePurchaseRequestState.initial();

  void reset() {
    state = CreatePurchaseRequestState.initial();
  }

  Future<void> loadLookups() async {
    if (state.isLoading || state.projects.isNotEmpty) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _repository.fetchProjects(),
        _repository.fetchCategories(),
        _repository.fetchWarehouses(),
      ]);
      state = state.copyWith(
        projects: results[0],
        categories: results[1],
        warehouses: results[2],
        isLoading: false,
      );
    } on Object catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> setProject(String? value) async {
    state = state.copyWith(
      selectedProject: value,
      autoWarehouse: '',
      isLoadingProject: value != null,
      clearProject: value == null,
      clearError: true,
    );
    if (value == null || value.isEmpty) return;

    try {
      final project = await _repository.fetchProjectMaster(value);
      state = state.copyWith(
        autoWarehouse: project.storeName,
        isLoadingProject: false,
      );
    } on Object catch (error) {
      state = state.copyWith(
        isLoadingProject: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  void setWarehouse(String? value) {
    state = state.copyWith(autoWarehouse: value ?? '', clearError: true);
  }

  void setScheduleDate(DateTime value) {
    state = state.copyWith(scheduleDate: value, clearError: true);
  }

  void setPriority(String? value) {
    state = state.copyWith(priority: value ?? 'Medium', clearError: true);
  }

  void setRemark(String value) {
    state = state.copyWith(remark: value, clearError: true);
  }

  Future<void> setCategory(String? value) async {
    state = state.copyWith(
      selectedCategory: value,
      subCategories: const [],
      filteredItems: const [],
      items: const [],
      isLoadingSubCategories: value != null,
      isLoadingItems: value != null,
      clearCategory: value == null,
      clearSubCategory: true,
      clearError: true,
    );
    if (value == null || value.isEmpty) return;

    try {
      final subCategories = await _repository.fetchSubCategories(
        category: value,
      );
      final items = await _repository.fetchItemsByCategory(category: value);
      state = state.copyWith(
        subCategories: subCategories,
        filteredItems: items,
        isLoadingSubCategories: false,
        isLoadingItems: false,
      );
    } on Object catch (error) {
      state = state.copyWith(
        isLoadingSubCategories: false,
        isLoadingItems: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> setSubCategory(String? value) async {
    final category = state.selectedCategory;
    state = state.copyWith(
      selectedSubCategory: value,
      filteredItems: const [],
      items: const [],
      isLoadingItems: category != null,
      clearSubCategory: value == null,
      clearError: true,
    );
    if (category == null || category.isEmpty) return;

    try {
      final items = await _repository.fetchItemsByCategory(
        category: category,
        subCategory: value,
      );
      state = state.copyWith(filteredItems: items, isLoadingItems: false);
    } on Object catch (error) {
      state = state.copyWith(
        isLoadingItems: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<ItemRequestDetail> fetchItemDetail(String itemCode) {
    return _repository.fetchItemDetail(itemCode);
  }

  void addItem(CreatePurchaseRequestItemDraft item) {
    state = state.copyWith(items: [...state.items, item], clearError: true);
  }

  void removeItem(int index) {
    final items = [...state.items]..removeAt(index);
    state = state.copyWith(items: items);
  }

  void captureAttachment({required String filePath, required String fileName}) {
    state = state.copyWith(
      materialAttachmentDraft: MaterialRequestAttachmentDraft(
        filePath: filePath,
        fileName: fileName,
      ),
      clearError: true,
    );
  }

  void clearAttachment() {
    state = state.copyWith(clearMaterialAttachment: true, clearError: true);
  }

  Future<MaterialRequestDetail> createAndSave() async {
    final validationError = _validate();
    if (validationError != null) {
      state = state.copyWith(errorMessage: validationError);
      throw validationError;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final createdName = await _repository.createMaterialRequest(
        project: state.selectedProject!,
        warehouse: state.autoWarehouse,
        category: state.selectedCategory!,
        subCategory: state.selectedSubCategory,
        scheduleDate: state.scheduleDate!,
        priority: state.priority,
        remark: state.remark,
        items: state.items
            .map(
              (item) => MaterialRequestItemDraft(
                itemCode: item.itemCode,
                scheduleDate: item.scheduleDate,
                qty: item.qty,
                uom: item.uom,
                conversionFactor: item.conversionFactor,
                specification: item.specification,
                remark: item.remark,
              ),
            )
            .toList(),
      );
      await _uploadCapturedAttachment(createdName);
      final savedDetail = await _repository.fetchMaterialRequestDetail(
        createdName,
      );
      state = CreatePurchaseRequestState.initial();
      return savedDetail;
    } on Object catch (error) {
      final message = error is String ? error : _friendlyError(error);
      state = state.copyWith(isSubmitting: false, errorMessage: message);
      throw message;
    }
  }

  Future<void> _uploadCapturedAttachment(String docName) async {
    final attachment = state.materialAttachmentDraft;
    if (attachment == null) return;

    state = state.copyWith(isUploadingAttachment: true);
    try {
      final uploaded = await _repository.uploadMaterialAttachment(
        filePath: attachment.filePath,
        fileName: attachment.fileName,
        docName: docName,
      );
      await _repository.updateMaterialAttachment(
        name: docName,
        fileUrl: uploaded.fileUrl,
      );
    } finally {
      state = state.copyWith(isUploadingAttachment: false);
    }
  }

  String? _validate() {
    if (state.selectedProject == null || state.selectedProject!.isEmpty) {
      return 'Project is required.';
    }
    if (state.selectedCategory == null || state.selectedCategory!.isEmpty) {
      return 'Category is required.';
    }
    if (state.autoWarehouse.trim().isEmpty) {
      return 'Warehouse is required.';
    }
    if (state.scheduleDate == null) {
      return 'Required date is required';
    }
    if (!const ['Low', 'Medium', 'High'].contains(state.priority)) {
      return 'Priority is required.';
    }
    if (state.items.isEmpty) return 'At least one item is required.';

    for (final item in state.items) {
      if (item.itemCode.isEmpty) return 'Item is required.';
      if (item.qty <= 0) return 'Quantity must be greater than zero.';
      if (item.uom.trim().isEmpty) return '${item.itemCode} UOM is required.';
    }
    return null;
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
