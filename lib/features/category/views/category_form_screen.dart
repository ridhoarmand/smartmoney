import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../service_providers/category_service_provider.dart';
import 'parent_category_selection_screen.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  final String uid;
  final String type;
  final Category? category;

  const CategoryFormScreen({
    super.key,
    required this.uid,
    required this.type,
    this.category,
  });

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
    _type = widget.category?.type ?? widget.type;
    _icon = widget.category?.icon ?? Icons.category;
    _parentId = widget.category?.parentId;
    _parentName = _parentId == null
        ? 'None'
        : ref
            .read(categoryProvider)
            .firstWhere(
              (category) => category.id == _parentId,
              orElse: () => Category(
                  id: '', name: 'None', type: '', icon: Icons.category),
            )
            .name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                      IconPickerIcon? icon = await showIconPicker(
                        context,
                        configuration: SinglePickerConfiguration(
                          title: const Text('Select an icon'),
                          iconPickerShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          searchComparator:
                              (String search, IconPickerIcon icon) =>
                                  search.toLowerCase().contains(icon.name
                                      .replaceAll('_', ' ')
                                      .toLowerCase()) ||
                                  icon.name
                                      .toLowerCase()
                                      .contains(search.toLowerCase()),
                        ),
                      );

                      if (icon != null) {
                        setState(() {
                          _icon = icon.data;
                        });
                      }
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
              // Type Form Field readonly
              TextFormField(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
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
                        currentCategoryType: _type,
                      ),
                    ),
                  );
                  if (selectedParentId != null) {
                    setState(
                      () {
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
                                    type: 'Income',
                                    icon: Icons.category),
                              )
                              .name;
                        }
                      },
                    );
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
              // Delete button
              if (widget.category != null) const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Modal dialog to confirm deletion
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Category'),
                      content: const Text(
                          'Are you sure you want to delete this category?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(categoryProvider.notifier).deleteCategory(
                                widget.uid, widget.category!.id);
                            Navigator.pop(context);
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  foregroundColor: Colors.red,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
