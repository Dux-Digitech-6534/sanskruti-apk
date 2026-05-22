import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/app_constants.dart';
import '../core/utils/formatters.dart';
import '../routes/app_routes.dart';
import '../services/procurement_document_controller.dart';
import 'app_state_widgets.dart';
import 'responsive_shell.dart';

class ProcurementDocumentDetailView<T extends ProcurementDocumentController>
    extends StatefulWidget {
  const ProcurementDocumentDetailView({
    super.key,
    required this.title,
    required this.icon,
    this.showApprovalAction = false,
  });

  final String title;
  final IconData icon;
  final bool showApprovalAction;

  @override
  State<ProcurementDocumentDetailView<T>> createState() =>
      _ProcurementDocumentDetailViewState<T>();
}

class _ProcurementDocumentDetailViewState<
  T extends ProcurementDocumentController
>
    extends State<ProcurementDocumentDetailView<T>> {
  late final T controller = Get.find<T>();
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
      title: widget.title,
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
          return EmptyState(
            icon: widget.icon,
            title: 'No document selected',
            message: 'Open a document from the list.',
          );
        }
        final total =
            double.tryParse(
              (data['grand_total'] ?? data['total'] ?? 0).toString(),
            ) ??
            0;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(child: Icon(widget.icon)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            data['name']?.toString() ?? '',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _InfoRow(
                      label: 'Status',
                      value: (data['status'] ?? 'Draft').toString(),
                    ),
                    _InfoRow(
                      label: 'Supplier',
                      value: (data['supplier'] ?? '-').toString(),
                    ),
                    _InfoRow(
                      label: 'Project',
                      value: (data['project'] ?? '-').toString(),
                    ),
                    _InfoRow(
                      label: 'Transaction Date',
                      value: Formatters.dateString(
                        (data['transaction_date'] ?? data['posting_date'])
                            ?.toString(),
                      ),
                    ),
                    if (total > 0)
                      _InfoRow(
                        label: 'Total',
                        value: Formatters.currency(total),
                      ),
                    if (widget.showApprovalAction &&
                        total > AppConstants.approvalThreshold) ...[
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => Get.toNamed(
                          AppRoutes.purchaseOrderApproval,
                          arguments: data,
                        ),
                        icon: const Icon(Icons.verified_outlined),
                        label: const Text('Review Approval'),
                      ),
                    ],
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
            for (final item in (data['items'] as List? ?? const []))
              Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(
                    (item['item_name'] ?? item['item_code'] ?? 'Item')
                        .toString(),
                  ),
                  subtitle: Text('Code: ${item['item_code'] ?? '-'}'),
                  trailing: Text('${item['qty'] ?? 0} ${item['uom'] ?? ''}'),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
