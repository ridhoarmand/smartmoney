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
    } catch (e) {
      print("Sign Up Error: $e");
      return null;
    }
  }

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      UserCredential? userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Reload user after successful sign-in to ensure data is updated
      await _auth.currentUser?.reload();
      return userCredential;
    } catch (e) {
      print("Sign In Error: $e");
      return null;
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
      if (e.code == 'account-exists-with-different-credential') {
        print("Account exists with different credential.");
      } else if (e.code == 'invalid-credential') {
        print("Invalid Google credential.");
      }
      return null;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }
}
