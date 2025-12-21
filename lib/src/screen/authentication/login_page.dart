import 'package:flutter/material.dart';
import 'package:muc_jomtravel/src/service/auth_service.dart';
import 'package:muc_jomtravel/src/shared/utils/validator.dart';
import 'package:muc_jomtravel/src/shared/widgets/google_login_button.dart';
import 'package:muc_jomtravel/src/shared/widgets/login_register_button.dart';
import 'package:muc_jomtravel/src/shared/widgets/view_pass_button.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key, required this.onRegisterTap});

  final VoidCallback onRegisterTap;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool rememberMe = false;
  bool passwordVisible = false;

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
                      "Login",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                    SizedBox(height: 30),

                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => validateEmail(value),
                    ),
                    SizedBox(height: 20),

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
                      validator: (value) => requiredField(value, 'Password'),
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

                    InkWell(onTap: () {}, child: Text("Forgot Password?")),

                    SizedBox(height: 20),

                    LoginRegisterButton(
                      buttonText: "Login",
                      onToggle: () async {
                        if (!_formKey.currentState!.validate()) {
                          return; // ⛔ validators will now show errors
                        }
                        await _authService.saveRememberIntent(rememberMe);

                        final result = await _authService
                            .signInWithEmailPassword(
                              _emailController.text,
                              _passwordController.text,
                              rememberMe,
                            );

                        if (!result) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Invalid credentials. Please try again.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    GoogleLoginButton(
                      buttonText: 'Sign in with Google',
                      rememberMe: rememberMe,
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Dont have an account? "),
                        InkWell(
                          onTap: widget.onRegisterTap,
                          child: Text(
                            "Sign Up",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
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
