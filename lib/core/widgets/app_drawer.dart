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
      backgroundColor: Colors.white,
      child: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Color(0xFFFFF8EA)],
            ),
          ),
          child: Column(
            children: [
              _DrawerHeader(
                name: user?.fullName ?? 'Sanskruti User',
                email: user?.email ?? user?.id ?? '',
                role: user?.role,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                  children: [
                    _DrawerItem(
                      icon: Icons.dashboard_outlined,
                      label: l10n.t('dashboard'),
                      selected: true,
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
                      icon: Icons.shopping_cart_outlined,
                      label: l10n.t('purchase_orders'),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/purchase-order');
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
                    _DrawerItem(
                      icon: Icons.person_outline,
                      label: l10n.t('profile'),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/profile');
                      },
                    ),
                    const SizedBox(height: 14),
                    const Divider(),
                    const SizedBox(height: 12),
                    _LanguageToggle(
                      selectedCode: locale.languageCode,
                      onChanged: (code) {
                        ref
                            .read(localeControllerProvider.notifier)
                            .setLocale(Locale(code));
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
                child: Column(
                  children: [
                    _LogoutTile(
                      enabled: !authState.isLoading,
                      onTap: () async {
                        Navigator.of(context).pop();
                        await ref
                            .read(authControllerProvider.notifier)
                            .logout();
                        if (context.mounted) context.go('/login');
                      },
                    ),
                    const SizedBox(height: 18),
                    const _DrawerFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.name, required this.email, this.role});

  final String name;
  final String email;
  final String? role;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Image(
            image: AssetImage(AppConstants.logoAsset),
            width: 154,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 2),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    if (role?.trim().isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          role!.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
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
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: AppColors.primary.withValues(alpha: .12),
            selectedForegroundColor: AppColors.primary,
            foregroundColor: AppColors.text,
            side: const BorderSide(color: AppColors.border),
          ),
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
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        selected: selected,
        selectedTileColor: AppColors.primary.withValues(alpha: .08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.mutedText),
        onTap: onTap,
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: enabled,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.danger.withValues(alpha: .18)),
        ),
        child: const Icon(Icons.logout, color: AppColors.danger),
      ),
      title: Text(
        context.l10n.t('logout'),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      onTap: enabled ? onTap : null,
    );
  }
}

class _DrawerFooter extends StatelessWidget {
  const _DrawerFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.l10n.t('powered_by'),
          style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
        ),
        const SizedBox(width: 8),
        const Image(
          image: AssetImage(AppConstants.duxMarkAsset),
          width: 26,
          height: 26,
        ),
        const SizedBox(width: 6),
        const Text(
          AppConstants.poweredBy,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
