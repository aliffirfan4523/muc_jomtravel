import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/service/services.dart';
import 'package:muc_jomtravel/src/shared/theme/app_colors.dart';

class GoogleLoginButton extends StatelessWidget {
  final String buttonText;
  final bool rememberMe;
  final VoidCallback? onTap;

  const GoogleLoginButton({
    super.key,
    this.buttonText = 'Continue with Google',
    this.rememberMe = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: onTap ??
            () async {
              await authService.saveRememberIntent(rememberMe);
              await authService.signInWithGoogle();
            },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon/g-icon.png',
              fit: BoxFit.contain,
              height: 22,
              width: 22,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.g_mobiledata_rounded,
                color: Colors.red,
                size: 26,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              buttonText,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
