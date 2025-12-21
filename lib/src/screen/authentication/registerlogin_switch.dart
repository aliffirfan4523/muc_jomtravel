import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/screen/authentication/login_page.dart';
import 'package:muc_jomtravel/src/screen/authentication/register_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool showLogin = true;

  void _showRegister() {
    setState(() => showLogin = false);
  }

  void _showLogin() {
    setState(() => showLogin = true);
  }

  @override
  Widget build(BuildContext context) {
    return showLogin
        ? LoginPage(onRegisterTap: _showRegister)
        : RegisterPage(onLoginTap: _showLogin);
  }
}
