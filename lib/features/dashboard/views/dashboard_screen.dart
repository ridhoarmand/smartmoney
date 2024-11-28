import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import intl package
import 'package:smartmoney/features/transaction/service_providers/transaction_service_providers.dart';
import 'package:smartmoney/features/transaction/views/update_transaction_screen.dart';

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
      symbol: 'Rp ', // Simbol mata uang
      decimalDigits: 0, // Jumlah digit desimal
    );
    return formatCurrency.format(value);
  }

  Map<String, List> groupTransactionsByDate(List transactions) {
    final Map<String, List> groupedTransactions = {};
    for (var transaction in transactions) {
      // Format tanggal transaksi menjadi yyyy-MM-dd
      final dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);
      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(transaction);
    }
    return groupedTransactions;
  }

  List removeOldTransactions(List transactions) {
    final currentDate = DateTime.now();
    final todayStart = DateTime(currentDate.year, currentDate.month,
        currentDate.day); // Mulai hari ini pukul 00:00
    final tomorrowStart =
        todayStart.add(const Duration(days: 1)); // Mulai besok pukul 00:00

    // Filter transaksi yang hanya terjadi hari ini atau setelahnya
    return transactions.where((transaction) {
      final transactionDate = transaction.date;
      // Pastikan transaksi dari hari ini atau yang lebih baru disertakan
      return transactionDate.isAfter(todayStart.subtract(const Duration(days: 1))) ||
          isSameDay(transactionDate, todayStart);
    }).toList();
  }

  // Fungsi untuk memeriksa apakah dua tanggal adalah hari yang sama
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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

    // Total balance logic
    final totalBalance =
        wallets.fold(0.0, (sum, wallet) => sum + wallet.balance.toDouble());
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
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          // Wrap the entire body in a SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
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
                        // Wallet Selector with Decoration
                        Container(
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
                                ...wallets.map((wallet) {
                                  return DropdownMenuItem<Wallet?>(
                                    value: wallet,
                                    child: Text(
                                      "${wallet.name}",
                                      style: TextStyle(
                                          color: onPrimary, fontSize: 15),
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${selectedWallet == null ? "All Wallets" : selectedWallet!.name} Balance',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(color: onPrimary),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            formatToRupiah(
                                displayedBalance), // Format balance to Rupiah
                            style: theme.textTheme.headlineMedium?.copyWith(
                                color: onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  height: 30,
                  decoration:  BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: primaryColor, width: 1))),
                  child:  const Text(
                    'Jenis',
                    style: TextStyle(
                       
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 25,),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                           onTap: (){},
                          child: Container(
                            width: 80,
                            height: 70,
                            decoration: BoxDecoration(
                              color: secondaryColor,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [BoxShadow(color: onPrimary, blurRadius: 5,spreadRadius: (0.2))]
                            ),
                            child:  Align(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.pie_chart, color: onPrimary),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'Grafik',
                                    style: TextStyle(
                                        fontSize: 10,color: onPrimary),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                           onTap: (){},
                          child: Container(
                            width: 80,
                            height: 70,
                            decoration: BoxDecoration(
                              color: secondaryColor,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5,spreadRadius: (0.2))]
                            ),
                            child:  Align(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.category, color: onPrimary),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'Categories',
                                    style: TextStyle(
                                        fontSize: 10,color: onPrimary),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                         onTap: (){},
                          child: Container(
                            width: 80,
                            height: 70,
                            decoration: BoxDecoration(
                               color: secondaryColor,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5,spreadRadius: (0.2))]
                            ),
                             child:  Align(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.wallet, color:onPrimary),
                                  const SizedBox(height: 5,),
                                  Text('e-wallet', style: TextStyle(fontSize: 10, color: onPrimary),)
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  height: 30,
                  decoration:  BoxDecoration(
                      border: Border(
                          bottom: BorderSide( color: primaryColor,width: 1))),
                  child:  const Text(
                    'Riwayat Transaksi',
                    style: TextStyle(
                     
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              // Replace Expanded with ListView here
              transactionAsyncValue.when(
                data: (transactions) {
                  final filteredTransactions =
                      removeOldTransactions(transactions);

                  if (filteredTransactions.isEmpty) {
                    return const Center(
                        child: Text('No transactions available.'));
                  }

                  final groupedTransactions =
                      groupTransactionsByDate(filteredTransactions);

                  return ListView.builder(
                    shrinkWrap:
                        true, // Prevents ListView from expanding beyond the available space
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable scrolling on the ListView itself
                    itemCount: groupedTransactions.length,
                    itemBuilder: (context, index) {
                      final date = groupedTransactions.keys.elementAt(index);
                      final dateTransactions = groupedTransactions[date]!;

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
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('dd MMM yyyy')
                                        .format(DateTime.parse(date)),
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (totalIncome > 0)
                                        Text(
                                          'Income: + ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: totalIncome == totalIncome.toInt() ? 0 : 2).format(totalIncome)}',
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 12),
                                        ),
                                      if (totalIncome > 0 && totalExpense > 0)
                                        const Text(' • ',
                                            style: TextStyle(fontSize: 12)),
                                      if (totalExpense > 0)
                                        Text(
                                          'Expense: - ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: totalExpense == totalExpense.toInt() ? 0 : 2).format(totalExpense)}',
                                          style: const TextStyle(
                                              color: Colors.red, fontSize: 12),
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
                                      Text(transaction.walletName,
                                          style: const TextStyle(fontSize: 12)),
                                      Text(
                                        '${transaction.categoryType == 'Income' ? '+' : '-'} ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: transaction.amount == transaction.amount.toInt() ? 0 : 2).format(transaction.amount)}',
                                        style: TextStyle(
                                          color: transaction.categoryType ==
                                                  'Income'
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
