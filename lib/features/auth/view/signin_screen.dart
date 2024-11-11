import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../provider/auth_provider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _signIn() async {
    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (result != null) {
      context.go('/home');
    } else {
      _showError("Sign in failed. Please check your credentials.");
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the sign-in process
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in the user with the Google credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Navigate to the home page
      context.go('/home');
    } catch (e) {
      // Handle sign-in failure
      _showError("Google sign-in failed. Please try again.");
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
      body: Padding(
        padding: const EdgeInsets.only(left: 40, right: 50, top: 60),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              _buildField(),
              _buildButton(),
              _buildSignUpLink(),
              _buildOrDivider(),
              _buildGoogleButton(),
            ],
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
        const SizedBox(
          height: 30,
        ),
        const Text(
          'Welcome back\nLet`s Smart money.',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        const SizedBox(
          height: 30,
        ),
      ],
    );
  }

  Widget _buildField() {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            hintText: 'Masukan Email Anda',
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: 'Masukan Password Anda',
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 30,
        ),
      ],
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _signIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
        ),
        child: const Text(
          'SIGN IN',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Belum punya akun? "),
        TextButton(
          onPressed: () {
            context.go('/signup');
          },
          child: const Text("Sign Up"),
        ),
      ],
    );
  }

  Widget _buildOrDivider() {
    return const Column(
      children: [
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 100, child: Divider(color: Colors.white)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Text("OR", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(width: 100, child: Divider(color: Colors.white)),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return Center(
      child: GestureDetector(
        onTap: _signInWithGoogle,
        child: Image.asset(
          'assets/google.png',
          // Pastikan file 'google.png' ada di dalam folder assets
          width: 40,
          height: 40,
        ),
      ),
    );
  }
}
