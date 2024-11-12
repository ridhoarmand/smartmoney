import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/provider/auth_provider.dart';

// Widget untuk AppBar di halaman Profile
class AppbarProfileScreen extends StatelessWidget
    implements PreferredSizeWidget {
  const AppbarProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Profile'),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Widget untuk Body di halaman Profile
class BodyProfileScreen extends ConsumerWidget {
  const BodyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepository = ref.read(authRepositoryProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Welcome, ${authRepository.currentUser?.email}'),
          ElevatedButton(
            onPressed: () {
              // Proses sign out
              authRepository.signOut();
              context.go('/signin');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
