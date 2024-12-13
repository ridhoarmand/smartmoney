import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import 'widgets/listtile_about_apps.dart';
import 'widgets/listtile_darkmode.dart';
import 'widgets/listtile_edit_profile.dart';
import 'widgets/listtile_signout.dart';
import 'widgets/listtile_wallet.dart';
import 'widgets/listtile_change_email.dart';
import 'widgets/listtile_change_password.dart';

class AppbarAccountScreen extends StatelessWidget
    implements PreferredSizeWidget {
  const AppbarAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Account'),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class BodyAccountScreen extends ConsumerWidget {
  const BodyAccountScreen({super.key});

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
            ListTileChangeEmail(user: authRepository.currentUser!),
            const Divider(),
            ListTileChangePassword(user: authRepository.currentUser!),
            const Divider(),
            const ListTileDarkMode(),
            const Divider(),
            const ListTileAboutApps(),
            const Divider(),
            ListTileSignOut(authRepository: authRepository),
          ],
        ),
      ),
    );
  }
}
