import 'dart:io';

import 'package:flutter/material.dart';

import '../model/product_model.dart';
import '../repository/product_repository.dart';
import '../widget/product_form.dart';
import '../widget/product_list_tile.dart';

class ProductScreen extends StatelessWidget {
  final ProductRepository _repository = ProductRepository();

  ProductScreen({super.key});

  void _openAddProductForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ProductForm(
        onSubmit: (Product product, File? imageFile) async {
          // Updated signature
          await _repository.createOrUpdateProduct(
            product,
            imageFile: imageFile, // Pass the imageFile
          );
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Produk berhasil ditambahkan')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        elevation: 2,
      ),
      body: StreamBuilder<List<Product>>(
        stream: _repository.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!;

          if (products.isEmpty) {
            return const Center(child: Text('Belum ada produk'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: products.length,
            itemBuilder: (context, index) => ProductListTile(
              product: products[index],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddProductForm(context),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
