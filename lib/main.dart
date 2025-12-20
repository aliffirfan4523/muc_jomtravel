import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:muc_jomtravel/firebase_options.dart';
import 'package:muc_jomtravel/screen/authentication/admin_login_page.dart';
import 'package:muc_jomtravel/screen/authentication/auth_service.dart';
import 'package:muc_jomtravel/screen/authentication/login_page.dart';
import 'package:muc_jomtravel/screen/authentication/register_page.dart';
import 'package:muc_jomtravel/screen/homepage/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await GoogleSignIn.instance.initialize();

  await AuthService().handleAutoLogoutIfNeeded();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/home": (_) => Homepage(),
        "/login": (_) => LoginPage(),
        "/register": (_) => RegisterPage(),
        "/adminlogin": (_) => AdminLoginPage(),
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return Homepage();
          }

          return LoginPage();
        },
      ),
    );
  }
}
