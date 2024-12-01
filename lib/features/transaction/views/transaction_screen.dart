import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../auth/providers/auth_provider.dart';
import "../../transaction/views/update_transaction_screen.dart";
import '../../wallet/service_providers/wallet_service_provider.dart';
import '../models/user_transaction_model.dart';
import '../service_providers/transaction_service_providers.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  String _searchQuery = '';
  bool _hideBalance = false;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, d MMMM y').format(date);
    }
  }

  bool _filterTransaction(UserTransaction transaction) {
    final selectedWallet = ref.watch(selectedWalletProvider);
    final searchLower = _searchQuery.toLowerCase();

    if (selectedWallet != 'All Wallets' &&
        transaction.walletId != selectedWallet) {
      return false;
    }

    return transaction.categoryName.toLowerCase().contains(searchLower) ||
        transaction.categoryType.toLowerCase().contains(searchLower) ||
        transaction.description.toLowerCase().contains(searchLower) ||
        transaction.amount.toString().contains(searchLower) ||
        transaction.walletName.toLowerCase().contains(searchLower);
  }

  Widget _buildWalletBalance(String uid) {
    return Consumer(
      builder: (context, ref, child) {
        final walletsAsyncValue = ref.watch(walletsStreamProvider(uid));
        final selectedWallet = ref.watch(selectedWalletProvider);

        return walletsAsyncValue.when(
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
          data: (wallets) {
            num totalBalance = 0;
            if (selectedWallet == 'All Wallets') {
              totalBalance = wallets.fold(
                  0, (sum, wallet) => sum + (wallet['balance'] ?? 0.0));
            } else {
              final selectedWalletData = wallets.firstWhereOrNull(
                (wallet) => wallet['id'] == selectedWallet,
              );
              totalBalance = selectedWalletData?['balance'] ?? 0.0;
            }

            return Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Total Balance',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Icon(_hideBalance
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _hideBalance = !_hideBalance;
                                });
                              },
                            ),
                          ],
                        ),
                        Text(
                          _hideBalance
                              ? '*********'
                              : NumberFormat.currency(
                                  locale: 'id_ID',
                                  symbol: 'Rp ',
                                  decimalDigits:
                                      totalBalance == totalBalance.toInt()
                                          ? 0
                                          : 2,
                                ).format(totalBalance),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _buildWalletDropdown(uid),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWalletDropdown(String uid) {
    return Consumer(
      builder: (context, ref, child) {
        final walletsAsyncValue = ref.watch(walletsStreamProvider(uid));

        return walletsAsyncValue.when(
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
          data: (wallets) {
            return DropdownButton<String>(
              isExpanded: false,
              value: ref.watch(selectedWalletProvider),
              items: [
                const DropdownMenuItem(
                  value: 'All Wallets',
                  child: Text('All Wallets'),
                ),
                ...wallets.map((wallet) => DropdownMenuItem(
                      value: wallet['id'] as String,
                      child: Text(wallet['name'] as String),
                    )),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(selectedWalletProvider.notifier).state = value;
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authRepositoryProvider).currentUser!.uid;
    final transactionAsyncValue = ref.watch(transactionStreamProvider(uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: Column(
        children: [
          _buildWalletBalance(uid),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search transactions...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: transactionAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('Error loading transactions: $error')),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Center(
                      child: Text('No transactions available.'));
                }

                final filteredTransactions =
                    transactions.where(_filterTransaction).toList();

                if (filteredTransactions.isEmpty) {
                  return const Center(
                      child: Text('No matching transactions found.'));
                }

                final groupedTransactions = groupBy(
                  filteredTransactions,
                  (transaction) => _formatDate(transaction.date),
                );

                return ListView.builder(
                  itemCount: groupedTransactions.length,
                  itemBuilder: (context, index) {
                    final date = groupedTransactions.keys.elementAt(index);
                    final dateTransactions = groupedTransactions[date]!;

                    num totalIncome = 0;
                    num totalExpense = 0;
                    for (var transaction in dateTransactions) {
                      if (transaction.categoryType == 'Income') {
                        totalIncome += transaction.amount;
                      } else {
                        totalExpense += transaction.amount;
                      }
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  date,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (totalIncome > 0)
                                      Text(
                                        'Income: + ${NumberFormat.currency(
                                          locale: 'id_ID',
                                          symbol: 'Rp ',
                                          decimalDigits:
                                              totalIncome == totalIncome.toInt()
                                                  ? 0
                                                  : 2,
                                        ).format(totalIncome)}',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                        ),
                                      ),
                                    if (totalIncome > 0 && totalExpense > 0)
                                      const Text(' • ',
                                          style: TextStyle(fontSize: 12)),
                                    if (totalExpense > 0)
                                      Text(
                                        'Expense: - ${NumberFormat.currency(
                                          locale: 'id_ID',
                                          symbol: 'Rp ',
                                          decimalDigits: totalExpense ==
                                                  totalExpense.toInt()
                                              ? 0
                                              : 2,
                                        ).format(totalExpense)}',
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: dateTransactions.length,
                            itemBuilder: (context, transactionIndex) {
                              final transaction =
                                  dateTransactions[transactionIndex];

                              return ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  backgroundColor:
                                      transaction.categoryType == 'Income'
                                          ? Colors.green
                                          : Colors.red,
                                  child: Icon(
                                    transaction.categoryType == 'Income'
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(transaction.categoryName),
                                subtitle: Text(transaction.description),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      transaction.walletName,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      '${transaction.categoryType == 'Income' ? '+' : '-'} ${NumberFormat.currency(
                                        locale: 'id_ID',
                                        symbol: 'Rp ',
                                        decimalDigits: transaction.amount ==
                                                transaction.amount.toInt()
                                            ? 0
                                            : 2,
                                      ).format(transaction.amount)}',
                                      style: TextStyle(
                                        color:
                                            transaction.categoryType == 'Income'
                                                ? Colors.green
                                                : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UpdateTransactionScreen(
                                        transaction: transaction,
                                        transactionId: transaction.id,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
