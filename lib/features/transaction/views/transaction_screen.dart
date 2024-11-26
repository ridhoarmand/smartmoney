import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/user_transaction_model.dart';
import '../service_providers/transaction_service_providers.dart';
import "../../transaction/views/update_transaction_screen.dart";

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  String _searchQuery = '';

  // Helper method to format date for grouping
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

  // Helper method to filter transactions
  bool _filterTransaction(UserTransaction transaction) {
    final searchLower = _searchQuery.toLowerCase();
    return transaction.categoryName.toLowerCase().contains(searchLower) ||
        transaction.categoryType.toLowerCase().contains(searchLower) ||
        transaction.description.toLowerCase().contains(searchLower) ||
        transaction.amount.toString().contains(searchLower) ||
        transaction.walletName.toLowerCase().contains(searchLower);
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authRepositoryProvider).currentUser!.uid;
    final transactionAsyncValue = ref.watch(transactionStreamProvider(uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction List'),
      ),
      body: Column(
        children: [
          // Search and filter row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
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
              ],
            ),
          ),
          // Transactions list
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

                // Filter transactions based on search query
                final filteredTransactions =
                    transactions.where(_filterTransaction).toList();

                if (filteredTransactions.isEmpty) {
                  return const Center(
                      child: Text('No matching transactions found.'));
                }

                // Group transactions by date
                final groupedTransactions = groupBy(
                  filteredTransactions,
                  (transaction) => _formatDate(transaction.date),
                );

                return ListView.builder(
                  itemCount: groupedTransactions.length,
                  itemBuilder: (context, index) {
                    final date = groupedTransactions.keys.elementAt(index);
                    final dateTransactions = groupedTransactions[date]!;

                    // Calculate total income and expense for the date
                    double totalIncome = 0;
                    double totalExpense = 0;
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
                          // Date header with summary
                          Padding(
                            padding: const EdgeInsets.all(12),
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
                          // Transactions list for this date
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: dateTransactions.length,
                            itemBuilder: (context, transactionIndex) {
                              final transaction =
                                  dateTransactions[transactionIndex];

                              return ListTile(
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
