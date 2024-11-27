import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../../auth/repositories/auth_repository.dart';

class ListTileEditProfil extends ConsumerWidget {
  const ListTileEditProfil({
    super.key,
    required this.authRepository,
  });

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    return ListTile(
      contentPadding: const EdgeInsets.all(8),
      leading: CircleAvatar(
        radius: 35,
        backgroundColor: Theme.of(context).cardColor,
        child: ClipOval(
          child: user?.photoURL != null
              ? Image.network(
                  user!.photoURL!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person,
                    size: 35,
                    color: Theme.of(context).iconTheme.color,
                  ),
                )
              : Icon(
                  Icons.person,
                  size: 35,
                  color: Theme.of(context).iconTheme.color,
                ),
        ),
      ),
      title: Text(
        user?.displayName ?? 'No Name',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      subtitle: Text(
        user?.email ?? 'No Email',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () => _handleEditPress(context, ref, user),
      ),
    );
  }

  Future<void> _handleEditPress(
      BuildContext context, WidgetRef ref, user) async {
    try {
      final result = await context.push('/profile', extra: user);

      if (result == true) {
        if (context.mounted) {
          // Jika hasilnya true, artinya profil telah diperbarui.
          // Memperbarui state dengan memanggil ref.refresh untuk menyegarkan profil pengguna
          ref.refresh(authRepositoryProvider);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error navigating to edit account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
