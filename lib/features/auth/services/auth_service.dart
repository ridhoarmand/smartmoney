import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/initials_data_templates.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Define scopes for Google Sign In
  static const List<String> scopes = <String>[
    'email',
    'profile',
    'openid',
  ];

  // Initialize Google Sign In with web client ID
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '601522394171-9hmhg1sias624f4fjrh18pl9frr03eu6.apps.googleusercontent.com',
    // Replace with your web client ID
    scopes: [
      'email',
      'profile',
      'openid',
    ],
  );

  // Current user getter
  User? get currentUser => _auth.currentUser;

  // Authentication state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser;

      if (kIsWeb) {
        // Web-specific sign in flow
        try {
          googleUser ??= await _googleSignIn.signIn();

          // Check for required scopes authorization
          final bool isAuthorized = await _googleSignIn.canAccessScopes(scopes);

          if (!isAuthorized) {
            final bool granted = await _googleSignIn.requestScopes(scopes);
            if (!granted) {
              throw Exception('Required permissions not granted');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Web Google Sign In error: $e');
          }
          rethrow;
        }
      } else {
        // Mobile sign in flow
        googleUser = await _googleSignIn.signIn();
      }

      if (googleUser == null) {
        return null;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Reload user data
      await _auth.currentUser?.reload();

      notifyListeners();

      // Check if the user is new
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        saveTemplateData();
      }

      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('SignInWithGoogle error: $e');
      }
      rethrow;
    }
  }

  // Email/Password Sign Up
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      saveTemplateData();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  // Email/Password Sign In
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Sign out error: $e');
      }
      rethrow;
    }
  }

  // Helper method to handle Firebase Auth exceptions
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    print(e.code);
    switch (e.code) {
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
