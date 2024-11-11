import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<void> loginStatusFuture;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    loginStatusFuture = _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await currentUser.getIdToken(true);
      }

      if (mounted) {
        if (currentUser != null) {
          // User is logged in, redirect to home
          context.go('/home');
        } else {
          // User is not logged in, redirect to login
          context.go('/login');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking login status: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
        // Pada error, arahkan ke login untuk aman
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: loginStatusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSplashScreen();
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return _buildSplashScreen();
          }
        },
      ),
    );
  }

  Widget _buildSplashScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo.png',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 20),
          const Text(
            'Welcome back.\nIn Smart money.',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
