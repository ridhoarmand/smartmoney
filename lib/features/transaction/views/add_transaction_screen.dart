import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import '../../auth/providers/auth_provider.dart';
import '../service_providers/transaction_service_providers.dart';
import 'category_selection_screen.dart';
import 'wallet_selection_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedCategoryType;
  String? _selectedWallet;
  String? _selectedWalletId;
  DateTime _selectedDate = DateTime.now();
  bool _includeImage = false;
  String? _imagePath;

  Future<void> _submitTransaction(String uid) async {
  if (_formKey.currentState!.validate() && _selectedCategoryType != null && _selectedWalletId != null) {
    final transactionService = ref.read(createTransactionProvider);

    try {
      // Step 1: Ambil saldo dompet dari Firestore
      final walletRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('wallets')
          .doc(_selectedWalletId);
      final walletSnapshot = await walletRef.get();
      if (!walletSnapshot.exists) {
        throw Exception('Selected wallet not found');
      }

      final walletData = walletSnapshot.data()!;
      final currentBalance = walletData['balance'] as double;

      // Step 2: Hitung saldo baru berdasarkan tipe transaksi
      final amount = double.parse(_amountController.text);
      double updatedBalance = currentBalance;
      if (_selectedCategoryType == 'Income') {
        updatedBalance += amount; // Tambah saldo untuk income
      } else if (_selectedCategoryType == 'Expense') {
        updatedBalance -= amount; // Kurangi saldo untuk expense
      }

      // Step 3: Simpan transaksi dan perbarui saldo dompet
      await transactionService.createTransaction(
        uid: uid,
        type: _selectedCategoryType!,
        amount: amount,
        categoryId: _selectedCategoryId!,
        description: _descriptionController.text,
        date: _selectedDate,
        walletId: _selectedWalletId!,
        imagePath: _imagePath,
      );

      await walletRef.update({'balance': updatedBalance}); // Update saldo

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction added successfully!')),
      );

      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add transaction: $error')),
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
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
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
                        await Navigator.push<Map<String, String>?>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CategorySelectionScreen(),
                      ),
                    );
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
                    final selectedWallet = await Navigator.push<Map<String,String>?>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WalletSelectionScreen(),
                      ),
                    );
                    if (selectedWallet != null) {
                      setState(() {
                        _selectedWalletId =
                            selectedWallet['id']; // Simpan ID dompet
                        _selectedWallet =
                            selectedWallet['name']; // Simpan nama dompet
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _includeImage,
                      onChanged: (value) =>
                          setState(() => _includeImage = value!),
                    ),
                    const Text('Include Attachment'),
                  ],
                ),
                if (_includeImage)
                  TextFormField(
                    onTap: () async {
                      // Simulate image picking
                      // Replace this with your image picker logic
                      setState(() {
                        _imagePath = 'path/to/image.jpg';
                      });
                    },
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Image Path',
                      prefixIcon: Icon(Icons.image),
                    ),
                  ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _submitTransaction(uid),
                    child: const Text('Save Transaction'),
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
