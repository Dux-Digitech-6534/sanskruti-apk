import '../../../services/api_client.dart';
import '../../../services/document_repository.dart';

class MaterialRequestRepository extends DocumentRepository {
  MaterialRequestRepository(ApiClient apiClient)
    : super(apiClient, 'Material Request');
}
