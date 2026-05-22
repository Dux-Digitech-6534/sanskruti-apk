import 'package:get/get.dart';

import '../../../services/api_client.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) {
      Get.put(
        AuthService(Get.find<ApiClient>(), Get.find<StorageService>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.put(
        AuthController(
          Get.find<AuthService>(),
          Get.find<StorageService>(),
          Get.find<ApiClient>(),
        ),
        permanent: true,
      );
    }
  }
}
