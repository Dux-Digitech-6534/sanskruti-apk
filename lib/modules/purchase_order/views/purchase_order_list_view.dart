import 'package:flutter/material.dart';

import '../../../routes/app_routes.dart';
import '../../../widgets/document_list_view.dart';
import '../controllers/purchase_order_controller.dart';

class PurchaseOrderListView extends StatelessWidget {
  const PurchaseOrderListView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProcurementDocumentListView<PurchaseOrderController>(
      title: 'Purchase Orders',
      emptyTitle: 'No purchase orders found',
      emptyMessage:
          'Approved and draft purchase orders from ERPNext will appear here.',
      icon: Icons.shopping_cart_checkout_outlined,
      detailsRoute: AppRoutes.purchaseOrderDetails,
    );
  }
}
