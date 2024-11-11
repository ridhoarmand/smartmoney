import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/provider/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepository = ref.read(authRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        elevation: 2,
      ),
      body:

          // Button sign out
          Column(
        children: [
          Text('Welcome, ${authRepository.currentUser?.email}'),
          ElevatedButton(
            onPressed: () {
              // Sign out
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
