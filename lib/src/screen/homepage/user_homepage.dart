import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/service/auth_service.dart';
import 'package:muc_jomtravel/src/shared/widgets/sign_out_button.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Homepage"),
        actions: [SignoutButton(authService: _authService)],
      ),
      body: Center(child: Text("Hello User")),
    );
  }
}
