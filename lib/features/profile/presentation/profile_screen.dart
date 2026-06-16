import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: CustomAppBar(
        title: context.l10n.t('profile'),
        showMenuButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? 'Sanskruti User',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(user?.email ?? user?.id ?? ''),
                if (user?.role?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(context.l10n.role(user!.role!.trim())),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: context.l10n.t('logout'),
            icon: Icons.logout,
            isLoading: authState.isLoading,
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
