import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartmoney/features/transaction/views/transaction_filters_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../category/models/category.dart';
import '../../category/service_providers/category_service_provider.dart';
import '../service_providers/transaction_service_providers.dart';

/// **TransactionScreen**
/// Menampilkan daftar transaksi dengan fitur pencarian yang tidak full layar.
class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authRepositoryProvider).currentUser!.uid;

    // Stream data transaksi dari provider
    final transactionAsyncValue = ref.watch(transactionStreamProvider(uid));

    // Stream kategori dari provider
    final categoryAsyncValue = ref.watch(categoryStreamProvider(uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction List'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.analytics),
        //     onPressed: () {
        //       // Aksi filter transaksi jika diperlukan
        //     },
        //   ),
        // ],
      ),
      body: Column(
        children: [
          // Baris pencarian dan tombol filter
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Input pencarian
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
                                  _searchQuery = ''; // Reset pencarian
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery =
                            value.toLowerCase(); // Simpan query pencarian
                      });
                    },
                  ),
                ),
                const SizedBox(
                    width: 8), // Jarak antara input dan tombol filter
                // Tombol filter
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () async {
                    final filterResult = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionFilterScreen(
                          onApplyFilter: (filterData) {
                            setState(() {
                              // Perbarui state filter di TransactionScreen
                              var timeRange = filterData['timeRange'];
                              var transactionType =
                                  filterData['transactionType'];
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Body dengan daftar transaksi
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

                // Filter transaksi berdasarkan query pencarian
                final filteredTransactions = transactions.where((transaction) {
                  return transaction.description
                      .toLowerCase()
                      .contains(_searchQuery);
                }).toList();

                return categoryAsyncValue.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) =>
                      Center(child: Text('Error loading categories: $error')),
                  data: (categories) {
                    return ListView.builder(
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];

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
                            backgroundColor: category.type == 'income'
                                ? Colors.green
                                : Colors.red,
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
                            if (transaction.imagePath != null) {
                              print('Image path: ${transaction.imagePath}');
                            }
                          },
                        );
                      },
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

  void applyFilter(filterResult) {}
}
