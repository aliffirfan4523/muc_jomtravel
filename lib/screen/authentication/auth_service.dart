import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:muc_jomtravel/service/user_service.dart';
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

      final user = result.user!;
      final isNewUser = result.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        await UserService().createUserIfNotExist(
          user,
          provider: 'google',
          name: user.displayName,
        );
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

      if (result.user == null) {
        return false;
      }
      await saveLoginStatus(rememberMe, result.user!.uid);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> registerWithEmailPassword(
    String email,
    String password,
    String name,
    bool rememberMe,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = result.user!;
      await user.updateDisplayName(name);

      await UserService().createUserIfNotExist(
        user,
        provider: 'email_password',
        name: name,
      );

      await saveLoginStatus(rememberMe, result.user!.uid);
      return true;
    } catch (signUpError) {
      if (signUpError is PlatformException) {
        if (signUpError.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
          /// `foo@bar.com` has alread been registered.
        }
      }
      return false;
    }
  }

  Future<void> saveLoginStatus(bool rememberMe, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setBool('rememberMe', true);
      await prefs.setString('userId', userId);
    } else {
      await prefs.setBool('rememberMe', false);
    }
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
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rememberMe');
    await prefs.remove('userId');
  }
}
