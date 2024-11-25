import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ListTileDarkMode extends StatelessWidget {
  const ListTileDarkMode({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.dark_mode),
      title: const Text('Dark Mode'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        context.push('/setting/darkmode');
      },
    );
  }
}
