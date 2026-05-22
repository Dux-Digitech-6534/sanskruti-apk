import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import 'auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _didNavigate = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_bootstrap);
    Future<void>.delayed(const Duration(seconds: 12), () {
      if (mounted && !_didNavigate) {
        _goNext(isAuthenticated: false);
      }
    });
  }

  Future<void> _bootstrap() async {
    try {
      await ref.read(authControllerProvider.notifier).bootstrap();
    } on Object {
      // Never trap the user on splash if local session restore fails.
    }
    if (!mounted) return;
    final isAuthenticated = ref.read(authControllerProvider).isAuthenticated;
    _goNext(isAuthenticated: isAuthenticated);
  }

  void _goNext({required bool isAuthenticated}) {
    if (_didNavigate) return;
    _didNavigate = true;
    context.go(isAuthenticated ? '/dashboard' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage(AppConstants.logoAsset), width: 180),
            SizedBox(height: 28),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
