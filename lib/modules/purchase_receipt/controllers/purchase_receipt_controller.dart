import '../../../services/api_client.dart';
import '../../../services/document_repository.dart';
import '../../../services/procurement_document_controller.dart';

class PurchaseReceiptController extends ProcurementDocumentController {
  PurchaseReceiptController(ApiClient apiClient)
    : super(DocumentRepository(apiClient, 'Purchase Receipt'), apiClient);
}
