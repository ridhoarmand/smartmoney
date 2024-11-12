import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme_provider.dart';

class DarkModeScreen extends ConsumerWidget {
  const DarkModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Dark Mode Page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          RadioListTile(
            title: const Text('On'),
            value: ThemeMode.dark,
            groupValue: theme.currentTheme,
            onChanged: (ThemeMode? value) {
              ref.watch(themeProvider).toggleTheme(ThemeMode.dark);
            },
          ),
          RadioListTile(
            title: const Text('Off'),
            value: ThemeMode.light,
            groupValue: theme.currentTheme,
            onChanged: (ThemeMode? value) {
              ref.watch(themeProvider).toggleTheme(ThemeMode.light);
            },
          ),
          RadioListTile(
            title: const Text('Use System Settings'),
            value: ThemeMode.system,
            groupValue: theme.currentTheme,
            onChanged: (ThemeMode? value) {
              ref.read(themeProvider).toggleTheme(ThemeMode.system);
            },
          ),
        ],
      ),
    );
  }
}
