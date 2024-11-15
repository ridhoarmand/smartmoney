import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/provider/auth_provider.dart';
import '../widget/listtile_darkmode.dart';
import '../widget/listtile_edit_profile.dart';
import '../widget/listtile_signout.dart';

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

    print(authRepository.currentUser);

    return SizedBox.expand(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ListTileEditProfil(authRepository: authRepository),
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
