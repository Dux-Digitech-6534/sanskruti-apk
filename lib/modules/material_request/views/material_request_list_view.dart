import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../widgets/app_state_widgets.dart';
import '../../../widgets/document_card.dart';
import '../../../widgets/responsive_shell.dart';
import '../controllers/material_request_controller.dart';

class MaterialRequestListView extends GetView<MaterialRequestController> {
  const MaterialRequestListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveShell(
      title: 'Material Requests',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.materialRequestCreate),
        icon: const Icon(Icons.add),
        label: const Text('New Material Request'),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoader(message: 'Loading material requests');
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
              TextField(
                controller: controller.searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => controller.load(),
                decoration: InputDecoration(
                  hintText: 'Search material request',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: controller.load,
                    icon: const Icon(Icons.tune),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (controller.documents.isEmpty)
                const SizedBox(
                  height: 420,
                  child: EmptyState(
                    icon: Icons.assignment_outlined,
                    title: 'No material requests found',
                    message:
                        'Create the first request to start the procurement workflow.',
                  ),
                )
              else
                for (final document in controller.documents)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DocumentCard(
                      document: document,
                      icon: Icons.assignment_outlined,
                      onTap: () => Get.toNamed(
                        AppRoutes.materialRequestDetails,
                        arguments: document.name,
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
