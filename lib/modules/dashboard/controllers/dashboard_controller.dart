import 'package:get/get.dart';

import '../../../core/models/document_summary.dart';
import '../../../services/api_client.dart';
import '../../../services/document_repository.dart';

class DashboardController extends GetxController {
  DashboardController(this._apiClient);

  final ApiClient _apiClient;
  final isLoading = false.obs;
  final error = ''.obs;
  final materialRequests = <DocumentSummary>[].obs;
  final purchaseOrders = <DocumentSummary>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      materialRequests.assignAll(
        await DocumentRepository(_apiClient, 'Material Request').list(limit: 5),
      );
      purchaseOrders.assignAll(
        await DocumentRepository(_apiClient, 'Purchase Order').list(limit: 5),
      );
    } catch (e) {
      error.value = _apiClient.readableError(e);
    } finally {
      isLoading.value = false;
    }
  }
}
