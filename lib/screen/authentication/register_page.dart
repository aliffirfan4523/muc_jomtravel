import 'package:flutter/material.dart';
import 'package:muc_jomtravel/screen/authentication/auth_service.dart';
import 'package:muc_jomtravel/shared/utils/validator.dart';
import 'package:muc_jomtravel/shared/widgets/google_login_button.dart';
import 'package:muc_jomtravel/shared/widgets/login_register_button.dart';
import 'package:muc_jomtravel/shared/widgets/view_pass_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

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
                        final result = await _authService
                            .registerWithEmailPassword(
                              _emailController.text,
                              _passwordController.text,
                              _nameController.text,
                              rememberMe,
                            );

                        if (result) {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    GoogleLoginButton(buttonText: 'Register with Google'),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? "),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
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
