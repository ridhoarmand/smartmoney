import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/snackbar_helper.dart';

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
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      size: 35,
                      color: Theme.of(context).iconTheme.color,
                    );
                  },
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
          // Memperbarui state profil pengguna
          ref.invalidate(authRepositoryProvider);
          ref.read(authRepositoryProvider);

          SnackBarHelper.showSuccess(context, 'Profile updated successfully');
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showError(
            context, 'Error navigating to edit account: $e');
      }
    }
  }
}
