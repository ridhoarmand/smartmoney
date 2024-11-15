import 'dart:io';

import '../model/product_model.dart';
import '../service/product_service.dart';

class ProductRepository {
  final ProductService _service;

  ProductRepository({ProductService? service})
      : _service = service ?? ProductService();

  Stream<List<Product>> getProducts() {
    return _service.getProducts();
  }

  Future<String?> uploadProductImage(File imageFile) async {
    return await _service.uploadProductImage(imageFile);
  }

  Future<bool> createOrUpdateProduct(Product product,
      {bool isUpdate = false, File? imageFile}) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadProductImage(imageFile);
        if (imageUrl == null) return false;
      }

      final updatedProduct = Product(
        id: product.id,
        nama: product.nama,
        satuan: product.satuan,
        harga: product.harga,
        imageUrl: imageUrl ?? product.imageUrl,
      );

      if (isUpdate) {
        return await _service.updateProduct(updatedProduct);
      } else {
        final id = await _service.addProduct(updatedProduct);
        return id != null;
      }
    } catch (e) {
      print('Error in createOrUpdateProduct: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(Product product) async {
    return await _service.deleteProduct(product);
  }
}
