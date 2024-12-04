import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category.dart';

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

  Future<bool> isCategoryUsedInTransactions(
      String uid, String categoryId) async {
    final transactionsSnapshot = await _firestore
        .collection('users/$uid/transactions')
        .where('categoryId', isEqualTo: categoryId)
        .limit(1)
        .get();

    return transactionsSnapshot.docs.isNotEmpty;
  }

  Future<bool> deleteCategory(String uid, String id) async {
    final isUsed = await isCategoryUsedInTransactions(uid, id);

    if (isUsed) {
      return false;
    }

    await _firestore.collection('users/$uid/categories').doc(id).delete();
    state = state.where((category) => category.id != id).toList();
    return true;
  }
}

final categoryStreamProvider =
    StreamProvider.family<List<Category>, String>((ref, uid) {
  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('users/$uid/categories')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return Category.fromFirestore(doc.data()..['id'] = doc.id);
    }).toList();
  });
});
