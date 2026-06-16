import 'package:flutter/material.dart';

import '../../../widgets/document_detail_view.dart';
import '../controllers/purchase_order_controller.dart';

class PurchaseOrderDetailView extends StatelessWidget {
  const PurchaseOrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProcurementDocumentDetailView<PurchaseOrderController>(
      title: 'Purchase Order Details',
      icon: Icons.shopping_cart_checkout_outlined,
      showApprovalAction: true,
    );
  }
}
