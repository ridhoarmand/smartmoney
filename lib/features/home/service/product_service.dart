import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/product_model.dart';

class ProductService {
  final CollectionReference _productCollection =
      FirebaseFirestore.instance.collection('products');

  Stream<List<Product>> getProducts() {
    return _productCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromDocumentSnapshot(doc))
          .toList();
    }).handleError((error) {
      print('Error fetching products: $error');
      return <Product>[];
    });
  }

  Future<String?> addProduct(Product product) async {
    try {
      final docRef = await _productCollection.add(product.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      return null;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      await _productCollection.doc(product.id).update(product.toMap());
      return true;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      await _productCollection.doc(productId).delete();
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }
}
