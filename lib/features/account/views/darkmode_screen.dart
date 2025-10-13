import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smartmoney/core/theme_provider.dart';

class DarkModeScreen extends ConsumerWidget {
  const DarkModeScreen({super.key});

  void _handleThemeChange(WidgetRef ref, ThemeMode value) {
    ref.read(themeProvider.notifier).toggleTheme(value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Dark Mode Page'),
      ),
      body: themeAsync.when(
        data: (theme) => Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('On'),
              value: ThemeMode.dark,
              groupValue: theme,
              onChanged: (value) => _handleThemeChange(ref, value!),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Off'),
              value: ThemeMode.light,
              groupValue: theme,
              onChanged: (value) => _handleThemeChange(ref, value!),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Use System Settings'),
              value: ThemeMode.system,
              groupValue: theme,
              onChanged: (value) => _handleThemeChange(ref, value!),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading theme: $error'),
        ),
      ),
    );
  }
}
