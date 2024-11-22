import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/category.dart';
import '../service_providers/category_service_provider.dart';
import 'category_form_screen.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  CategoryScreenState createState() => CategoryScreenState();
}

class CategoryScreenState extends ConsumerState<CategoryScreen>
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

    // Get the root categories (categories with no parent)
    final rootCategories =
        categories.where((category) => category.parentId == null).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.arrow_downward), text: 'Income'),
            Tab(icon: Icon(Icons.arrow_upward), text: 'Expense'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryView(rootCategories, 'Income'),
          _buildCategoryView(rootCategories, 'Expense'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryFormScreen(
                  uid: uid,
                  type: _tabController.index == 0 ? 'Income' : 'Expense'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryView(List<Category> rootCategories, String type) {
    // Filter root categories based on type
    final filteredRoots =
        rootCategories.where((category) => category.type == type).toList();

    if (filteredRoots.isEmpty) {
      return const Center(child: Text('No categories found'));
    }

    return ListView.builder(
      itemCount: filteredRoots.length,
      itemBuilder: (context, index) {
        final root = filteredRoots[index];

        // Get children of this root
        final children = ref
            .watch(categoryProvider)
            .where((category) => category.parentId == root.id)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: type == 'Income' ? Colors.green : Colors.red,
                child: Icon(
                  root.icon,
                  color: Colors.white,
                ),
              ),
              title: Text(root.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryFormScreen(
                        uid: uid, category: root, type: type),
                  ),
                );
              },
            ),
            if (children.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
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
          const Icon(Icons.subdirectory_arrow_right),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: child.type == 'Income' ? Colors.green : Colors.red,
            child: Icon(
              child.icon,
              color: Colors.white,
            ),
          ),
        ],
      ),
      title: Text(child.name),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryFormScreen(
              uid: uid,
              category: child,
              type: child.type,
            ),
          ),
        );
      },
    );
  }
}
