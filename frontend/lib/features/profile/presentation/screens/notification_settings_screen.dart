import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../notifications/model/notification_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(notificationPreferenceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: preference.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(notificationPreferenceProvider),
            child: const Text('Try again'),
          ),
        ),
        data: (value) => ListView(
          children: [
            SwitchListTile(
              title: const Text('Emergency Fund activity'),
              subtitle: const Text(
                'Show in-app updates when money is added to or released from your Emergency Fund.',
              ),
              value: value.emergencyFundEnabled,
              onChanged: (enabled) async {
                try {
                  await ref
                      .read(notificationPreferenceProvider.notifier)
                      .updateEmergencyFundEnabled(enabled);
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Unable to update notification preferences.')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
