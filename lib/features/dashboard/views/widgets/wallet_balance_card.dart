import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../wallet/models/wallet.dart';
import '../../service_providers/dashboard_service_provider.dart';

class WalletBalanceCard extends ConsumerStatefulWidget {
  final List<Wallet> wallets;
  final Function(Wallet?) onWalletSelected;

  const WalletBalanceCard(
      {super.key, required this.wallets, required this.onWalletSelected});

  @override
  ConsumerState<WalletBalanceCard> createState() => _WalletBalanceCardState();
}

class _WalletBalanceCardState extends ConsumerState<WalletBalanceCard> {
  Wallet? selectedWallet;

  String formatToRupiah(double value) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(value);
  }

  String hideBalance(double value) {
    return "Rp *********";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    final onPrimary = theme.colorScheme.onPrimary;

    final isBalanceVisible = ref.watch(balanceVisibilityProvider);

    final totalBalance = widget.wallets
        .fold(0.0, (sum, wallet) => sum + wallet.balance.toDouble());

    final displayedBalance = selectedWallet == null
        ? totalBalance
        : selectedWallet?.balance.toDouble() ?? 0.0;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: secondaryColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: onPrimary, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Wallet?>(
                          value: selectedWallet,
                          isExpanded: true,
                          dropdownColor: secondaryColor,
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.white),
                          style: TextStyle(color: onPrimary, fontSize: 16),
                          items: [
                            DropdownMenuItem<Wallet?>(
                              value: null,
                              child: Text("All Wallets",
                                  style: TextStyle(color: onPrimary)),
                            ),
                            ...widget.wallets.map((wallet) {
                              return DropdownMenuItem<Wallet?>(
                                value: wallet,
                                child: Text(
                                  wallet.name,
                                  style:
                                      TextStyle(color: onPrimary, fontSize: 15),
                                ),
                              );
                            }),
                          ],
                          onChanged: (Wallet? wallet) {
                            setState(() {
                              selectedWallet = wallet;
                              widget.onWalletSelected(wallet);
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      '${selectedWallet == null ? "All Wallets" : selectedWallet!.name} Balance',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: onPrimary),
                    ),
                    IconButton(
                      icon: Icon(
                        isBalanceVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: onPrimary,
                      ),
                      onPressed: () {
                        ref
                            .read(balanceVisibilityProvider.notifier)
                            .toggleVisibility();
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  isBalanceVisible
                      ? formatToRupiah(displayedBalance)
                      : hideBalance(displayedBalance),
                  style: theme.textTheme.labelLarge?.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
