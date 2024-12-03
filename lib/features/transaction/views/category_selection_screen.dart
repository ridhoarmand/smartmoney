import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../category/models/category.dart';
import '../../category/service_providers/category_service_provider.dart';
import '../../category/views/category_form_screen.dart';

class CategorySelectionScreen extends ConsumerStatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  CategorySelectionScreenState createState() => CategorySelectionScreenState();
}

class CategorySelectionScreenState
    extends ConsumerState<CategorySelectionScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final String uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      uid = ref.read(authRepositoryProvider).currentUser!.uid;
      ref.read(categoryProvider.notifier).fetchCategories(uid);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Category'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.arrow_downward), text: 'Expense'),
            Tab(icon: Icon(Icons.arrow_upward), text: 'Income'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryView(categories, 'Expense'),
          _buildCategoryView(categories, 'Income'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryFormScreen(
                  uid: uid,
                  type: _tabController.index == 0 ? 'Expense' : 'Income'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryView(List<Category> categories, String type) {
    // Filter root categories based on type
    final rootCategories = categories
        .where((category) => category.type == type && category.parentId == null)
        .toList();

    if (rootCategories.isEmpty) {
      return const Center(child: Text('No categories found.'));
    }

    return ListView.builder(
      itemCount: rootCategories.length,
      itemBuilder: (context, index) {
        final root = rootCategories[index];

        // Get children of this root
        final children = categories
            .where((category) => category.parentId == root.id)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(root.icon),
              title: Text(root.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context, {
                  'id': root.id, // Mengirim ID kategori
                  'name': root.name, // Mengirim Nama kategori
                  'type': root.type, // Mengirim Tipe kategori
                });
              },
            ),
            if (children.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                    left: 20.0), // Indent child categories
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      children.map((child) => _buildChildTile(child)).toList(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildChildTile(Category child) {
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.subdirectory_arrow_right, color: Colors.grey),
          const SizedBox(width: 8),
          Icon(child.icon, color: Colors.grey),
        ],
      ),
      title: Text(child.name),
      onTap: () {
        Navigator.pop(context, {
          'id': child.id, // Mengirim ID kategori
          'name': child.name, // Mengirim Nama kategori
          'type': child.type, // Mengirim Tipe kategori
        });
      },
    );
  }
}
