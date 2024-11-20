import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import 'widgets/listtile_darkmode.dart';
import 'widgets/listtile_edit_profile.dart';
import 'widgets/listtile_signout.dart';
import 'widgets/listtile_wallet.dart';

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

    return SizedBox.expand(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ListTileEditProfil(authRepository: authRepository),
            const Divider(),
            ListTileWallet(uid: authRepository.currentUser!.uid),
            const Divider(),
            const ListTileDarkMode(),
            const Divider(),
            ListTileSignOut(authRepository: authRepository),
          ],
        ),
      ),
    );
  }
}
