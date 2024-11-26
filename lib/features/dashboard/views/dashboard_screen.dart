import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import intl package

import '../../wallet/service_providers/wallet_service_provider.dart';
import '../../wallet/models/wallet.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

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

  // Function to format balance into Rupiah
  String formatToRupiah(double value) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID', // Format untuk Indonesia
      symbol: 'Rp ',  // Simbol mata uang
      decimalDigits: 0, // Jumlah digit desimal
    );
    return formatCurrency.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final wallets = ref.watch(walletProvider);

    // Total balance logic
    final totalBalance = wallets.fold(0.0, (sum, wallet) => sum + wallet.balance.toDouble());
    final displayedBalance = selectedWallet == null
        ? totalBalance
        : selectedWallet?.balance.toDouble() ?? 0.0;

    // Access theme colors
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    final onPrimary = theme.colorScheme.onPrimary;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user?.displayName ?? "User"}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card UI for balance and wallet selection
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wallet Selector with Decoration
                    Container(
                      decoration: BoxDecoration(
                        color: secondaryColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: onPrimary, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Wallet?>(
                          value: selectedWallet,
                          isExpanded: true,
                          dropdownColor: secondaryColor,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          style: TextStyle(color: onPrimary, fontSize: 16),
                          items: [
                            DropdownMenuItem<Wallet?>(
                              value: null,
                              child: Text("All Wallets", style: TextStyle(color: onPrimary)),
                            ),
                            ...wallets.map((wallet) {
                              return DropdownMenuItem<Wallet?>(
                                value: wallet,
                                child: Text(
                                  "${wallet.name}",
                                  style: TextStyle(color: onPrimary),
                                ),
                              );
                            }).toList(),
                          ],
                          onChanged: (Wallet? wallet) {
                            setState(() {
                              selectedWallet = wallet;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Balance Display
                    Text(
                      '${selectedWallet == null ? "All Wallets" : selectedWallet!.name} Balance',
                      style: theme.textTheme.titleLarge?.copyWith(color: onPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatToRupiah(displayedBalance), // Format balance to Rupiah
                      style: theme.textTheme.headlineMedium?.copyWith(
                          color: onPrimary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
