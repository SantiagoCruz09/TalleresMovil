import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/task_provider.dart';

class SyncIndicator extends StatelessWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        if (provider.syncStatus == SyncStatus.idle) {
          return const SizedBox.shrink();
        }

        final (icon, color, message) = switch (provider.syncStatus) {
          SyncStatus.syncing => (
            Icons.cloud_upload,
            Colors.blue,
            'Sincronizando...',
          ),
          SyncStatus.success => (
            Icons.cloud_done,
            Colors.green,
            'Sincronizado',
          ),
          SyncStatus.error => (
            Icons.cloud_off,
            Colors.red,
            'Error al sincronizar',
          ),
          SyncStatus.idle => (Icons.check, Colors.grey, ''),
        };

        return Container(
          color: color.withValues(alpha: 0.1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              if (provider.syncStatus == SyncStatus.syncing)
                const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              else
                Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
              const SizedBox(width: 8),
              Text(
                message,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
