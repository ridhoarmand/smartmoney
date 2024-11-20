import 'package:flutter/material.dart';

class Wallet {
  final String id;
  final String name;
  final String currency;
  final double balance;
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
    double? balance,
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
      'id': id,
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
}
