import 'package:absensi_go/src/core/constants/button_style.dart';
import 'package:absensi_go/src/core/constants/color_const.dart';
import 'package:absensi_go/src/core/constants/default_font.dart';
import 'package:absensi_go/src/core/constants/form_decoration.dart';
import 'package:absensi_go/src/core/utils/navigator.dart';
import 'package:absensi_go/src/features/auth/presentation/register_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscured = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 28),
              Text('Welcome Back', style: DefaultFont.header),
              Text('Sign in to your account', style: DefaultFont.body),
              SizedBox(height: 28),

              ///Login Form
              TextFormField(
                // controller: emailController,
                decoration: formInputConstant(
                  prefixIconData: Icon(Icons.email),
                  labelText: 'Email Adress',
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                // controller: passwordController,
                // obscureText: _isObscured,
                decoration: formInputConstant(
                  labelText: 'Password',
                  prefixIconData: Icon(Icons.key),
                ),
              ),

              Row(
                children: [
                  Checkbox(
                    value: !_isObscured,
                    onChanged: (onChanged) {
                      setState(() {
                        // _isObscured = !_isObscured;
                      });
                    },
                  ),
                  Text('Show Password'),
                  Spacer(),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Forgot Password?',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.pushReplacement(RegisterScreen());
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                style: AppButtonStyles.defaultButton(),
                onPressed: () async {},
                child: Text('Sign in'),
              ),
              SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  text: 'Don\'t have an account? ',
                  children: [
                    TextSpan(
                      text: 'Sign Up',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          context.pushReplacement(RegisterScreen());
                        },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
