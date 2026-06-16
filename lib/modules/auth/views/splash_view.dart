import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/app_constants.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_state_widgets.dart';
import '../controllers/auth_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  late final AuthController controller = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    controller.decideStartRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppTheme.orange,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.apartment, color: Colors.white, size: 42),
            ),
            const SizedBox(height: 20),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Procurement Management',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 32),
            const AppLoader(),
          ],
        ),
      ),
    );
  }
}
