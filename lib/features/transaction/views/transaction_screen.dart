import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../category/models/category.dart';
import '../../category/service_providers/category_service_provider.dart';
import '../service_providers/transaction_service_providers.dart';

/// **TransactionScreen**
/// Menampilkan daftar transaksi dengan kategori terkait.
class TransactionScreen extends ConsumerWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authRepositoryProvider).currentUser!.uid;

    // Stream data transaksi dari provider
    final transactionAsyncValue = ref.watch(transactionStreamProvider(uid));

    // Stream kategori dari provider
    final categoryAsyncValue = ref.watch(categoryStreamProvider(uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Aksi filter transaksi jika diperlukan
            },
          ),
        ],
      ),
      body: transactionAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading transactions: $error')),
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(child: Text('No transactions available.'));
          }

          return categoryAsyncValue.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) =>
                Center(child: Text('Error loading categories: $error')),
            data: (categories) {
              return ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];

                  // Check if categoryId is valid and find the category
                  final category = categories.firstWhere(
                    (cat) => cat.id == transaction.categoryId,
                    orElse: () => Category(
                      id: '',
                      name: 'Uncategorized',
                      type: 'none',
                      icon: Icons.help,
                    ),
                  );

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          category.type == 'income' ? Colors.green : Colors.red,
                      child: Icon(
                        category.icon,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(category.name),
                    subtitle: Text(transaction.description),
                    trailing: Text(
                      '${category.type == 'income' ? '+' : '-'} ${transaction.amount}',
                      style: TextStyle(
                        color: category.type == 'income'
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      // Handle onTap for imagePath or other functionality
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
