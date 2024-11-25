import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/wallet.dart';
import '../providers/wallet_provider.dart';
import 'currency_secelction_screen.dart';

class AddEditWalletScreen extends ConsumerStatefulWidget {
  final Wallet? wallet;
  final String uid;

  const AddEditWalletScreen({super.key, this.wallet, required this.uid});

  @override
  ConsumerState<AddEditWalletScreen> createState() =>
      _AddEditWalletScreenState();
}

class _AddEditWalletScreenState extends ConsumerState<AddEditWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  late String _currency;
  IconData _selectedIcon = Icons.account_balance_wallet;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wallet?.name ?? '');
    _balanceController = TextEditingController(
      text: widget.wallet?.balance != null
          ? NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 2)
              .format(widget.wallet!.balance)
          : '0',
    );
    _currency = widget.wallet?.currency ?? 'Rupiah';
    _selectedIcon = widget.wallet?.icon ?? Icons.account_balance_wallet;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wallet == null ? 'Add Wallet' : 'Edit Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newWallet = Wallet(
                  id: widget.wallet?.id ?? '',
                  name: _nameController.text,
                  currency: _currency,
                  balance:
                      double.parse(_balanceController.text.replaceAll(',', '')),
                  icon: _selectedIcon,
                );
                ref
                    .read(walletProvider.notifier)
                    .addOrUpdateWallet(widget.uid, newWallet);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final selectedIcon = await _showIconPickerDialog(context);
                      if (selectedIcon != null) {
                        setState(() {
                          _selectedIcon = selectedIcon;
                        });
                      }
                    },
                    child: Icon(_selectedIcon, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: 'Wallet Name'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter wallet name'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final selectedCurrency = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CurrencySelectionScreen(),
                    ),
                  );
                  if (selectedCurrency != null) {
                    setState(() {
                      _currency = selectedCurrency;
                    });
                  }
                },
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(child: Text('Currency: $_currency')),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _balanceController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ThousandsSeparatorInputFormatter(),
                ],
                decoration: const InputDecoration(labelText: 'Balance'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter balance';
                  if (double.tryParse(value.replaceAll(',', '')) == null) {
                    return 'Enter valid number';
                  }
                  return null;
                },
              ),
              const Spacer(),
              if (widget.wallet != null)
                TextButton(
                  onPressed: () {
                    ref
                        .read(walletProvider.notifier)
                        .deleteWallet(widget.uid, widget.wallet!.id);
                    Navigator.pop(context);
                  },
                  child: const Text('Delete Wallet',
                      style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // A method to show an icon picker dialog
  Future<IconData?> _showIconPickerDialog(BuildContext context) async {
    List<IconData> iconsList = [
      Icons.account_balance_wallet,
      Icons.credit_card,
      Icons.wallet_giftcard,
      Icons.money,
      Icons.attach_money,
      Icons.account_box,
      Icons.shopping_bag,
      Icons.business,
      Icons.store,
      Icons.paid,
    ];

    return showDialog<IconData>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Icon'),
          content: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
            ),
            itemCount: iconsList.length,
            itemBuilder: (context, index) {
              final icon = iconsList[index];
              return IconButton(
                icon: Icon(icon),
                onPressed: () {
                  Navigator.pop(context, icon);
                },
              );
            },
          ),
        );
      },
    );
  }
}

// Custom input formatter for thousands separator
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove any existing commas
    String newText = newValue.text.replaceAll(',', '');

    // Format with thousands separator
    final formatter = NumberFormat('#,###');
    final formattedText = formatter.format(int.parse(newText));

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
