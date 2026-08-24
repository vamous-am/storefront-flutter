import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../cart/presentation/cart_provider.dart';
import 'profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Refresh',
            onPressed: () => ref.read(profileProvider.notifier).refresh(),
          ),
        ],
      ),
      body: profileState.when(
        loading: () =>
            const LoadingIndicator(message: 'Loading profile...'),
        error: (error, _) => ErrorState(
          message: 'Could not load profile. Please try again.',
          onRetry: () => ref.read(profileProvider.notifier).refresh(),
        ),
        data: (user) {
          if (user == null) {
            return const ErrorState(
              message: 'Profile not found for the current account.',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 48,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    '${user.firstName.isNotEmpty ? user.firstName[0] : '?'}${user.lastName.isNotEmpty ? user.lastName[0] : ''}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${user.firstName} ${user.lastName}'.trim().isEmpty
                      ? user.username
                      : '${user.firstName} ${user.lastName}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${user.username}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 28),
                // Info card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      _InfoTile(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user.email,
                      ),
                      Divider(height: 1, indent: 56, color: colorScheme.outlineVariant),
                      _InfoTile(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: user.phone.isNotEmpty ? user.phone : '—',
                      ),
                      Divider(height: 1, indent: 56, color: colorScheme.outlineVariant),
                      _InfoTile(
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: [user.street, user.city]
                            .where((s) => s.isNotEmpty)
                            .join(', ')
                            .isNotEmpty
                            ? '${user.street}, ${user.city}'
                            : '—',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Logout button
                FilledButton.tonal(
                  onPressed: () => _confirmLogout(context, ref),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: colorScheme.error),
                      const SizedBox(width: 8),
                      Text(
                        'Log Out',
                        style: TextStyle(
                          color: colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Shows a confirmation dialog before performing logout.
  /// Logout clears the auth session and the shopping cart.
  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text(
            'Are you sure you want to log out? Your cart will be cleared.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        // Clear cart first, then log out.
        ref.read(cartProvider.notifier).clearCart();
        ref.read(authProvider.notifier).logout();
      }
    });
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 22, color: colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
