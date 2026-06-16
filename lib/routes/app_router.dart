import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/purchase_order/presentation/purchase_order_list_screen.dart';
import '../features/purchase_order/presentation/purchase_order_detail_screen.dart';
import '../features/purchase_receipt/presentation/create_purchase_receipt_screen.dart';
import '../features/purchase_receipt/presentation/purchase_receipt_detail_screen.dart';
import '../features/purchase_receipt/presentation/purchase_receipt_list_screen.dart';
import '../features/purchase_request/presentation/create_purchase_request_screen.dart';
import '../features/purchase_request/presentation/purchase_request_detail_screen.dart';
import '../features/purchase_request/presentation/purchase_request_list_screen.dart';
import '../features/stock/presentation/stock_screen.dart';
import 'app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final path = state.uri.path;
      final publicRoute = path == '/' || path == '/login';
      if (!authState.isAuthenticated && !publicRoute) return '/login';
      if (authState.isAuthenticated && path == '/login') return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', redirect: (context, state) => '/dashboard'),
      GoRoute(
        path: '/purchase-request',
        builder: (context, state) => PurchaseRequestListScreen(
          initialPendingOnly: state.uri.queryParameters['status'] == 'pending',
        ),
      ),
      GoRoute(
        path: '/create-purchase-request',
        builder: (context, state) => const CreatePurchaseRequestScreen(),
      ),
      GoRoute(
        path: '/purchase-request-detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PurchaseRequestDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/purchase-order',
        builder: (context, state) => PurchaseOrderListScreen(
          initialPendingOnly: state.uri.queryParameters['status'] == 'pending',
        ),
      ),
      GoRoute(
        path: '/purchase-order-detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PurchaseOrderDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/purchase-receipt',
        builder: (context, state) => const PurchaseReceiptListScreen(),
      ),
      GoRoute(
        path: '/purchase-receipt-detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PurchaseReceiptDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/create-purchase-receipt',
        builder: (context, state) => const CreatePurchaseReceiptScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/requests',
                builder: (context, state) => PurchaseRequestListScreen(
                  initialPendingOnly:
                      state.uri.queryParameters['status'] == 'pending',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/receipts',
                builder: (context, state) => const PurchaseReceiptListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stock',
                builder: (context, state) => const StockScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
