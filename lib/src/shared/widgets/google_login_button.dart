import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/service/auth_service.dart';

class GoogleLoginButton extends StatelessWidget {
  GoogleLoginButton({
    super.key,
    required this.buttonText,
    required this.rememberMe,
  });
  final AuthService _authService = AuthService();
  final String buttonText;
  final bool rememberMe;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 49,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.black),
          ),
        ),
        onPressed: () async {
          await _authService.saveRememberIntent(rememberMe);
          await _authService.signInWithGoogle();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              // decoration: BoxDecoration(color: Colors.blue),
              child: Image.asset(
                'assets/icon/g-icon.png',
                fit: BoxFit.cover,
                height: 32,
                width: 32,
              ),
            ),
            Text(
              buttonText,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
