import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ListTileAboutApps extends StatelessWidget {
  const ListTileAboutApps({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info),
      title: const Text('About Apps'),
      onTap: () {
        context.push('/about');
      },
    );
  }
}
