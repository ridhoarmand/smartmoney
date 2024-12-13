import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false; // Tambahkan variabel loading

  Future<void> _signUp() async {
    // Periksa apakah sudah dalam proses loading
    if (_isLoading) return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Aktifkan loading state
      });

      try {
        final authRepository = ref.read(authRepositoryProvider);
        final result = await authRepository.signUp(
          _emailController.text,
          _passwordController.text,
        );

        if (result != null) {
          // Update user profile with name
          await result.user?.updateDisplayName(_nameController.text);
          // Navigate to dashboard after successful signup
          context.go('/dashboard');
        } else {
          _showError('Signup failed');
        }
      } on FirebaseAuthException catch (e) {
        // Handle Firebase specific errors
        if (e.code == 'email-already-in-use') {
          _showError('This email is already in use.');
        } else if (e.code == 'weak-password') {
          _showError('The password is too weak.');
        } else {
          _showError('Error: ${e.message}');
        }
      } catch (e) {
        _showError('Error: $e');
      } finally {
        // Matikan loading state di blok finally
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/signin');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 40, right: 50, top: 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(),
                _buildFields(),
                _buildButton(),
                _buildSignInLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/logo.png',
          width: 50,
          height: 50,
        ),
        const SizedBox(height: 30),
        const Text(
          'Create your account',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Enter your full name',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            hintText: 'Enter your email',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            return null;
          },
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildButton() {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: FilledButton(
        onPressed: _isLoading ? null : _signUp,
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'SIGN UP',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already have an account?'),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        context.go('/signin');
                      },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
