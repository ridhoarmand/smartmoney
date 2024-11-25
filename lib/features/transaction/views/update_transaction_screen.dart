import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/auth_provider.dart';
import '../service_providers/transaction_service_providers.dart';
import 'category_selection_screen.dart';
import 'wallet_selection_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../transaction/models/user_transaction_model.dart';

class UpdateTransactionScreen extends ConsumerStatefulWidget {
  final String transactionId;
  final UserTransaction transaction;

  const UpdateTransactionScreen({
    super.key,
    required this.transactionId,
    required this.transaction,
  });

  @override
  ConsumerState<UpdateTransactionScreen> createState() =>
      _UpdateTransactionScreenState();
}

class _UpdateTransactionScreenState
    extends ConsumerState<UpdateTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedCategoryType;
  String? _selectedWallet;
  String? _selectedWalletId;
  late DateTime _selectedDate;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.transaction.amount.toString());
    _descriptionController =
        TextEditingController(text: widget.transaction.description);
    _selectedCategoryId = widget.transaction.categoryId;
    _selectedCategoryName = widget.transaction.categoryName;
    _selectedCategoryType = widget.transaction.categoryType;
    _selectedWallet = widget.transaction.walletName;
    _selectedWalletId = widget.transaction.walletId;
    _selectedDate = widget.transaction.date;
    _imagePath = widget.transaction.imagePath;
  }

  Future<void> _updateTransaction(String uid) async {
  if (_formKey.currentState!.validate() &&
      _selectedCategoryType != null &&
      _selectedWalletId != null) {
    final transactionService = ref.read(updateTransactionProvider);

    try {
      final walletCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('wallets');

      final oldWalletRef = walletCollection.doc(widget.transaction.walletId);
      final newWalletRef = walletCollection.doc(_selectedWalletId);

      // Ambil data dompet lama
      final oldWalletSnapshot = await oldWalletRef.get();
      if (!oldWalletSnapshot.exists) {
        throw Exception('Old wallet not found');
      }
      final oldWalletData = oldWalletSnapshot.data()!;
      double oldWalletBalance = oldWalletData['balance'] as double;

      // Ambil data dompet baru (jika berbeda)
      double newWalletBalance = 0.0;
      if (_selectedWalletId != widget.transaction.walletId) {
        final newWalletSnapshot = await newWalletRef.get();
        if (!newWalletSnapshot.exists) {
          throw Exception('New wallet not found');
        }
        final newWalletData = newWalletSnapshot.data()!;
        newWalletBalance = newWalletData['balance'] as double;
      }

      // Nominal lama dan baru
      final oldAmount = widget.transaction.amount;
      final newAmount = double.parse(_amountController.text);

      // Update saldo dompet lama jika wallet berubah
      if (_selectedWalletId != widget.transaction.walletId) {
        if (widget.transaction.categoryType == 'Income') {
          oldWalletBalance -= oldAmount; // Kembalikan saldo lama jika income
        } else {
          oldWalletBalance += oldAmount; // Tambahkan saldo lama jika expense
        }
        await oldWalletRef.update({'balance': oldWalletBalance});
      }

      // Update saldo dompet baru
      if (_selectedWalletId != widget.transaction.walletId) {
        if (_selectedCategoryType == 'Income') {
          newWalletBalance += newAmount; // Tambahkan saldo baru jika income
        } else {
          newWalletBalance -= newAmount; // Kurangi saldo baru jika expense
        }
        await newWalletRef.update({'balance': newWalletBalance});
      } else {
        // Jika wallet sama, langsung update saldo
        double balanceAdjustment = newAmount - oldAmount;
        if (_selectedCategoryType == 'Income') {
          oldWalletBalance += balanceAdjustment;
        } else {
          oldWalletBalance -= balanceAdjustment;
        }
        await oldWalletRef.update({'balance': oldWalletBalance});
      }

      // Simpan perubahan transaksi
      await transactionService.updateTransaction(
        uid: uid,
        transactionId: widget.transactionId,
        type: _selectedCategoryType!,
        amount: newAmount,
        categoryId: _selectedCategoryId!,
        categoryName: _selectedCategoryName!,
        categoryType: _selectedCategoryType!,
        description: _descriptionController.text,
        date: _selectedDate,
        walletId: _selectedWalletId!,
        walletName: _selectedWallet!,
        imagePath: _imagePath,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction updated successfully!')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update transaction: $error')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please complete all required fields.')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authRepositoryProvider).currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Update Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount.';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Category'),
                  subtitle: Text(_selectedCategoryName ?? 'Select a category'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final selectedCategory =
                        await Navigator.push<Map<String, String>?>(context,
                            MaterialPageRoute(builder: (_) {
                      return const CategorySelectionScreen();
                    }));
                    if (selectedCategory != null) {
                      setState(() {
                        _selectedCategoryId = selectedCategory['id'];
                        _selectedCategoryName = selectedCategory['name'];
                        _selectedCategoryType = selectedCategory['type'];
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Wallet'),
                  subtitle: Text(_selectedWallet ?? 'Select a wallet'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final selectedWallet =
                        await Navigator.push<Map<String, String>?>(context,
                            MaterialPageRoute(builder: (_) {
                      return const WalletSelectionScreen();
                    }));
                    if (selectedWallet != null) {
                      setState(() {
                        _selectedWalletId = selectedWallet['id'];
                        _selectedWallet = selectedWallet['name'];
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date: ${DateFormat('EEEE, dd/MM/yyyy').format(_selectedDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _selectedDate = pickedDate;
                          });
                        }
                      },
                      child: const Text('Select Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _updateTransaction(uid),
                    child: const Text('Update Transaction'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
