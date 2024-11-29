import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ListTileWallet extends StatelessWidget {
  final String uid;

  const ListTileWallet({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.wallet),
      title: const Text('My Wallets'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        context.push('/account/wallets', extra: uid);
      },
    );
  }
}
