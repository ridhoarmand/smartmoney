import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/auth_provider.dart';
import '../service_providers/transaction_service_providers.dart';
import 'category_selection_screen.dart';
import 'wallet_selection_screen.dart';

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
  dynamic _selectedImage;
  String? _imageUrl;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Picks an image from the gallery.
  Future<void> _pickImage() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = kIsWeb ? image : File(image.path);
      });
    }
  }

  /// Uploads the selected image to Firebase Storage.
  Future<String?> _uploadImage(String uid) async {
    if (_selectedImage == null) return null;

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef =
          FirebaseStorage.instance.ref().child('transactions/$timestamp.jpg');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'picked-file-path': 'transactions/$timestamp.jpg',
        },
      );

      if (kIsWeb && _selectedImage is XFile) {
        final bytes = await (_selectedImage as XFile).readAsBytes();
        await storageRef.putData(bytes, metadata);
      } else if (_selectedImage is File) {
        await storageRef.putFile(_selectedImage as File, metadata);
      }

      return await storageRef.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: $e')),
      );
      return null;
    }
  }

  /// Submits the transaction form.
  Future<void> _submitTransaction(String uid) async {
    if (_formKey.currentState!.validate() &&
        _selectedCategoryType != null &&
        _selectedWalletId != null) {
      final transactionService = ref.read(transactionServiceProvider);

      try {
        if (_selectedImage != null) {
          _imageUrl = await _uploadImage(uid);
        }

        await transactionService.createTransaction(
          uid: uid,
          amount: double.parse(_amountController.text),
          categoryId: _selectedCategoryId!,
          categoryType: _selectedCategoryType!,
          description: _descriptionController.text,
          date: _selectedDate,
          walletId: _selectedWalletId!,
          imagePath: _imageUrl,
        );

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
                _buildAmountField(),
                const SizedBox(height: 16),
                _buildCategorySelector(context),
                const SizedBox(height: 16),
                _buildWalletSelector(context),
                const SizedBox(height: 16),
                _buildDescriptionField(),
                const SizedBox(height: 16),
                _buildDateSelector(),
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
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
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

  Widget _buildWalletSelector(BuildContext context) {
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

  Widget _buildDateSelector() {
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
      onTap: _selectedImage != null
          ? () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: InteractiveViewer(
                    child: kIsWeb
                        ? Image.network((_selectedImage as XFile).path)
                        : Image.file(_selectedImage as File),
                  ),
                ),
              );
            }
          : null,
      child: SizedBox(
        width: double.infinity,
        height: _selectedImage == null ? null : 200,
        child: _selectedImage == null
            ? ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Add Image'),
              )
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb
                        ? Image.network(
                            (_selectedImage as XFile).path,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                          )
                        : Image.file(
                            _selectedImage as File,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                          ),
                  ),
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

  Widget _buildSubmitButton(String uid) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () => _submitTransaction(uid),
        child: const Text('Save Transaction'),
      ),
    );
  }
}
