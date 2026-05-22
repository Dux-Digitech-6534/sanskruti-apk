import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import '../theme/app_theme.dart';

class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({
    super.key,
    required this.title,
    required this.child,
    this.floatingActionButton,
  });

  final String title;
  final Widget child;
  final Widget? floatingActionButton;

  static const destinations = [
    _NavItem('Dashboard', Icons.dashboard_outlined, AppRoutes.dashboard),
    _NavItem('Requests', Icons.assignment_outlined, AppRoutes.materialRequests),
    _NavItem(
      'Quotations',
      Icons.request_quote_outlined,
      AppRoutes.supplierQuotations,
    ),
    _NavItem(
      'Orders',
      Icons.shopping_cart_checkout_outlined,
      AppRoutes.purchaseOrders,
    ),
    _NavItem(
      'Receipts',
      Icons.inventory_2_outlined,
      AppRoutes.purchaseReceipts,
    ),
    _NavItem('Approvals', Icons.verified_outlined, AppRoutes.approvals),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final currentIndex = destinations.indexWhere(
      (item) => Get.currentRoute.startsWith(item.route),
    );
    final selected = currentIndex < 0 ? 0 : currentIndex;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Get.key.currentState?.canPop() ?? false) {
              Get.back<void>();
            } else {
              Get.offNamed(AppRoutes.dashboard);
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => Get.toNamed(AppRoutes.notifications),
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () => Get.toNamed(AppRoutes.profile),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      drawer: wide ? null : _AppDrawer(selected: selected),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: selected > 3 ? 0 : selected,
              onDestinationSelected: (index) =>
                  Get.offNamed(destinations[index].route),
              destinations: destinations
                  .take(4)
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.icon),
                      label: item.label,
                    ),
                  )
                  .toList(),
            ),
      body: Row(
        children: [
          if (wide)
            SizedBox(
              width: 248,
              child: _AppDrawer(selected: selected, permanent: true),
            ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.selected, this.permanent = false});

  final int selected;
  final bool permanent;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Container(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        color: AppTheme.darkBlue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: AppTheme.orange,
              foregroundColor: Colors.white,
              child: Icon(Icons.apartment),
            ),
            const SizedBox(height: 12),
            Text(
              'Sanskruti Group',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Construction Procurement',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
      for (var i = 0; i < ResponsiveShell.destinations.length; i++)
        NavigationDrawerDestination(
          selectedIcon: Icon(
            ResponsiveShell.destinations[i].icon,
            color: AppTheme.orange,
          ),
          icon: Icon(ResponsiveShell.destinations[i].icon),
          label: Text(ResponsiveShell.destinations[i].label),
        ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.settings_outlined),
        title: const Text('Settings'),
        onTap: () => Get.toNamed(AppRoutes.settings),
      ),
    ];
    final drawer = NavigationDrawer(
      selectedIndex: selected,
      onDestinationSelected: (index) {
        if (index < ResponsiveShell.destinations.length) {
          Get.offNamed(ResponsiveShell.destinations[index].route);
        }
      },
      children: children,
    );
    return permanent ? drawer : Drawer(child: drawer);
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}
