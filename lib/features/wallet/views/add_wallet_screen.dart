import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/wallet.dart';
import '../service_providers/wallet_service_provider.dart';
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
          ? widget.wallet!.balance.toString()
          : '',
    );
    _currency = widget.wallet?.currency ?? 'Rupiah';
    _selectedIcon = widget.wallet?.icon ?? Icons.account_balance_wallet;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wallet == null ? 'Tambah Dompet' : 'Edit Dompet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => _showIconPickerDialog(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_selectedIcon, color: Colors.blue, size: 40),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: 'Nama Dompet'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Masukkan nama dompet'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
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
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mata Uang: $_currency',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _balanceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Saldo',
                  hintText: '0.00',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan saldo';
                  }
                  try {
                    final amount = double.parse(value);
                    if (amount < 0) {
                      return 'Saldo tidak boleh negatif';
                    }
                  } catch (e) {
                    return 'Format saldo tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveWallet,
                child: const Text('Simpan'),
              ),
              if (widget.wallet != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _deleteWallet,
                  child: const Text(
                    'Hapus Dompet',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _saveWallet() {
    if (_formKey.currentState!.validate()) {
      final newWallet = Wallet(
        id: widget.wallet?.id ?? '',
        name: _nameController.text,
        currency: _currency,
        balance: double.parse(_balanceController.text),
        icon: _selectedIcon,
      );
      ref
          .read(walletProvider.notifier)
          .addOrUpdateWallet(widget.uid, newWallet);
      Navigator.pop(context);
    }
  }

  void _deleteWallet() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus dompet ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(walletProvider.notifier)
                  .deleteWallet(widget.uid, widget.wallet!.id);
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _showIconPickerDialog() async {
    final List<IconData> iconsList = [
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

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Ikon'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: iconsList.length,
            itemBuilder: (context, index) {
              final icon = iconsList[index];
              return InkWell(
                onTap: () {
                  setState(() => _selectedIcon = icon);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedIcon == icon ? Colors.grey[300] : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 32),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
