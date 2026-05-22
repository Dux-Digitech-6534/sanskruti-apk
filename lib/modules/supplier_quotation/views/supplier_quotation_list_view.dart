import 'package:flutter/material.dart';

import '../../../routes/app_routes.dart';
import '../../../widgets/document_list_view.dart';
import '../controllers/supplier_quotation_controller.dart';

class SupplierQuotationListView extends StatelessWidget {
  const SupplierQuotationListView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProcurementDocumentListView<SupplierQuotationController>(
      title: 'Supplier Quotations',
      emptyTitle: 'No supplier quotations found',
      emptyMessage: 'Supplier quotations from ERPNext will appear here.',
      icon: Icons.request_quote_outlined,
      detailsRoute: AppRoutes.supplierQuotationDetails,
    );
  }
}
