import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/blueprint_background.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final remembered = ref.read(authControllerProvider).rememberedUser;
      if (remembered != null) _userController.text = remembered;
    });
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    _userFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    debugPrint('[Login] Login button clicked');
    if (ref.read(authControllerProvider).isLoading) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final success = await ref
        .read(authControllerProvider.notifier)
        .login(_userController.text, _passwordController.text);
    if (!mounted) return;
    if (success) {
      context.go('/dashboard');
      return;
    }
    final error = ref.read(authControllerProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.message(error ?? 'Unable to login. Please try again.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final keyboardBottom = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.background,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: BlueprintBackground(
            blueTop: true,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(22, 28, 22, 24 + keyboardBottom),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _LoginCard(
                          userController: _userController,
                          passwordController: _passwordController,
                          userFocusNode: _userFocusNode,
                          passwordFocusNode: _passwordFocusNode,
                          obscurePassword: _obscurePassword,
                          rememberMe: state.rememberMe,
                          isLoading: state.isLoading,
                          onTogglePassword: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          onRememberChanged: (value) => ref
                              .read(authControllerProvider.notifier)
                              .setRememberMe(value ?? true),
                          onSubmit: _submit,
                        ),
                        const SizedBox(height: 26),
                        const _LoginTrustRow(),
                        const SizedBox(height: 18),
                        const _LoginFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.userController,
    required this.passwordController,
    required this.userFocusNode,
    required this.passwordFocusNode,
    required this.obscurePassword,
    required this.rememberMe,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onRememberChanged,
    required this.onSubmit,
  });

  final TextEditingController userController;
  final TextEditingController passwordController;
  final FocusNode userFocusNode;
  final FocusNode passwordFocusNode;
  final bool obscurePassword;
  final bool rememberMe;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: .7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: .20),
            offset: const Offset(0, 22),
            blurRadius: 46,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Image(
              image: AssetImage(AppConstants.logoAsset),
              width: 210,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.t('welcome_back'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sign in to continue',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          _FieldLabel(text: 'Email / Username'),
          const SizedBox(height: 8),
          AppTextField(
            controller: userController,
            focusNode: userFocusNode,
            hintText: 'Enter your email or username',
            prefixIcon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            validator: (value) => value == null || value.trim().isEmpty
                ? l10n.message('User ID is required')
                : null,
          ),
          const SizedBox(height: 16),
          _FieldLabel(text: l10n.t('password')),
          const SizedBox(height: 8),
          AppTextField(
            controller: passwordController,
            focusNode: passwordFocusNode,
            hintText: 'Enter your password',
            prefixIcon: Icons.lock_outline,
            obscureText: obscurePassword,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => onSubmit(),
            suffixIcon: IconButton(
              onPressed: onTogglePassword,
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
            validator: (value) => value == null || value.isEmpty
                ? l10n.message('Password is required')
                : null,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                visualDensity: VisualDensity.compact,
                value: rememberMe,
                onChanged: onRememberChanged,
              ),
              Text(
                l10n.t('remember_me'),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppButton(
            label: l10n.t('login'),
            icon: Icons.login,
            isLoading: isLoading,
            onPressed: onSubmit,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.text,
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _LoginTrustRow extends StatelessWidget {
  const _LoginTrustRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _TrustPill(
            icon: Icons.verified_user_outlined,
            label: 'Secure',
            caption: 'Protected',
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _TrustPill(
            icon: Icons.schedule_outlined,
            label: 'Real-time',
            caption: 'Track every step',
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _TrustPill(
            icon: Icons.check_circle_outline,
            label: 'Reliable',
            caption: 'Built for site',
          ),
        ),
      ],
    );
  }
}

class _TrustPill extends StatelessWidget {
  const _TrustPill({
    required this.icon,
    required this.label,
    required this.caption,
  });

  final IconData icon;
  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .76),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: .85)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 19),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.mutedText, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context).t('powered_by'),
          style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
        ),
        const SizedBox(width: 8),
        const Image(
          image: AssetImage(AppConstants.duxMarkAsset),
          width: 28,
          height: 28,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 6),
        const Text(
          AppConstants.poweredBy,
          style: TextStyle(
            color: AppColors.text,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
