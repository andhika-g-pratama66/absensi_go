import 'package:absensi_go/src/core/constants/button_style.dart';
import 'package:absensi_go/src/core/constants/default_font.dart';
import 'package:absensi_go/src/core/constants/form_decoration.dart';
import 'package:absensi_go/src/core/utils/navigator.dart';
import 'package:absensi_go/src/data/repositories/local_storage.dart';
import 'package:absensi_go/src/features/attendance/presentation/homescreen.dart';
// Import provider auth kamu di sini
// import 'package:absensi_go/src/features/auth/providers/auth_provider.dart';
import 'package:absensi_go/src/features/auth/presentation/register_view.dart';
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Controller untuk mengambil data dari TextField
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State lokal untuk UI (show/hide password) masih boleh di sini
  // atau dipindah ke provider jika ingin benar-benar clean.
  bool _isObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mendengarkan perubahan state untuk feedback (Error/Success)
    ref.listen(authProvider, (previous, next) {
      next.maybeWhen(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Colors.red,
            ),
          );
        },
        data: (user) {
          if (user != null) {
            // Jika login berhasil, pindah ke Home
            // context.pushReplacement(const HomeScreen());
          }
        },
        orElse: () {},
      );
    });

    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading; // Cek status loading dari provider

    // ... rest of your Scaffold
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // Agar tidak error overflow saat keyboard muncul
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 28),
              Text('Welcome Back', style: DefaultFont.header),
              Text('Sign in to your account', style: DefaultFont.body),
              const SizedBox(height: 28),

              /// Login Form
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: formInputConstant(
                  prefixIconData: const Icon(Icons.email),
                  labelText: 'Alamat Email',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: _isObscured,
                decoration: formInputConstant(
                  labelText: 'Kata Sandi',
                  prefixIconData: const Icon(Icons.key),
                ),
              ),

              Row(
                children: [
                  Checkbox(
                    value: !_isObscured,
                    onChanged: (val) {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  ),
                  const Text('Lihat Kata Sandi'),
                  const Spacer(),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Lupa Kata Sandi?',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Navigasi ke lupa password
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: AppButtonStyles.defaultButton(),
                // Matikan tombol jika sedang loading agar tidak double-click
                onPressed: isLoading
                    ? null
                    : () async {
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();

                        if (email.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Email dan password tidak boleh kosong',
                              ),
                            ),
                          );
                          return;
                        }

                        await ref
                            .read(authProvider.notifier)
                            .login(email, password);
                        LocalStorageService().saveToken(
                          ref.read(authProvider).value?.data?.token ?? "",
                        );
                        if (ref.read(authProvider).value?.data != null) {
                          context.pushReplacement(const Homescreen());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Login gagal. Coba lagi.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Masuk'),
              ),

              /// Tombol Login dengan State dari Provider
              const SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  text: 'Belum punya akun? ',
                  children: [
                    TextSpan(
                      text: 'Daftar',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          context.pushReplacement(const RegisterScreen());
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
