import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';

class TransactionScreen extends ConsumerWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ambil UID dari providers auth
    final uid = ref.watch(authRepositoryProvider).currentUser!.uid;

    // Ambil data transaksi dari providers
    final transactionAsyncValue = ref.watch(transactionListProvider(uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Aksi filter transaksi
            },
          ),
        ],
      ),
      body: transactionAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(child: Text('No transactions available.'));
          }
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      transaction.type == 'Income' ? Colors.green : Colors.red,
                  child: Icon(
                    transaction.type == 'Income'
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: Colors.white,
                  ),
                ),
                title: Text(transaction.description ?? 'No Description'),
                subtitle: Text(
                  '${transaction.category} • ${transaction.date.toLocal()}'
                      .split(' ')[0],
                ),
                trailing: Text(
                  '${transaction.type == 'Income' ? '+' : '-'} ${transaction.amount}',
                  style: TextStyle(
                    color: transaction.type == 'Income'
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  // Aksi saat transaksi di-tap
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Arahkan ke AddTransactionScreen untuk menambah transaksi baru
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
