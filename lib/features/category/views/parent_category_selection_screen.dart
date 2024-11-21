import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../category_model_service_provider.dart';

class ParentCategorySelectionScreen extends ConsumerWidget {
  final String uid;
  final String? currentCategoryId;

  const ParentCategorySelectionScreen({
    super.key,
    required this.uid,
    this.currentCategoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Filter categories to show only root categories
    final categories = ref.watch(categoryProvider).where((category) {
      return category.parentId == null && category.id != currentCategoryId;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Parent Category'),
      ),
      body: ListView.builder(
        itemCount: categories.length + 1, // +1 for the "None" option
        itemBuilder: (context, index) {
          if (index == 0) {
            // Option for "None"
            return ListTile(
              leading: const Icon(Icons.clear, color: Colors.grey),
              title: const Text('None'),
              onTap: () {
                Navigator.pop(context, 'None'); // Return 'None' for "None"
              },
            );
          }
          // Display actual categories
          final category = categories[index - 1];
          return ListTile(
            leading: Icon(category.icon),
            title: Text(category.name),
            onTap: () {
              Navigator.pop(
                  context, category.id); // Return selected category ID
            },
          );
        },
      ),
    );
  }
}
