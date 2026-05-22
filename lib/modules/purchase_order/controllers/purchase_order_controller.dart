import '../../../services/api_client.dart';
import '../../../services/document_repository.dart';
import '../../../services/procurement_document_controller.dart';

class PurchaseOrderController extends ProcurementDocumentController {
  PurchaseOrderController(ApiClient apiClient)
    : super(DocumentRepository(apiClient, 'Purchase Order'), apiClient);
}
