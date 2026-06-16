import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/models/document_summary.dart';
import 'api_client.dart';
import 'document_repository.dart';

class ProcurementDocumentController extends GetxController {
  ProcurementDocumentController(this.repository, this.apiClient);

  final DocumentRepository repository;
  final ApiClient apiClient;
  final isLoading = false.obs;
  final error = ''.obs;
  final documents = <DocumentSummary>[].obs;
  final details = Rxn<Map<String, dynamic>>();
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      documents.assignAll(await repository.list(search: searchController.text));
    } catch (e) {
      error.value = apiClient.readableError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDetails(String name) async {
    isLoading.value = true;
    error.value = '';
    try {
      details.value = await repository.getByName(name);
    } catch (e) {
      error.value = apiClient.readableError(e);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
