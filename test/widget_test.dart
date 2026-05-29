import 'package:flutter_test/flutter_test.dart';
import 'package:sanskruti_group/core/constants/app_constants.dart';
import 'package:sanskruti_group/models/purchase_request.dart';

void main() {
  test('app constants expose the production brand', () {
    expect(AppConstants.appName, 'Dux Purchase Master');
    expect(AppConstants.poweredBy, 'Dux Digitech');
  });

  group('Material Request ERP status mapping', () {
    test('keeps Ordered above workflow approval state', () {
      final request = PurchaseRequest.fromJson(const {
        'name': 'MAT-MR-1',
        'status': 'Ordered',
        'docstatus': 1,
        'workflow_state': 'Approved',
      });

      expect(request.displayStatus, 'Ordered');
    });

    test('keeps Received above workflow approval state', () {
      final request = PurchaseRequest.fromJson(const {
        'name': 'MAT-MR-2',
        'status': 'Received',
        'docstatus': 1,
        'workflow_state': 'Approved',
      });

      expect(request.displayStatus, 'Received');
    });

    test(
      'shows pending approval from workflow before approved/pending flow',
      () {
        final request = PurchaseRequest.fromJson(const {
          'name': 'MAT-MR-3',
          'status': 'Pending',
          'docstatus': 0,
          'workflow_state': 'Pending Approval',
        });

        expect(request.displayStatus, 'Pending Approval');
      },
    );

    test('uses percentage fields when ERP status is not final', () {
      final request = PurchaseRequest.fromJson(const {
        'name': 'MAT-MR-4',
        'status': 'Pending',
        'docstatus': 1,
        'per_ordered': 100,
        'workflow_state': 'Approved',
      });

      expect(request.displayStatus, 'Ordered');
    });
  });
}
