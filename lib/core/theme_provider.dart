// ========= KODE FINAL AUTH_SERVICE.DART (VERSI BERSIH) =========

import 'package:firebase_auth/firebase_auth.dart';
// FIX 2: Menghapus 'show kIsWeb' karena tidak lagi digunakan
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Ganti dengan path import yang benar untuk proyek Anda
import '../../../core/initials_data_templates.dart';
import '../../../core/remote_config_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RemoteConfigService _remoteConfigService = RemoteConfigService();

  static const List<String> scopes = <String>['email', 'profile', 'openid'];
  GoogleSignIn? _googleSignIn;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isSignedIn => _auth.currentUser != null;

  Future<void> initialize() async {
    await _remoteConfigService.initialize();
    String? googleSignInClientId =
        await _remoteConfigService.getGoogleSignInClientId();

    if (googleSignInClientId == null) {
      throw Exception('Google Sign-In Client ID tidak ditemukan');
    }

    _googleSignIn = GoogleSignIn(
      clientId: googleSignInClientId,
      scopes: scopes,
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (_googleSignIn == null) await initialize();

      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();

      if (googleUser == null) return null; // User membatalkan login

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      await _auth.currentUser?.reload();
      notifyListeners();

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        saveTemplateData();
      }

      return userCredential;
    } catch (e) {
      if (kDebugMode) print('Error signInWithGoogle: $e');
      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      saveTemplateData();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn?.signOut();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error signOut: $e');
      rethrow;
    }
  }

  String _handleFirebaseAuthException(FirebaseAuthException e) {
    if (kDebugMode) print('FirebaseAuthException: ${e.code}');
    switch (e.code) {
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'user-not-found':
        return 'Tidak ada akun dengan email ini.';
      case 'wrong-password':
        return 'Password yang dimasukkan salah.';
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar.';
      case 'weak-password':
        return 'Password terlalu lemah.';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }
}

// FIX 1: TIDAK ADA KODE 'EXTENSION' APAPUN DI SINI. FILE BERAKHIR DI SINI.
