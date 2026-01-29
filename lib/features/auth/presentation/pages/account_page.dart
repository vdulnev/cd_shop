import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cd_shop/core/services/firestore_seeder.dart';
import 'package:cd_shop/features/auth/domain/entities/user.dart';
import 'package:cd_shop/features/auth/presentation/providers/account_state.dart';
import 'package:cd_shop/features/auth/presentation/providers/account_provider.dart';
import 'package:cd_shop/features/order/presentation/routes/order_routes.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(accountProvider.notifier).load());
  }

  void _goToLogin() async {
    await context.push('/account/login');
    if (mounted) {
      await ref.read(accountProvider.notifier).load();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AccountState>(accountProvider, (previous, state) {
      if (state is AccountLoggedOut) {
        ref.read(accountProvider.notifier).load();
      }
    });

    final state = ref.watch(accountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: switch (state) {
        AccountInitial() ||
        AccountLoading() =>
          const Center(child: CircularProgressIndicator()),
        AccountUnauthenticated() ||
        AccountLoggedOut() =>
          _UnauthenticatedView(
            onLoginPressed: _goToLogin,
          ),
        AccountError(:final message) => _ErrorView(
            message: message,
            onRetry: () => ref.read(accountProvider.notifier).load(),
          ),
        AccountAuthenticated(:final user) => _AuthenticatedView(
            user: user,
            onLogout: () => ref.read(accountProvider.notifier).logout(),
          ),
      },
    );
  }
}

class _AuthenticatedView extends StatelessWidget {
  const _AuthenticatedView({
    required this.user,
    required this.onLogout,
  });

  final User user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 50,
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 40,
                  color:
                      Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 48),
            _AccountMenuItem(
              icon: Icons.shopping_bag_outlined,
              title: 'My Orders',
              onTap: () => context.push(
                '/account/orders',
                extra: OrdersRouteData(userId: user.id),
              ),
            ),
            _AccountMenuItem(
              icon: Icons.favorite_outline,
              title: 'Wishlist',
              onTap: () {},
            ),
            _AccountMenuItem(
              icon: Icons.location_on_outlined,
              title: 'Addresses',
              onTap: () => context.push('/account/addresses'),
            ),
            _AccountMenuItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {},
            ),
            const Divider(),
            if (kDebugMode) const _SeedProductsButton(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      );
  }
}

class _SeedProductsButton extends StatefulWidget {
  const _SeedProductsButton();

  @override
  State<_SeedProductsButton> createState() => _SeedProductsButtonState();
}

class _SeedProductsButtonState extends State<_SeedProductsButton> {
  bool _isSeeding = false;

  Future<void> _seedProducts() async {
    setState(() => _isSeeding = true);
    try {
      final seeder = FirestoreSeeder();
      final count = await seeder.seedProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(count > 0
                ? 'Seeded $count products to Firestore'
                : 'Products already exist in Firestore'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error seeding: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AccountMenuItem(
      icon: _isSeeding ? Icons.hourglass_top : Icons.cloud_upload,
      title: _isSeeding ? 'Seeding...' : 'Seed Products (Debug)',
      onTap: _isSeeding ? () {} : _seedProducts,
    );
  }
}

class _UnauthenticatedView extends StatelessWidget {
  const _UnauthenticatedView({required this.onLoginPressed});

  final VoidCallback onLoginPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Sign in to your account',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onLoginPressed,
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _AccountMenuItem extends StatelessWidget {
  const _AccountMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
