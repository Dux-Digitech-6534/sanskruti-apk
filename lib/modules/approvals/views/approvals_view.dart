import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/app_state_widgets.dart';
import '../../../widgets/document_card.dart';
import '../../../widgets/responsive_shell.dart';
import '../controllers/approvals_controller.dart';

class ApprovalsView extends GetView<ApprovalsController> {
  const ApprovalsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveShell(
      title: 'Approvals',
      child: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoader(message: 'Loading purchase order approvals');
        }
        if (controller.error.value.isNotEmpty) {
          return ErrorState(
            message: controller.error.value,
            onRetry: controller.load,
          );
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.rule_folder_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Purchase Orders above ${Formatters.currency(AppConstants.approvalThreshold)} require approval.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (controller.pendingOrders.isEmpty)
                const SizedBox(
                  height: 420,
                  child: EmptyState(
                    icon: Icons.verified_outlined,
                    title: 'No pending approvals',
                    message:
                        'Eligible purchase orders from ERPNext will appear here.',
                  ),
                )
              else
                for (final order in controller.pendingOrders)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DocumentCard(
                      document: order,
                      icon: Icons.verified_outlined,
                      onTap: () => Get.toNamed(
                        AppRoutes.purchaseOrderApproval,
                        arguments: order.data,
                      ),
                    ),
                  ),
            ],
          ),
        );
      }),
    );
  }
}
