import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../providers/edit_profile_provider.dart';
import 'widgets/form_edit_profile.dart';
import 'widgets/image_picker_edit_profile.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  File? _imageFile;
  bool _changeEmail = false;
  bool _changePassword = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authRepositoryProvider).currentUser;
    _nameController.text = user?.displayName ?? '';
    _emailController.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleImagePicked(File image) {
    setState(() {
      _imageFile = image;
    });
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    await ref.read(editProfileRepositoryProvider.notifier).updateProfile(
          user: user,
          name: _nameController.text,
          email: _emailController.text,
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
          changeEmail: _changeEmail,
          changePassword: _changePassword,
          imageFile: _imageFile,
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update account: $error'),
                backgroundColor: Colors.red,
              ),
            );
          },
          onSuccess: () {
            if (_changeEmail) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Verification email sent. Please check your inbox.'),
                ),
              );
            }
            if (_changePassword) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password updated successfully'),
                ),
              );
            }
            context.pop(true);
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final isLoading = ref.watch(editProfileRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ImagePickerEditProfile(
                  imageFile: _imageFile,
                  currentPhotoURL: user?.photoURL,
                  onImagePicked: _handleImagePicked,
                ),
                const SizedBox(height: 24),
                ProfileFormField(
                  controller: _nameController,
                  label: 'Name',
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name cannot be empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text("Change Email"),
                  value: _changeEmail,
                  onChanged: (value) =>
                      setState(() => _changeEmail = value ?? false),
                ),
                if (_changeEmail) ...[
                  ProfileFormField(
                    controller: _emailController,
                    label: 'New Email',
                    hint: 'Enter new email',
                    prefixIcon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email cannot be empty';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                CheckboxListTile(
                  title: const Text("Change Password"),
                  value: _changePassword,
                  onChanged: (value) =>
                      setState(() => _changePassword = value ?? false),
                ),
                if (_changePassword || _changeEmail) ...[
                  ProfileFormField(
                    controller: _currentPasswordController,
                    label: 'Current Password',
                    hint: 'Enter current password',
                    prefixIcon: Icons.lock,
                    obscureText: !_showPassword,
                    onToggleVisibility: () =>
                        setState(() => _showPassword = !_showPassword),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Current password is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                if (_changePassword) ...[
                  ProfileFormField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    hint: 'Enter new password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: !_showPassword,
                    onToggleVisibility: () =>
                        setState(() => _showPassword = !_showPassword),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'New password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ProfileFormField(
                    controller: _confirmPasswordController,
                    label: 'Confirm New Password',
                    hint: 'Confirm your new password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: !_showPassword,
                    onToggleVisibility: () =>
                        setState(() => _showPassword = !_showPassword),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleUpdate,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Update Profile',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
