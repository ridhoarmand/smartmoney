import 'package:flutter/material.dart';

class CurrencySelectionScreen extends StatelessWidget {
  const CurrencySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencies = [
      {'name': 'Inconesian Rupiah', 'symbol': 'Rp', 'flag': '🇮🇩'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Select Currency')),
      body: ListView.builder(
        itemCount: currencies.length,
        itemBuilder: (context, index) {
          final currency = currencies[index];
          return ListTile(
            leading: Text(currency['flag']!),
            title: Text('${currency['name']} (${currency['symbol']})'),
            onTap: () => Navigator.pop(context, currency['name']),
          );
        },
      ),
    );
  }
}
