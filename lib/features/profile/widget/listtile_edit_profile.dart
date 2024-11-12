import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/provider/auth_provider.dart';
import '../../auth/repository/auth_repository.dart';

/// Widget untuk menampilkan bagian Edit Profile pada halaman profil
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
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) =>
                      Image.asset('assets/images/logo-icon.png'),
                )
              : Image.asset('assets/images/logo-icon.png'),
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
      final result = await context.push('/profile-edit', extra: user);

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
            content: Text('Error navigating to edit profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
