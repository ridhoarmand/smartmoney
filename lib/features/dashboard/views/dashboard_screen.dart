import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transaction/service_providers/transaction_service_providers.dart';
import '../../wallet/models/wallet.dart';
import '../../wallet/service_providers/wallet_service_provider.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/report_card.dart';
import 'widgets/top_spending.dart';
import 'widgets/wallet_balance_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Wallet? selectedWallet;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await ref.read(walletProvider.notifier).fetchWallets(uid);
      }
    });
  }

  void _handleWalletSelection(Wallet? wallet) {
    setState(() {
      selectedWallet = wallet;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Dashboard')),
          body: const Center(child: Text('No user logged in')));
    }

    final wallets = ref.watch(walletProvider);
    final transactionAsyncValue = ref.watch(transactionStreamProvider(uid));

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user?.displayName ?? "User"}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WalletBalanceCard(
                  wallets: wallets, onWalletSelected: _handleWalletSelection),
              transactionAsyncValue.when(
                data: (transactions) {
                  final filteredTransactions = selectedWallet != null
                      ? transactions
                          .where((t) => t.walletId == selectedWallet!.id)
                          .toList()
                      : transactions;

                  return Column(
                    children: [
                      if (filteredTransactions.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'No Transactions Found',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        )
                      else ...[
                        ReportCardWidget(selectedWallet: selectedWallet),
                        TopSpendingWidget(selectedWallet: selectedWallet),
                        RecentTransactionsWidget(
                            selectedWallet: selectedWallet),
                      ],
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
