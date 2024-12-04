import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/user_transaction_model.dart';
import '../service_providers/transaction_service_providers.dart';
import 'category_selection_screen.dart';
import 'wallet_selection_screen.dart';

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
  dynamic _selectedImage;
  String? _imagePath;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final transaction = widget.transaction;
    _amountController =
        TextEditingController(text: transaction.amount.toString());
    _descriptionController =
        TextEditingController(text: transaction.description);
    _selectedCategoryId = transaction.categoryId;
    _selectedCategoryName = transaction.categoryName;
    _selectedCategoryType = transaction.categoryType;
    _selectedWallet = transaction.walletName;
    _selectedWalletId = transaction.walletId;
    _selectedDate = transaction.date;
    _imagePath = transaction.imagePath;
  }

  Future<void> _pickImage() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = kIsWeb ? image : File(image.path);
      });
    }
  }

  Future<String?> _uploadImage(String uid) async {
    if (_selectedImage == null) return _imagePath;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('transactions/${DateTime.now().millisecondsSinceEpoch}.jpg');

      final metadata = SettableMetadata(contentType: 'image/jpeg');

      if (kIsWeb) {
        if (_selectedImage is XFile) {
          final bytes = await (_selectedImage as XFile).readAsBytes();
          await storageRef.putData(bytes, metadata);
        }
      } else {
        await storageRef.putFile(_selectedImage as File, metadata);
      }

      return await storageRef.getDownloadURL();
    } catch (e) {
      _showSnackBar('Image upload failed: $e');
      return null;
    }
  }

  Future<void> _updateTransaction(String uid) async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please complete all required fields.');
      return;
    }

    if (_selectedCategoryType == null || _selectedWalletId == null) {
      _showSnackBar('Category and Wallet are required.');
      return;
    }

    final transactionService = ref.read(transactionServiceProvider);

    try {
      if (_selectedImage != null) {
        _imagePath = await _uploadImage(uid);
      }

      await transactionService.updateTransaction(
        uid: uid,
        transactionId: widget.transactionId,
        oldTransaction: widget.transaction,
        amount: double.parse(_amountController.text),
        categoryId: _selectedCategoryId!,
        categoryType: _selectedCategoryType!,
        description: _descriptionController.text,
        date: _selectedDate,
        walletId: _selectedWalletId!,
        imagePath: _imagePath,
      );

      _showSnackBar('Transaction updated successfully!');
      Navigator.of(context).pop();
    } catch (error) {
      _showSnackBar('Failed to update transaction: $error');
    }
  }

  Future<void> _deleteTransaction(String uid) async {
    final transactionService = ref.read(transactionServiceProvider);
    try {
      await transactionService.deleteTransaction(
        uid: uid,
        transactionId: widget.transactionId,
        transaction: widget.transaction,
      );

      _showSnackBar('Transaction deleted successfully!');
      Navigator.of(context).pop();
    } catch (error) {
      _showSnackBar('Failed to delete transaction: $error');
    }
  }

  void _confirmDelete(String uid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content:
            const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteTransaction(uid);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authRepositoryProvider).currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Transaction'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(uid),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildAmountField(),
                const SizedBox(height: 16),
                _buildCategorySelection(context),
                const SizedBox(height: 16),
                _buildWalletSelection(context),
                const SizedBox(height: 16),
                _buildDescriptionField(),
                const SizedBox(height: 16),
                _buildDatePicker(context),
                const SizedBox(height: 16),
                _buildImagePicker(),
                const SizedBox(height: 30),
                _buildSubmitButton(uid),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      decoration: const InputDecoration(
        labelText: 'Amount',
        prefixText: 'Rp ',
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
    );
  }

  Widget _buildCategorySelection(BuildContext context) {
    return ListTile(
      title: const Text('Category'),
      subtitle: Text(_selectedCategoryName ?? 'Select a category'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final selectedCategory = await Navigator.push<Map<String, String>?>(
          context,
          MaterialPageRoute(builder: (_) => const CategorySelectionScreen()),
        );
        if (selectedCategory != null) {
          setState(() {
            _selectedCategoryId = selectedCategory['id'];
            _selectedCategoryName = selectedCategory['name'];
            _selectedCategoryType = selectedCategory['type'];
          });
        }
      },
    );
  }

  Widget _buildWalletSelection(BuildContext context) {
    return ListTile(
      title: const Text('Wallet'),
      subtitle: Text(_selectedWallet ?? 'Select a wallet'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final selectedWallet = await Navigator.push<Map<String, String>?>(
          context,
          MaterialPageRoute(builder: (_) => const WalletSelectionScreen()),
        );
        if (selectedWallet != null) {
          setState(() {
            _selectedWalletId = selectedWallet['id'];
            _selectedWallet = selectedWallet['name'];
          });
        }
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description (Optional)',
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Date: ${DateFormat('EEEE, dd/MM/yyyy').format(_selectedDate)}',
          style: const TextStyle(fontSize: 16),
        ),
        FilledButton(
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
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _selectedImage != null || _imagePath != null
          ? () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: InteractiveViewer(
                    child: _selectedImage != null
                        ? kIsWeb
                            ? Image.network(_selectedImage!.path)
                            : Image.file(_selectedImage as File)
                        : Image.network(_imagePath!),
                  ),
                ),
              );
            }
          : null,
      child: SizedBox(
        width: double.infinity,
        height: _selectedImage == null && _imagePath == null ? null : 200,
        child: _selectedImage == null && _imagePath == null
            ? ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Add Image'),
              )
            : Stack(
                children: [
                  _buildImagePreview(),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.8),
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(Icons.edit, color: Colors.black),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: _selectedImage != null
          ? kIsWeb
              ? Image.network(
                  _selectedImage!.path,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  errorBuilder: (_, __, ___) => const Icon(Icons.error),
                )
              : Image.file(
                  _selectedImage as File,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                )
          : Image.network(
              _imagePath!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
              errorBuilder: (_, __, ___) => const Icon(Icons.error),
            ),
    );
  }

  Widget _buildSubmitButton(String uid) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () => _updateTransaction(uid),
        child: const Text('Update Transaction'),
      ),
    );
  }
}
