import 'package:flutter/material.dart';

class Wallet {
  final String id;
  final String name;
  final String currency;
  final num balance;
  final IconData icon;

  Wallet({
    required this.id,
    required this.name,
    required this.currency,
    required this.balance,
    required this.icon,
  });

  Wallet copyWith({
    String? id,
    String? name,
    String? currency,
    num? balance,
    IconData? icon,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'currency': currency,
      'balance': balance,
      'icon': icon.codePoint,
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map, String id) {
    return Wallet(
      id: id,
      name: map['name'],
      currency: map['currency'],
      balance: map['balance'],
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
    );
  }

  // wallet from firestore
  factory Wallet.fromFirestore(Map<String, dynamic> data) {
    return Wallet(
      id: data['id'] as String,
      name: data['name'] as String,
      currency: data['currency'] as String,
      balance: data['balance'] as num,
      icon: IconData(data['icon'] as int, fontFamily: 'MaterialIcons'),
    );
  }
}
