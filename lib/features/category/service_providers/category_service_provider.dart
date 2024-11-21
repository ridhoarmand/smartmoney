import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category.dart';

// PROVIDER
final categoryProvider =
    StateNotifierProvider<CategoryNotifier, List<Category>>(
  (ref) => CategoryNotifier(),
);

class CategoryNotifier extends StateNotifier<List<Category>> {
  final _firestore = FirebaseFirestore.instance;

  CategoryNotifier() : super([]);

  Future<void> fetchCategories(String uid) async {
    final snapshot = await _firestore.collection('users/$uid/categories').get();
    state = snapshot.docs
        .map((doc) => Category.fromMap(doc.data(), doc.id))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> addOrUpdateCategory(String uid, Category category) async {
    if (category.id.isEmpty) {
      final docRef = await _firestore
          .collection('users/$uid/categories')
          .add(category.toMap());
      state = [...state, category.copyWith(id: docRef.id)];
    } else {
      await _firestore
          .collection('users/$uid/categories')
          .doc(category.id)
          .update(category.toMap());
      state = state.map((c) => c.id == category.id ? category : c).toList();
    }
  }

  Future<void> deleteCategory(String uid, String id) async {
    await _firestore.collection('users/$uid/categories').doc(id).delete();
    state = state.where((category) => category.id != id).toList();
  }
}

// PROVIDER untuk mengambil stream kategori berdasarkan UID pengguna
final categoryStreamProvider =
    StreamProvider.family<List<Category>, String>((ref, uid) {
  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('users') // Koleksi users
      .doc(uid) // Berdasarkan UID pengguna
      .collection('categories') // Koleksi kategori pengguna
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return Category.fromFirestore(
          doc.data()..['id'] = doc.id); // Add 'id' from document ID
    }).toList();
  });
});
