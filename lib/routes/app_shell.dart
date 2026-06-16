import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';
import '../l10n/app_localizations.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            selectedIcon: const Icon(Icons.home, color: AppColors.primary),
            icon: const Icon(Icons.home_outlined),
            label: context.l10n.t('home'),
          ),
          NavigationDestination(
            selectedIcon: const Icon(
              Icons.assignment,
              color: AppColors.primary,
            ),
            icon: const Icon(Icons.assignment_outlined),
            label: context.l10n.t('request'),
          ),
          NavigationDestination(
            selectedIcon: const Icon(
              Icons.receipt_long,
              color: AppColors.primary,
            ),
            icon: const Icon(Icons.receipt_long_outlined),
            label: context.l10n.t('receipt'),
          ),
          NavigationDestination(
            selectedIcon: const Icon(
              Icons.inventory_2,
              color: AppColors.primary,
            ),
            icon: const Icon(Icons.inventory_2_outlined),
            label: context.l10n.t('stock'),
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.person, color: AppColors.primary),
            icon: const Icon(Icons.person_outline),
            label: context.l10n.t('profile'),
          ),
        ],
      ),
    );
  }
}
