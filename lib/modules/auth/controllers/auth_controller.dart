import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../services/api_client.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';

class AuthController extends GetxController {
  AuthController(this._authService, this._storage, this._apiClient);

  final AuthService _authService;
  final StorageService _storage;
  final ApiClient _apiClient;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  Future<void> decideStartRoute() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final hasSession = await _storage.hasSession;
    Get.offAllNamed(hasSession ? AppRoutes.dashboard : AppRoutes.login);
  }

  Future<void> login() async {
    usernameFocusNode.unfocus();
    passwordFocusNode.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    try {
      await _authService.login(
        username: usernameController.text.trim(),
        password: passwordController.text,
      );
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (error) {
      Get.snackbar(
        'Login failed',
        _apiClient.readableError(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  // App-lifetime controller: login fields are reused across splash/login/logout
  // route transitions, so their TextEditingControllers are intentionally kept.
}
