import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/service/auth_service.dart';
import 'package:muc_jomtravel/src/service/user_service.dart';
import 'package:muc_jomtravel/src/shared/utils/validator.dart';
import 'package:muc_jomtravel/src/shared/widgets/google_login_button.dart';
import 'package:muc_jomtravel/src/shared/widgets/login_register_button.dart';
import 'package:muc_jomtravel/src/shared/widgets/view_pass_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.onLoginTap});

  final VoidCallback onLoginTap;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool rememberMe = false;
  bool passwordVisible = false;
  final AuthService _authService = AuthService();
  final UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/kl.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark Overlay
          Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
          ),
          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Create Account",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            color: Color(0xFF00695C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Join us and explore the world",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 30),

                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          validator: (value) =>
                              requiredField(value, 'Full Name'),
                        ),

                        const SizedBox(height: 15),

                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          validator: (value) => validateEmail(value),
                        ),

                        const SizedBox(height: 15),

                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            suffixIcon: ViewPasswordButton(
                              isVisible: passwordVisible,
                              onToggle: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !passwordVisible,
                          validator: (val) => validatePassword(val),
                        ),

                        const SizedBox(height: 15),

                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_reset),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            suffixIcon: ViewPasswordButton(
                              isVisible: passwordVisible,
                              onToggle: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (val) {
                            if (val!.isEmpty)
                              return 'Please confirm your password';
                            if (val != _passwordController.text)
                              return 'Passwords do not match';
                            return null;
                          },
                          obscureText: !passwordVisible,
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              activeColor: const Color(0xFF00695C),
                              onChanged: (val) {
                                setState(() {
                                  rememberMe = val!;
                                });
                              },
                            ),
                            const Text("Remember Me"),
                          ],
                        ),

                        const SizedBox(height: 20),

                        LoginRegisterButton(
                          buttonText: "Register",
                          onToggle: () async {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }
                            await _authService.saveRememberIntent(rememberMe);
                            await userService.savePendingProfile(
                              name: _nameController.text,
                            );
                            try {
                              await _authService.registerWithEmailPassword(
                                _emailController.text,
                                _passwordController.text,
                              );
                            } on FirebaseAuthException catch (e) {
                              String message = 'Registration failed';
                              if (e.code == 'email-already-in-use') {
                                message = 'The email is already in use.';
                              } else if (e.code == 'weak-password') {
                                message = 'The password provided is too weak.';
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: const [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "OR",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 20),

                        GoogleLoginButton(
                          buttonText: 'Register with Google',
                          rememberMe: rememberMe,
                        ),

                        const SizedBox(height: 30),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account? "),
                            InkWell(
                              onTap: () {
                                widget.onLoginTap();
                              },
                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00695C),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
