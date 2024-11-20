import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/transaction_provider.dart';

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
  String _selectedType = 'Income';
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  Future<void> _submitTransaction(String uid) async {
    if (_formKey.currentState!.validate()) {
      final transactionService = ref.read(transactionServiceProvider);
      await transactionService.createTransaction(
        uid: uid,
        type: _selectedType,
        amount: double.parse(_amountController.text),
        category: _selectedCategory!,
        description: _descriptionController.text,
        date: _selectedDate,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction added successfully!')),
      );

      Navigator.of(context).pop();
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ChoiceChip(
                      label: const Text('Income'),
                      selected: _selectedType == 'Income',
                      onSelected: (_) => setState(() {
                        _selectedType = 'Income';
                      }),
                    ),
                    ChoiceChip(
                      label: const Text('Expense'),
                      selected: _selectedType == 'Expense',
                      onSelected: (_) => setState(() {
                        _selectedType = 'Expense';
                      }),
                    ),
                  ],
                ),
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
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value),
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Food',
                      child: Text('Food'),
                    ),
                    DropdownMenuItem(
                      value: 'Transport',
                      child: Text('Transport'),
                    ),
                    DropdownMenuItem(
                      value: 'Shopping',
                      child: Text('Shopping'),
                    ),
                    DropdownMenuItem(
                      value: 'Health',
                      child: Text('Health'),
                    ),
                    DropdownMenuItem(
                      value: 'Entertainment',
                      child: Text('Entertainment'),
                    ),
                    DropdownMenuItem(
                      value: 'Others',
                      child: Text('Others'),
                    ),
                  ],
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
                      'Date: ${_selectedDate.toLocal()}'.split(' ')[0],
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
