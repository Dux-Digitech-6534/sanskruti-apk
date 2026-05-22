import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/document_summary.dart';
import '../../../core/utils/formatters.dart';
import '../../../routes/app_routes.dart';
import '../../../services/api_client.dart';
import '../models/material_request_item.dart';
import '../repositories/material_request_repository.dart';

class MaterialRequestController extends GetxController {
  MaterialRequestController(this._repository, this._apiClient);

  final MaterialRequestRepository _repository;
  final ApiClient _apiClient;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final error = ''.obs;
  final documents = <DocumentSummary>[].obs;
  final details = Rxn<Map<String, dynamic>>();
  final items = <MaterialRequestItem>[MaterialRequestItem()].obs;
  final formKey = GlobalKey<FormState>();

  final searchController = TextEditingController();
  final seriesController = TextEditingController(text: 'MAT-MR-.YYYY.-');
  final departmentController = TextEditingController();
  final purposeController = TextEditingController(text: 'Purchase');
  final transactionDateController = TextEditingController(
    text: Formatters.apiDate(DateTime.now()),
  );
  final projectController = TextEditingController();
  final requiredByController = TextEditingController(
    text: Formatters.apiDate(DateTime.now().add(const Duration(days: 7))),
  );
  final categoryController = TextEditingController();
  final priceListController = TextEditingController();
  final warehouseController = TextEditingController();
  final remarksController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      documents.assignAll(
        await _repository.list(search: searchController.text),
      );
    } catch (e) {
      error.value = _apiClient.readableError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDetails(String name) async {
    isLoading.value = true;
    error.value = '';
    try {
      details.value = await _repository.getByName(name);
    } catch (e) {
      error.value = _apiClient.readableError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void addItem() => items.add(
    MaterialRequestItem(
      warehouse: warehouseController.text,
      requiredBy: requiredByController.text,
    ),
  );

  void removeItem(int index) {
    if (items.length > 1) {
      items.removeAt(index);
    }
  }

  Future<List<Map<String, dynamic>>> searchItems(String query) {
    return _repository.searchLink(
      linkDoctype: 'Item',
      query: query,
      referenceDoctype: 'Material Request Item',
    );
  }

  Future<List<Map<String, dynamic>>> searchWarehouse(String query) {
    return _repository.searchLink(
      linkDoctype: 'Warehouse',
      query: query,
      referenceDoctype: 'Material Request',
    );
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isSaving.value = true;
    try {
      final payload = {
        'naming_series': seriesController.text.trim(),
        'purpose': 'Purchase',
        'material_request_type': purposeController.text.trim().isEmpty
            ? 'Purchase'
            : purposeController.text.trim(),
        'transaction_date': transactionDateController.text.trim(),
        'schedule_date': requiredByController.text.trim(),
        'department': departmentController.text.trim(),
        'custom_select_project_': projectController.text.trim(),
        'material_category': categoryController.text.trim(),
        'buying_price_list': priceListController.text.trim(),
        'set_warehouse': warehouseController.text.trim(),
        'remarks': remarksController.text.trim(),
        'items': items.map((item) => item.toJson()).toList(),
      };
      final created = await _repository.create(payload);
      final name = created['name']?.toString() ?? '';
      if (name.isEmpty) {
        throw Exception('Material Request created but submit failed');
      }
      await _repository.update(name, {'docstatus': 1});
      _resetForm();
      Get.snackbar(
        'Material Request submitted',
        name,
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offNamed(AppRoutes.materialRequestDetails, arguments: name);
    } catch (e) {
      Get.snackbar(
        'Save failed',
        _apiClient.readableError(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  void _resetForm() {
    departmentController.clear();
    projectController.clear();
    categoryController.clear();
    priceListController.clear();
    warehouseController.clear();
    remarksController.clear();
    purposeController.text = 'Purchase';
    transactionDateController.text = Formatters.apiDate(DateTime.now());
    requiredByController.text = Formatters.apiDate(
      DateTime.now().add(const Duration(days: 7)),
    );
    for (final item in items) {
      item.dispose();
    }
    items.assignAll([MaterialRequestItem()]);
  }

  @override
  void onClose() {
    searchController.dispose();
    seriesController.dispose();
    departmentController.dispose();
    purposeController.dispose();
    transactionDateController.dispose();
    projectController.dispose();
    requiredByController.dispose();
    categoryController.dispose();
    priceListController.dispose();
    warehouseController.dispose();
    remarksController.dispose();
    for (final item in items) {
      item.dispose();
    }
    super.onClose();
  }
}
