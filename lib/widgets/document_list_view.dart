import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/procurement_document_controller.dart';
import 'app_state_widgets.dart';
import 'document_card.dart';
import 'responsive_shell.dart';

class ProcurementDocumentListView<T extends ProcurementDocumentController>
    extends GetView<T> {
  const ProcurementDocumentListView({
    super.key,
    required this.title,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.icon,
    required this.detailsRoute,
  });

  final String title;
  final String emptyTitle;
  final String emptyMessage;
  final IconData icon;
  final String detailsRoute;

  @override
  Widget build(BuildContext context) {
    return ResponsiveShell(
      title: title,
      child: Obx(() {
        if (controller.isLoading.value) {
          return AppLoader(message: 'Loading $title');
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
                  hintText: 'Search ${title.toLowerCase()}',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    tooltip: 'Search',
                    onPressed: controller.load,
                    icon: const Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (controller.documents.isEmpty)
                SizedBox(
                  height: 420,
                  child: EmptyState(
                    icon: icon,
                    title: emptyTitle,
                    message: emptyMessage,
                  ),
                )
              else
                for (final document in controller.documents)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DocumentCard(
                      document: document,
                      icon: icon,
                      onTap: () =>
                          Get.toNamed(detailsRoute, arguments: document.name),
                    ),
                  ),
            ],
          ),
        );
      }),
    );
  }
}
