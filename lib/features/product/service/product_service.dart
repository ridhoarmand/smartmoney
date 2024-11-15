import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../model/product_model.dart';

class ProductService {
  final CollectionReference _productCollection =
      FirebaseFirestore.instance.collection('products');
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Stream<List<Product>> getProducts() {
    return _productCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromDocumentSnapshot(doc))
          .toList();
    });
  }

  Future<String?> uploadProductImage(File imageFile) async {
    try {
      final String fileName = '${_uuid.v4()}${path.extension(imageFile.path)}';
      final Reference storageRef = _storage.ref().child('products/$fileName');

      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;

      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<bool> deleteProductImage(String imageUrl) async {
    try {
      final Reference storageRef = _storage.refFromURL(imageUrl);
      await storageRef.delete();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
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

  Future<bool> deleteProduct(Product product) async {
    try {
      if (product.imageUrl != null) {
        await deleteProductImage(product.imageUrl!);
      }
      await _productCollection.doc(product.id).delete();
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }
}
