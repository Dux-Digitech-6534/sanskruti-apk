import 'package:flutter_test/flutter_test.dart';
import 'package:sanskruti_group/core/constants/app_constants.dart';
import 'package:sanskruti_group/models/purchase_request.dart';
import 'package:sanskruti_group/repositories/purchase_receipt_repository.dart';

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

    test('shows ERP Pending as Pending PO in the app', () {
      final request = PurchaseRequest.fromJson(const {
        'name': 'MAT-MR-5',
        'status': 'Pending',
        'docstatus': 1,
        'workflow_state': 'Approved',
      });

      expect(request.displayStatus, 'Pending PO');
    });
  });

  group('Purchase Receipt PO item mapping', () {
    test('uses base_rate when rate is missing from PO item JSON', () {
      final item = PurchaseOrderReceiptItem.fromJson(const {
        'item_code': 'ITEM-1',
        'qty': 5,
        'received_qty': 0,
        'base_rate': 10,
      });

      expect(item.rate, 10);
    });

    test('falls back to amount divided by qty for PO item rate', () {
      final item = PurchaseOrderReceiptItem.fromJson(const {
        'item_code': 'ITEM-1',
        'qty': 5,
        'received_qty': 0,
        'amount': 50,
      });

      expect(item.rate, 10);
    });
  });
}
