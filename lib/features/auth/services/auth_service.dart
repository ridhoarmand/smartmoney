import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/initials_data_templates.dart';
import '../../../core/remote_config_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RemoteConfigService _remoteConfigService = RemoteConfigService();

  // Define scopes for Google Sign In
  static const List<String> scopes = <String>[
    'email',
    'profile',
    'openid',
  ];

  // GoogleSignIn instance will be initialized after getting clientId from RemoteConfig
  GoogleSignIn? _googleSignIn;

  // Current user getter
  User? get currentUser => _auth.currentUser;

  // Authentication state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Initialize AuthService (asynchronous) to set up googleSignIn clientId
  Future<void> initialize() async {
    // Initialize RemoteConfigService and fetch the Google Sign-In Client ID
    await _remoteConfigService.initialize();

    // Get the Google Sign-In Client ID from Remote Config
    String? googleSignInClientId =
        await _remoteConfigService.getGoogleSignInClientId();

    if (googleSignInClientId == null) {
      throw Exception('Google Sign-In Client ID is null');
    }

    // Initialize GoogleSignIn with the fetched client ID
    _googleSignIn = GoogleSignIn(
      clientId: googleSignInClientId,
      scopes: scopes,
    );
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Make sure we're initialized
      if (_googleSignIn == null) {
        await initialize();
      }

      GoogleSignInAccount? googleUser;

      if (kIsWeb) {
        // Web-specific sign in flow
        try {
          googleUser ??= await _googleSignIn!.signIn();

          // Check for required scopes authorization
          final bool isAuthorized =
              await _googleSignIn!.canAccessScopes(scopes);

          if (!isAuthorized) {
            final bool granted = await _googleSignIn!.requestScopes(scopes);
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
        googleUser = await _googleSignIn!.signIn();
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
      await _auth.signOut();

      if (_googleSignIn != null) {
        await _googleSignIn!.signOut();
      }

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
    if (kDebugMode) {
      print(e.code);
    }
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
