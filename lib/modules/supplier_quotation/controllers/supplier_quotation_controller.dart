import '../../../services/api_client.dart';
import '../../../services/document_repository.dart';
import '../../../services/procurement_document_controller.dart';

class SupplierQuotationController extends ProcurementDocumentController {
  SupplierQuotationController(ApiClient apiClient)
    : super(DocumentRepository(apiClient, 'Supplier Quotation'), apiClient);
}
