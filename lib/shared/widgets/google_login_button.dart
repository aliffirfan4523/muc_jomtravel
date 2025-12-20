import 'package:flutter/material.dart';
import 'package:muc_jomtravel/screen/authentication/auth_service.dart';

class GoogleLoginButton extends StatelessWidget {
  GoogleLoginButton({super.key, required this.buttonText});
  final AuthService _authService = AuthService();
  final String buttonText;

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
