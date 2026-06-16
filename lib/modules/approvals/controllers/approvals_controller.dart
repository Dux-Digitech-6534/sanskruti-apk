import 'package:get/get.dart';

import '../../../core/app_constants.dart';
import '../../../core/models/document_summary.dart';
import '../../../services/api_client.dart';
import '../../../services/document_repository.dart';

class ApprovalsController extends GetxController {
  ApprovalsController(this._apiClient);

  final ApiClient _apiClient;
  late final DocumentRepository _purchaseOrders = DocumentRepository(
    _apiClient,
    'Purchase Order',
  );

  final isLoading = false.obs;
  final isApproving = false.obs;
  final error = ''.obs;
  final pendingOrders = <DocumentSummary>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      pendingOrders.assignAll(
        await _purchaseOrders.list(
          limit: 50,
          extraFilters: [
            ['grand_total', '>', AppConstants.approvalThreshold],
            ['docstatus', '<', 2],
          ],
          fields: const [
            'name',
            'supplier',
            'status',
            'modified',
            'transaction_date',
            'grand_total',
          ],
        ),
      );
    } catch (e) {
      error.value = _apiClient.readableError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approve(String name) async {
    isApproving.value = true;
    try {
      final document = await _purchaseOrders.getByName(name);
      await _purchaseOrders.submitByAction(document, 'Approve');
      Get.snackbar('Approved', '$name submitted in ERPNext.');
      await load();
    } catch (e) {
      Get.snackbar('Approval failed', _apiClient.readableError(e));
    } finally {
      isApproving.value = false;
    }
  }
}
