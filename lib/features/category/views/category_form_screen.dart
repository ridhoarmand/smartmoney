import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../category_model_service_provider.dart';
import 'parent_category_selection_screen.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  final String uid;
  final Category? category;

  const CategoryFormScreen({super.key, required this.uid, this.category});

  @override
  CategoryFormScreenState createState() => CategoryFormScreenState();
}

class CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _type;
  late IconData _icon;
  String? _parentId;
  String? _parentName;

  @override
  void initState() {
    super.initState();
    _name = widget.category?.name ?? '';
    _type = widget.category?.type ?? 'income';
    _icon = widget.category?.icon ?? Icons.category;
    _parentId = widget
        .category?.parentId; // If there's no parentId, it will remain null
    _parentName = _parentId == null
        ? 'None'
        : ref
            .read(categoryProvider)
            .firstWhere(
              (category) => category.id == widget.category?.parentId,
              orElse: () => Category(
                  id: '', name: 'None', type: 'income', icon: Icons.category),
            )
            .name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and Name input
              Row(
                children: [
                  IconButton(
                    icon: Icon(_icon),
                    onPressed: () async {
                      // Future functionality to select icon from assets will be implemented here
                      setState(() {
                        _icon = Icons.star; // For now, a placeholder icon
                      });
                    },
                  ),
                  Expanded(
                    child: TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _name = value,
                      validator: (value) =>
                          value!.isEmpty ? 'Category name is required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              // Type dropdown
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'income', child: Text('Income')),
                  DropdownMenuItem(value: 'expense', child: Text('Expense')),
                ],
                onChanged: (value) => _type = value!,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              // Parent Category Selection
              ListTile(
                title: const Text('Parent Category'),
                subtitle: Text(_parentName ?? 'None'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final selectedParentId = await Navigator.push<String?>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ParentCategorySelectionScreen(
                          uid: widget.uid,
                          currentCategoryId: widget.category?.id,
                        ),
                      ));
                  if (selectedParentId != null) {
                    setState(() {
                      if (selectedParentId == 'None') {
                        _parentId = null; // Set to null for "None"
                        _parentName = 'None'; // Display 'None' in the UI
                      } else {
                        _parentId = selectedParentId;
                        _parentName = ref
                            .read(categoryProvider)
                            .firstWhere(
                              (category) => category.id == selectedParentId,
                              orElse: () => Category(
                                  id: '',
                                  name: 'None',
                                  type: 'income',
                                  icon: Icons.category),
                            )
                            .name;
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16.0),
              // Submit button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Only set parentId if it's not null
                    final newCategory = Category(
                      id: widget.category?.id ?? '',
                      name: _name,
                      type: _type,
                      icon: _icon,
                      parentId: _parentId, // Null if 'None' is selected
                    );
                    ref
                        .read(categoryProvider.notifier)
                        .addOrUpdateCategory(widget.uid, newCategory);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(widget.category == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
