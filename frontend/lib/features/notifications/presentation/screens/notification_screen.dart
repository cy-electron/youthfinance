import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../design_system/cards/app_card.dart';
import '../../model/app_notification.dart';
import '../../model/notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    final hasUnread = notifications.valueOrNull?.any((item) => !item.isRead) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: () async {
                try {
                  await ref.read(notificationProvider.notifier).markAllRead();
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Unable to mark notifications as read.')),
                  );
                }
              },
              child: const Text('Read all'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationProvider.notifier).refresh(),
        child: notifications.when(
          loading: () => const _LoadingView(),
          error: (_, __) => _ErrorView(
            onRetry: () => ref.read(notificationProvider.notifier).refresh(),
          ),
          data: (items) => items.isEmpty
              ? const _EmptyView()
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: items.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _NotificationCard(
                      notification: items[index],
                      onTap: () async {
                        if (items[index].isRead) return;
                        try {
                          await ref.read(notificationProvider.notifier).markRead(items[index].id);
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Unable to update notification.')),
                          );
                        }
                      },
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = notification.createdAt.toLocal();
    return AppCard(
      color: notification.isRead ? null : AppColors.primaryLight,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.savings_outlined, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.xs),
                Text(notification.message),
                const SizedBox(height: AppSpacing.xs),
                Text('${date.day}/${date.month}/${date.year}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (!notification.isRead)
            const Padding(
              padding: EdgeInsets.only(left: AppSpacing.sm),
              child: Icon(Icons.circle, size: 10, color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => ListView(
    children: [SizedBox(height: 300, child: Center(child: CircularProgressIndicator()))],
  );
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppSpacing.lg),
    children: [
      const SizedBox(height: 120),
      const Icon(Icons.error_outline, size: 48),
      const SizedBox(height: AppSpacing.md),
      const Center(child: Text('Unable to load notifications.')),
      const SizedBox(height: AppSpacing.md),
      Center(child: FilledButton(onPressed: onRetry, child: const Text('Try again'))),
    ],
  );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) => ListView(
    padding: EdgeInsets.all(AppSpacing.lg),
    children: [
      SizedBox(height: 120),
      Icon(Icons.notifications_none_rounded, size: 64),
      SizedBox(height: AppSpacing.md),
      Text('No notifications yet.', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      SizedBox(height: AppSpacing.sm),
      Text('Emergency Fund updates will appear here when enabled in Settings.', textAlign: TextAlign.center),
    ],
  );
}
