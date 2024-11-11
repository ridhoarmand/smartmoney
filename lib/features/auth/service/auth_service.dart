import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  get currentUser {
    return _auth.currentUser;
  }

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      rethrow;
    } catch (e) {
      // Jika error lainnya, lemparkan kembali kesalahan umum
      throw Exception("An unknown error occurred: $e");
    }
  }

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      // Coba login dengan email dan password
      UserCredential? userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Reload user setelah sign-in untuk memastikan data terupdate
      await _auth.currentUser?.reload();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        throw ('Username and password do not match');
      } else {
        throw ('${e.code} : ${e.message}');
      }
    } catch (e) {
      // Error lainnya selain FirebaseAuthException
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential? userCredential =
          await _auth.signInWithCredential(credential);
      // Reload user after successful sign-in to ensure data is updated
      await _auth.currentUser?.reload();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      rethrow;
    } catch (e) {
      // Jika error lainnya, lemparkan kembali kesalahan umum
      throw Exception("An unknown error occurred: $e");
    }
  }
}
