import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/wallet_provider.dart';
import 'add_wallet_screen.dart';

class WalletScreen extends ConsumerStatefulWidget {
  final String uid;

  const WalletScreen({super.key, required this.uid});

  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends ConsumerState<WalletScreen> {
  @override
  void initState() {
    super.initState();
    // Memanggil fungsi fetchWallets saat tampilan pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletProvider.notifier).fetchWallets(widget.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/account'),
        ),
        title: const Text('My Wallets'),
      ),
      body: wallets.isEmpty
          ? const Center(child: Text('No wallets found.'))
          : ListView.builder(
              itemCount: wallets.length,
              itemBuilder: (context, index) {
                final wallet = wallets[index];
                final balance = NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: wallet.currency == 'Rupiah' ? 'Rp ' : '\$',
                  decimalDigits: wallet.balance == wallet.balance.toInt()
                      ? 0
                      : 2, // Adjust decimal places
                ).format(wallet.balance);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey.shade100,
                    child: Icon(wallet.icon, color: Colors.blue),
                  ),
                  title: Row(
                    children: [
                      Text(wallet.name),
                    ],
                  ),
                  subtitle: Text(balance),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditWalletScreen(
                            uid: widget.uid, wallet: wallet),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditWalletScreen(uid: widget.uid),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
