import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    required this.title,
    this.actions,
    this.leading,
    this.showMenuButton = false,
    super.key,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showMenuButton;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: leading ?? (showMenuButton ? _MenuButton() : _BackButton()),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => IconButton(
        tooltip: context.l10n.t('menu'),
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/dashboard');
        }
      },
    );
  }
}
