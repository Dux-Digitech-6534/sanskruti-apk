import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_state_widgets.dart';
import '../../../widgets/responsive_shell.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveShell(
      title: 'Dashboard',
      child: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoader(message: 'Loading procurement dashboard');
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
            padding: const EdgeInsets.all(20),
            children: [
              _WorkflowBanner(),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 720;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        [
                              _MetricCard(
                                label: 'Material Requests',
                                value: controller.materialRequests.length
                                    .toString(),
                                icon: Icons.assignment_outlined,
                              ),
                              _MetricCard(
                                label: 'Purchase Orders',
                                value: controller.purchaseOrders.length
                                    .toString(),
                                icon: Icons.shopping_cart_checkout_outlined,
                              ),
                              _MetricCard(
                                label: 'Approval Rule',
                                value:
                                    '> ${Formatters.currency(AppConstants.approvalThreshold)}',
                                icon: Icons.verified_outlined,
                              ),
                            ]
                            .map(
                              (child) => SizedBox(
                                width: wide
                                    ? (constraints.maxWidth - 24) / 3
                                    : constraints.maxWidth,
                                child: child,
                              ),
                            )
                            .toList(),
                  );
                },
              ),
              const SizedBox(height: 18),
              Text(
                'Recent Purchase Orders',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              for (final order in controller.purchaseOrders)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    tileColor: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    leading: const Icon(Icons.shopping_bag_outlined),
                    title: Text(order.name),
                    subtitle: Text(order.status),
                    trailing: Text(Formatters.currency(order.grandTotal)),
                    onTap: () => Get.toNamed(
                      AppRoutes.purchaseOrderDetails,
                      arguments: order.name,
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

class _WorkflowBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const steps = [
      'Material Request',
      'Supplier Quotation',
      'Purchase Order',
      'Material Received',
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Procurement Workflow',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                Chip(
                  avatar: CircleAvatar(
                    backgroundColor: AppTheme.orange,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  label: Text(steps[i]),
                  backgroundColor: Colors.white,
                ),
                if (i != steps.length - 1)
                  const Icon(Icons.arrow_forward, color: Colors.white70),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.orange.withValues(alpha: 0.15),
              foregroundColor: AppTheme.orange,
              child: Icon(icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
