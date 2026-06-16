import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/app_constants.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/erp_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(24),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppTheme.darkBlue,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.construction,
                          color: AppTheme.orange,
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to manage material procurement, approvals, and site receiving.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 28),
                    ErpTextField(
                      controller: controller.usernameController,
                      focusNode: controller.usernameFocusNode,
                      label: 'Email or User ID',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [
                        AutofillHints.username,
                        AutofillHints.email,
                      ],
                      onFieldSubmitted: (_) =>
                          controller.passwordFocusNode.requestFocus(),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'User ID is required'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    ErpTextField(
                      controller: controller.passwordController,
                      focusNode: controller.passwordFocusNode,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      enableSuggestions: false,
                      autocorrect: false,
                      onFieldSubmitted: (_) => controller.login(),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Password is required'
                          : null,
                    ),
                    const SizedBox(height: 22),
                    Obx(
                      () => ElevatedButton.icon(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.login,
                        icon: controller.isLoading.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.login),
                        label: const Text('Sign In'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      AppConstants.backendBaseUrl,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
