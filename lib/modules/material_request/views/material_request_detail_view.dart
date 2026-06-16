import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/formatters.dart';
import '../../../widgets/app_state_widgets.dart';
import '../../../widgets/responsive_shell.dart';
import '../controllers/material_request_controller.dart';

class MaterialRequestDetailView extends StatefulWidget {
  const MaterialRequestDetailView({super.key});

  @override
  State<MaterialRequestDetailView> createState() =>
      _MaterialRequestDetailViewState();
}

class _MaterialRequestDetailViewState extends State<MaterialRequestDetailView> {
  late final MaterialRequestController controller =
      Get.find<MaterialRequestController>();
  late final String name = Get.arguments?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    if (name.isNotEmpty) {
      controller.loadDetails(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveShell(
      title: 'Material Request Details',
      child: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoader(message: 'Loading document');
        }
        if (controller.error.value.isNotEmpty) {
          return ErrorState(
            message: controller.error.value,
            onRetry: () => controller.loadDetails(name),
          );
        }
        final data = controller.details.value;
        if (data == null) {
          return const EmptyState(
            icon: Icons.assignment_outlined,
            title: 'No document selected',
            message: 'Open a material request from the list.',
          );
        }
        final items = data['items'] as List? ?? const [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name']?.toString() ?? '',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Status: ${data['status'] ?? 'Draft'}'),
                    Text('Project: ${data['project'] ?? '-'}'),
                    Text(
                      'Required By: ${Formatters.dateString(data['schedule_date']?.toString())}',
                    ),
                    Text('Warehouse: ${data['set_warehouse'] ?? '-'}'),
                    if ((data['remarks'] ?? '').toString().isNotEmpty)
                      Text('Remarks: ${data['remarks']}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Items',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (final item in items)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(
                    (item['item_name'] ?? item['item_code'] ?? '').toString(),
                  ),
                  subtitle: Text(
                    'Code: ${item['item_code'] ?? '-'} | Warehouse: ${item['warehouse'] ?? '-'}',
                  ),
                  trailing: Text('${item['qty'] ?? 0} ${item['uom'] ?? ''}'),
                ),
              ),
          ],
        );
      }),
    );
  }
}
