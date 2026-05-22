import 'package:flutter/material.dart';

import '../../../core/app_constants.dart';
import '../../../widgets/responsive_shell.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveShell(
      title: 'Settings',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.link),
                  title: Text('Backend'),
                  subtitle: Text(AppConstants.backendBaseUrl),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.cloud_sync_outlined),
                  title: Text('Offline Sync'),
                  subtitle: Text('Architecture ready for queued transactions'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.qr_code_scanner),
                  title: Text('QR Scanner'),
                  subtitle: Text(
                    'Prepared module surface for receiving workflows',
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.draw_outlined),
                  title: Text('Signature Upload'),
                  subtitle: Text('Prepared for site handover confirmations'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
