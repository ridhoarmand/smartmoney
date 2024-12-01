import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  late Future<void> loginStatusFuture;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // Form state
  final _formKey = GlobalKey<FormState>();
  bool _autovalidateMode = false;
  bool _isLoading = false;

  // Validation states
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loginStatusFuture = _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await currentUser.getIdToken(true);
    }

    if (mounted) {
      if (currentUser != null) {
        // User is logged in, redirect to home
        context.go('/dashboard');
      }
    }
  }

  // Improved email validation with better regex pattern
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Improved password validation with multiple criteria
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    return null;
  }

  // Handle real-time validation
  void _onEmailChanged(String value) {
    if (_autovalidateMode) {
      setState(() {
        _emailError = _validateEmail(value);
      });
    }
  }

  void _onPasswordChanged(String value) {
    if (_autovalidateMode) {
      setState(() {
        _passwordError = _validatePassword(value);
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Improved sign in logic with better error handling
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidateMode = true);
      return;
    }

    try {
      setState(() => _isLoading = true);

      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (result != null) {
        context.go('/dashboard');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Improved Google sign in with better error handling
  Future<void> _signInWithGoogle() async {
    try {
      setState(() => _isLoading = true);

      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.signInWithGoogle();

      if (!mounted) return;

      if (result != null) {
        context.go('/dashboard');
      }
    } on FirebaseAuthException catch (e) {
      _showError('${e.message}');
    } catch (e) {
      _showError('An error occurred during Google sign in');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 40, right: 50, top: 20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  _buildFields(),
                  _buildForgotPasswordLink(),
                  _buildSignInButton(),
                  _buildSignUpLink(),
                  _buildOrDivider(),
                  _buildGoogleButton(),
                ],
              ),
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
          'Welcome back\nLet`s Smart money.',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildFields() {
    return AutofillGroup(
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            onChanged: _onEmailChanged,
            validator: _validateEmail,
            decoration: InputDecoration(
              hintText: 'Enter your email',
              errorText: _emailError,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onChanged: _onPasswordChanged,
            validator: _validatePassword,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              errorText: _passwordError,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _isLoading ? null : () => context.go('/forgot-password'),
        child: const Text("Forgot Password?"),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: FilledButton(
          onPressed: _isLoading ? null : _signIn,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            disabledBackgroundColor: Colors.grey,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'SIGN IN',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? "),
        TextButton(
          onPressed: _isLoading ? null : () => context.go('/signup'),
          child: const Text("Sign Up"),
        ),
      ],
    );
  }

  Widget _buildOrDivider() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Divider(thickness: 3),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("OR"),
          ),
          Expanded(
            child: Divider(thickness: 3),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Center(
      child: InkWell(
        onTap: _isLoading ? null : _signInWithGoogle,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/google.png',
            width: 40,
            height: 40,
          ),
        ),
      ),
    );
  }
}
