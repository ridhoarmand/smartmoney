import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../../auth/repositories/auth_repository.dart';

class ListTileSignOut extends ConsumerWidget {
  const ListTileSignOut({
    super.key,
    required this.authRepository,
  });

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
      onTap: () async {
        try {
          await authRepository.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logout success'),
              duration: Duration(seconds: 3),
            ),
          );
          // Periksa apakah user sudah logout
          if (!ref.read(authRepositoryProvider).isSignedIn) {
            // Navigasi ke halaman login
            context.go('/signin');
          }
        } catch (e) {
          // Tangani kesalahan jika ada
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to logout: $e'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
    );
  }
}
