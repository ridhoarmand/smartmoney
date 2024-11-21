import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// MODEL
class Category {
  final String id;
  final String name;
  final String type; // 'income' or 'expense'
  final IconData icon;
  final String? parentId; // null if no parent

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    this.parentId,
  });

  Category copyWith({
    String? id,
    String? name,
    String? type,
    IconData? icon,
    String? parentId,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      parentId: parentId ?? this.parentId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'icon': icon.codePoint,
      'parentId': parentId,
    };
  }

  static Category fromMap(Map<String, dynamic> map, String id) {
    return Category(
      id: id,
      name: map['name'],
      type: map['type'],
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
      parentId: map['parentId'],
    );
  }
}

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
