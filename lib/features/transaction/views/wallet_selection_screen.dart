import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../wallet/models/wallet.dart';
import '../../wallet/providers/wallet_provider.dart';

class WalletSelectionScreen extends ConsumerStatefulWidget {
  const WalletSelectionScreen({super.key});

  @override
  WalletSelectionScreenState createState() => WalletSelectionScreenState();
}

class WalletSelectionScreenState extends ConsumerState<WalletSelectionScreen> {
  late final String uid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      uid = ref.read(authRepositoryProvider).currentUser!.uid;
      ref.read(walletProvider.notifier).fetchWallets(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Wallet'),
      ),
      body: _buildWalletView(wallets),
    );
  }

  Widget _buildWalletView(List<Wallet> wallets) {
    if (wallets.isEmpty) {
      return const Center(child: Text('No wallets available.'));
    }

    return ListView.builder(
      itemCount: wallets.length,
      itemBuilder: (context, index) {
        final wallet = wallets[index];

        return ListTile(
          leading: Icon(wallet.icon),
          title: Text(wallet.name),
          onTap: () {
            Navigator.pop(context, {
              'id': wallet.id, // Kirim ID dompet
              'name': wallet.name, // Kirim nama dompet
            }); // Return the wallet name
          },
        );
      },
    );
  }
}
