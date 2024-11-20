import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  User? get currentUser => _authService.currentUser;

  bool get isSignedIn => _authService.isSignedIn;

  Future<UserCredential?> signUp(String email, String password) {
    return _authService.signInWithEmail(email, password);
  }

  Future<UserCredential?> signIn(String email, String password) {
    return _authService.signInWithEmail(email, password);
  }

  Future<void> signOut() {
    return _authService.signOut();
  }

  Future<UserCredential?> signInWithGoogle() {
    return _authService.signInWithGoogle();
  }
}
