import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late UserCredential result;

  Future<bool> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        result = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final googleUser = await GoogleSignIn.instance.authenticate();
        final googleAuth = googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        result = await FirebaseAuth.instance.signInWithCredential(credential);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signInWithEmailPassword(
    String email,
    String password,
    bool rememberMe,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user != null ? true : false;
    } catch (e) {
      return false;
    }
  }

  Future<void> registerWithEmailPassword(String email, String password) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    try {
      print('Firestore user created');
    } catch (e) {
      print('Error creating Firestore user: $e');
    }
  }

  Future<void> saveRememberIntent(bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', rememberMe);
  }

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('rememberMe') ?? false;
    final userId = prefs.getString('userId');
    return isLoggedIn && userId != null;
  }

  Future<void> handleAutoLogoutIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('rememberMe') ?? false;

    if (!rememberMe) {
      await FirebaseAuth.instance.signOut();

      if (!kIsWeb) {
        await GoogleSignIn.instance.signOut();
      }
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await GoogleSignIn.instance.signOut();
    }

    // 🔴 Firebase sign-out (MANDATORY)
    await _auth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rememberMe');
    await prefs.remove('userId');
  }
}
