import 'package:get/get.dart';

import '../../../services/api_client.dart';
import '../controllers/material_request_controller.dart';
import '../repositories/material_request_repository.dart';

class MaterialRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => MaterialRequestRepository(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut(
      () => MaterialRequestController(
        Get.find<MaterialRequestRepository>(),
        Get.find<ApiClient>(),
      ),
      fenix: true,
    );
  }
}
