import 'package:flutter/material.dart';

import '../../../widgets/document_detail_view.dart';
import '../controllers/purchase_receipt_controller.dart';

class PurchaseReceiptDetailView extends StatelessWidget {
  const PurchaseReceiptDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProcurementDocumentDetailView<PurchaseReceiptController>(
      title: 'Material Received Details',
      icon: Icons.inventory_2_outlined,
    );
  }
}
