import 'package:flutter/material.dart';

import '../../../routes/app_routes.dart';
import '../../../widgets/document_list_view.dart';
import '../controllers/purchase_receipt_controller.dart';

class PurchaseReceiptListView extends StatelessWidget {
  const PurchaseReceiptListView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProcurementDocumentListView<PurchaseReceiptController>(
      title: 'Material Received',
      emptyTitle: 'No material received records found',
      emptyMessage: 'Site receiving documents from ERPNext will appear here.',
      icon: Icons.inventory_2_outlined,
      detailsRoute: AppRoutes.purchaseReceiptDetails,
    );
  }
}
