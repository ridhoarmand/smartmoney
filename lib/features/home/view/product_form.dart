import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/product_model.dart';

class ProductForm extends StatefulWidget {
  final Product? product;
  final Function(Product) onSubmit;

  const ProductForm({
    super.key,
    this.product,
    required this.onSubmit,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _satuanController = TextEditingController();
  final _hargaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _namaController.text = widget.product!.nama;
      _satuanController.text = widget.product!.satuan;
      _hargaController.text = widget.product!.harga.toString();
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _satuanController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: widget.product?.id ?? '',
        nama: _namaController.text,
        satuan: _satuanController.text,
        harga: double.parse(_hargaController.text),
      );
      widget.onSubmit(product);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 8,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama Produk'),
              validator: (value) =>
                  value!.isEmpty ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _satuanController,
              decoration: const InputDecoration(labelText: 'Satuan'),
              validator: (value) =>
                  value!.isEmpty ? 'Satuan tidak boleh kosong' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _hargaController,
              decoration: const InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) =>
                  value!.isEmpty ? 'Harga tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(
                  widget.product == null ? 'Tambah Produk' : 'Update Produk'),
            ),
          ],
        ),
      ),
    );
  }
}
