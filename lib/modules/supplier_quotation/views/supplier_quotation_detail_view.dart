import 'package:flutter/material.dart';

import '../../../widgets/document_detail_view.dart';
import '../controllers/supplier_quotation_controller.dart';

class SupplierQuotationDetailView extends StatelessWidget {
  const SupplierQuotationDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProcurementDocumentDetailView<SupplierQuotationController>(
      title: 'Supplier Quotation Details',
      icon: Icons.request_quote_outlined,
    );
  }
}
