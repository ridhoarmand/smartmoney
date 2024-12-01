import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../../transaction/service_providers/transaction_service_providers.dart';
import '../../../transaction/views/update_transaction_screen.dart';

class RecentTransactionsWidget extends ConsumerWidget {
  const RecentTransactionsWidget({super.key});

  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.isAfter(today)) {
      return 'Today';
    } else if (date.isAfter(yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authRepositoryProvider).currentUser?.uid;

    if (uid == null) {
      return const SizedBox.shrink();
    }

    return ref.watch(transactionStreamProvider(uid)).when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return const SizedBox.shrink();
            }

            // Sort and take top 3 transactions
            final recentTransactions = transactions.take(3).toList();

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/transactions'),
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = recentTransactions[index];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: transaction.categoryType == 'Income'
                              ? Colors.green
                              : Colors.red,
                          child: Icon(
                            transaction.categoryType == 'Income'
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(transaction.description),
                        subtitle:
                            Text(_formatTransactionDate(transaction.date)),
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
                                color: transaction.categoryType == 'Income'
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
                              builder: (context) => UpdateTransactionScreen(
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
  }
}
