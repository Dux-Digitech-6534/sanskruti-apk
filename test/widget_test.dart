import 'package:flutter_test/flutter_test.dart';
import 'package:sanskruti_group/core/constants/app_constants.dart';
import 'package:sanskruti_group/features/purchase_order/presentation/purchase_order_controller.dart';
import 'package:sanskruti_group/models/dashboard_data.dart';
import 'package:sanskruti_group/models/purchase_request.dart';
import 'package:sanskruti_group/repositories/purchase_order_repository.dart';
import 'package:sanskruti_group/repositories/purchase_receipt_repository.dart';
import 'package:sanskruti_group/repositories/purchase_request_repository.dart';

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

  group('Material Request detail mapping', () {
    test('reads saved sub category custom field', () {
      final detail = MaterialRequestDetail.fromJson(const {
        'name': 'MAT-MR-1',
        'status': 'Pending',
        'docstatus': 1,
        'custom_category': 'Civil',
        'custom_sub_category': 'Cement',
      });

      expect(detail.subCategory, 'Cement');
    });
  });

  group('Dashboard data mapping', () {
    test('reads total purchase order count', () {
      final data = DashboardData.fromJson(const {
        'total_material_requests_count': 8,
        'total_purchase_orders_count': 12,
        'pending_purchase_orders_count': 3,
      });

      expect(data.totalPurchaseOrdersCount, 12);
    });
  });

  group('Purchase Order filters', () {
    final orders = [
      const PurchaseOrderSummary(
        name: 'PO-DRAFT',
        supplier: 'Supplier',
        status: 'Draft',
        docstatus: 0,
        grandTotal: 0,
      ),
      const PurchaseOrderSummary(
        name: 'PO-PENDING',
        supplier: 'Supplier',
        status: 'Pending',
        docstatus: 1,
        grandTotal: 0,
      ),
      const PurchaseOrderSummary(
        name: 'PO-APPROVED',
        supplier: 'Supplier',
        status: 'To Receive and Bill',
        docstatus: 1,
        grandTotal: 0,
      ),
      const PurchaseOrderSummary(
        name: 'PO-CANCELLED',
        supplier: 'Supplier',
        status: 'Cancelled',
        docstatus: 2,
        grandTotal: 0,
      ),
    ];

    test('All shows every purchase order', () {
      final state = PurchaseOrderState(items: orders);

      expect(state.visibleItems.map((item) => item.name), [
        'PO-DRAFT',
        'PO-PENDING',
        'PO-APPROVED',
        'PO-CANCELLED',
      ]);
    });

    test('Approval Pending shows Draft and Pending only', () {
      final state = PurchaseOrderState(
        items: orders,
        statusFilter: PurchaseOrderStatusFilter.approvalPending,
      );

      expect(state.visibleItems.map((item) => item.name), [
        'PO-DRAFT',
        'PO-PENDING',
      ]);
    });

    test('Approved excludes Draft, Pending, and Cancelled', () {
      final state = PurchaseOrderState(
        items: orders,
        statusFilter: PurchaseOrderStatusFilter.approved,
      );

      expect(state.visibleItems.map((item) => item.name), ['PO-APPROVED']);
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

  group('Purchase Receipt attachment dedupe', () {
    test('removes duplicate file urls with query parameters', () {
      final attachments = dedupeReceiptAttachments(const [
        ReceiptAttachment(
          id: 'FILE-1',
          fileName: 'receipt.jpg',
          fileUrl: '/private/files/receipt.jpg?download=1',
        ),
        ReceiptAttachment(
          id: 'FILE-2',
          fileName: 'receipt.jpg',
          fileUrl: 'https://sanskruti.example/private/files/receipt.jpg',
        ),
      ]);

      expect(attachments, hasLength(1));
      expect(attachments.single.id, 'FILE-1');
    });

    test('keeps same file name when urls point to different files', () {
      final attachments = dedupeReceiptAttachments(const [
        ReceiptAttachment(
          id: 'FILE-1',
          fileName: 'receipt.jpg',
          fileUrl: '/private/files/receipt.jpg',
        ),
        ReceiptAttachment(
          id: 'FILE-2',
          fileName: 'receipt.jpg',
          fileUrl: '/private/files/receipt-1.jpg',
        ),
      ]);

      expect(attachments, hasLength(2));
    });

    test('removes duplicate uploads with same file name and size', () {
      final attachments = dedupeReceiptAttachments(const [
        ReceiptAttachment(
          id: 'FILE-1',
          fileName: 'receipt.jpg',
          fileUrl: '/private/files/receipt.jpg',
          fileSize: 1024,
        ),
        ReceiptAttachment(
          id: 'FILE-2',
          fileName: 'receipt.jpg',
          fileUrl: '/private/files/receipt-1.jpg',
          fileSize: 1024,
        ),
      ]);

      expect(attachments, hasLength(1));
    });
  });
}
