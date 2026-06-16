import 'package:get/get.dart';

import '../modules/approvals/controllers/approvals_controller.dart';
import '../modules/approvals/views/approvals_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/splash_view.dart';
import '../modules/dashboard/controllers/dashboard_controller.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/material_request/bindings/material_request_binding.dart';
import '../modules/material_request/views/material_request_create_view.dart';
import '../modules/material_request/views/material_request_detail_view.dart';
import '../modules/material_request/views/material_request_list_view.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/purchase_order/controllers/purchase_order_controller.dart';
import '../modules/purchase_order/views/purchase_order_approval_view.dart';
import '../modules/purchase_order/views/purchase_order_detail_view.dart';
import '../modules/purchase_order/views/purchase_order_list_view.dart';
import '../modules/purchase_receipt/controllers/purchase_receipt_controller.dart';
import '../modules/purchase_receipt/views/purchase_receipt_detail_view.dart';
import '../modules/purchase_receipt/views/purchase_receipt_list_view.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/supplier_quotation/controllers/supplier_quotation_controller.dart';
import '../modules/supplier_quotation/views/supplier_quotation_detail_view.dart';
import '../modules/supplier_quotation/views/supplier_quotation_list_view.dart';
import '../services/api_client.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => DashboardController(Get.find<ApiClient>())),
      ),
    ),
    GetPage(
      name: AppRoutes.materialRequests,
      page: () => const MaterialRequestListView(),
      binding: MaterialRequestBinding(),
    ),
    GetPage(
      name: AppRoutes.materialRequestCreate,
      page: () => const MaterialRequestCreateView(),
      binding: MaterialRequestBinding(),
    ),
    GetPage(
      name: AppRoutes.materialRequestDetails,
      page: () => const MaterialRequestDetailView(),
      binding: MaterialRequestBinding(),
    ),
    GetPage(
      name: AppRoutes.supplierQuotations,
      page: () => const SupplierQuotationListView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(
          () => SupplierQuotationController(Get.find<ApiClient>()),
        ),
      ),
    ),
    GetPage(
      name: AppRoutes.supplierQuotationDetails,
      page: () => const SupplierQuotationDetailView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(
          () => SupplierQuotationController(Get.find<ApiClient>()),
        ),
      ),
    ),
    GetPage(
      name: AppRoutes.purchaseOrders,
      page: () => const PurchaseOrderListView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => PurchaseOrderController(Get.find<ApiClient>())),
      ),
    ),
    GetPage(
      name: AppRoutes.purchaseOrderDetails,
      page: () => const PurchaseOrderDetailView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => PurchaseOrderController(Get.find<ApiClient>())),
      ),
    ),
    GetPage(
      name: AppRoutes.purchaseOrderApproval,
      page: () => const PurchaseOrderApprovalView(),
    ),
    GetPage(
      name: AppRoutes.purchaseReceipts,
      page: () => const PurchaseReceiptListView(),
      binding: BindingsBuilder(
        () =>
            Get.lazyPut(() => PurchaseReceiptController(Get.find<ApiClient>())),
      ),
    ),
    GetPage(
      name: AppRoutes.purchaseReceiptDetails,
      page: () => const PurchaseReceiptDetailView(),
      binding: BindingsBuilder(
        () =>
            Get.lazyPut(() => PurchaseReceiptController(Get.find<ApiClient>())),
      ),
    ),
    GetPage(
      name: AppRoutes.approvals,
      page: () => const ApprovalsView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => ApprovalsController(Get.find<ApiClient>())),
      ),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: AuthBinding(),
    ),
    GetPage(name: AppRoutes.settings, page: () => const SettingsView()),
  ];
}
