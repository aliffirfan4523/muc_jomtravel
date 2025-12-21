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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(255, 97, 96, 96),
              width: 2,
            ),
          ),
          child: Scaffold(
            bottomSheet: Text("JomTravel V1.01"),
            body: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Register",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => requiredField(value, 'Full Name'),
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => validateEmail(value),
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
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
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
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
                        if (val!.isEmpty) return 'Empty';
                        if (val != _passwordController.text) return 'Not Match';
                        return null;
                      },
                      obscureText: !passwordVisible,
                    ),

                    SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (val) {
                            setState(() {
                              rememberMe = val!;
                            });
                          },
                        ),
                        Text("Remember Me"),
                      ],
                    ),
                    SizedBox(height: 20),
                    LoginRegisterButton(
                      buttonText: "Register",
                      onToggle: () async {
                        if (!_formKey.currentState!.validate()) {
                          return; // ⛔ validators will now show errors
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
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    GoogleLoginButton(
                      buttonText: 'Register with Google',
                      rememberMe: rememberMe,
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? "),
                        InkWell(
                          onTap: () {
                            widget.onLoginTap();
                          },
                          child: Text(
                            "Sign In",
                            style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }
}
