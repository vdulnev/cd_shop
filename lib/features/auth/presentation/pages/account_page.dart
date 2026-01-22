import 'package:cd_shop/features/auth/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:cd_shop/core/widgets/snackbar_helper.dart';
import 'package:cd_shop/features/auth/presentation/bloc/account_bloc.dart';
import 'package:cd_shop/injection_container.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccountBloc>()..add(const AccountLoaded()),
      child: const _AccountView(),
    );
  }
}

class _AccountView extends StatefulWidget {
  const _AccountView();

  @override
  State<_AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<_AccountView> {
  void _goToLogin() async {
    await context.push('/account/login');
    // Reload when returning from login
    if (mounted) {
      context.read<AccountBloc>().add(const AccountLoaded());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: BlocConsumer<AccountBloc, AccountState>(
        listener: (context, state) {
          if (state is AccountLoggedOut) {
            // Reload to check auth status
            context.read<AccountBloc>().add(const AccountLoaded());
          } else if (state is AccountError) {
            showErrorSnackBar(
              context,
              message: state.message,
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            AccountInitial() ||
            AccountLoading() =>
              const Center(child: CircularProgressIndicator()),
            AccountUnauthenticated() ||
            AccountLoggedOut() =>
              _UnauthenticatedView(
                onLoginPressed: _goToLogin,
              ),
            AccountError(:final message) => _ErrorView(message: message),
            AccountAuthenticated(:final user) => _AuthenticatedView(user: user),
          };
        },
      ),
    );
  }
}

class _AuthenticatedView extends StatelessWidget {
  const _AuthenticatedView({
    required this.user,
  });

  final User user;

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
              onTap: () {},
            ),
            _AccountMenuItem(
              icon: Icons.favorite_outline,
              title: 'Wishlist',
              onTap: () {},
            ),
            _AccountMenuItem(
              icon: Icons.location_on_outlined,
              title: 'Addresses',
              onTap: () {},
            ),
            _AccountMenuItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context
                      .read<AccountBloc>()
                      .add(const AccountLogoutRequested());
                },
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
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<AccountBloc>().add(const AccountLoaded()),
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
