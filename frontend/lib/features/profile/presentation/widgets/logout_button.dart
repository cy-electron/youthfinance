import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youthfinance/features/auth/providers/auth_provider.dart';

class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonal(
        onPressed: () async {
          await ref.read(authProvider.notifier).logout();
        },

        style: FilledButton.styleFrom(
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),

        child: const Text("Log Out"),
      ),
    );
  }
}
