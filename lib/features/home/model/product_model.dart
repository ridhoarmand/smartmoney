import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String nama;
  final String satuan;
  final double harga;

  Product({
    required this.id,
    required this.nama,
    required this.satuan,
    required this.harga,
  });

  factory Product.fromDocumentSnapshot(DocumentSnapshot doc) {
    return Product(
      id: doc.id,
      nama: doc['nama'],
      satuan: doc['satuan'],
      harga: doc['harga'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'satuan': satuan,
      'harga': harga,
    };
  }
}
