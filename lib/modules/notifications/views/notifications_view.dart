import 'package:flutter/material.dart';

import '../../../widgets/app_state_widgets.dart';
import '../../../widgets/responsive_shell.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveShell(
      title: 'Notifications',
      child: EmptyState(
        icon: Icons.notifications_none,
        title: 'No notifications',
        message:
            'Push notification hooks are prepared for future ERPNext alerts.',
      ),
    );
  }
}
