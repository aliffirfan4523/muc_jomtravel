import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/service/auth_service.dart';

class SignoutButton extends StatelessWidget {
  const SignoutButton({super.key, required AuthService authService})
    : _authService = authService;

  final AuthService _authService;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await _authService.signOut();
      },
      icon: Icon(Icons.logout),
    );
  }
}
