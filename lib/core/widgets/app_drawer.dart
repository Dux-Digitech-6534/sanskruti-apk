import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/locale_controller.dart';
import '../constants/app_constants.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final locale = ref.watch(localeControllerProvider);
    final l10n = context.l10n;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    child: Icon(Icons.person_outline),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? 'Sanskruti User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? user?.id ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            _DrawerItem(
              icon: Icons.dashboard_outlined,
              label: l10n.t('dashboard'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/dashboard');
              },
            ),
            _DrawerItem(
              icon: Icons.assignment_outlined,
              label: l10n.t('material_requests'),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/purchase-request');
              },
            ),
            _DrawerItem(
              icon: Icons.receipt_long_outlined,
              label: l10n.t('purchase_receipts'),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/purchase-receipt');
              },
            ),
            _DrawerItem(
              icon: Icons.inventory_2_outlined,
              label: l10n.t('stock'),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/stock');
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _LanguageToggle(
                selectedCode: locale.languageCode,
                onChanged: (code) {
                  ref
                      .read(localeControllerProvider.notifier)
                      .setLocale(Locale(code));
                },
              ),
            ),
            const Spacer(),
            const Divider(height: 1),
            _DrawerItem(
              icon: Icons.logout,
              label: l10n.t('logout'),
              onTap: authState.isLoading
                  ? null
                  : () async {
                      Navigator.of(context).pop();
                      await ref.read(authControllerProvider.notifier).logout();
                      if (context.mounted) context.go('/login');
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({required this.selectedCode, required this.onChanged});

  final String selectedCode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.t('language'),
          style: const TextStyle(
            color: AppColors.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'en', label: Text(l10n.t('english'))),
            ButtonSegment(value: 'hi', label: Text(l10n.t('hindi'))),
          ],
          selected: {selectedCode == 'hi' ? 'hi' : 'en'},
          onSelectionChanged: (selection) => onChanged(selection.first),
        ),
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      onTap: onTap,
    );
  }
}
