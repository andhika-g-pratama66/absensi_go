import 'package:absensi_go/src/core/constants/button_style.dart';
import 'package:absensi_go/src/core/constants/default_font.dart';
import 'package:absensi_go/src/core/constants/form_decoration.dart';
import 'package:absensi_go/src/core/utils/navigator.dart';
import 'package:absensi_go/src/data/repositories/local_storage.dart';
import 'package:absensi_go/src/features/attendance/presentation/homescreen.dart';
import 'package:absensi_go/src/features/attendance/provider/attendance_provider.dart';
import 'package:absensi_go/src/features/auth/presentation/register_view.dart';
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';
import 'package:absensi_go/src/features/check_in/provider/get_today_check_in_provider.dart';
import 'package:absensi_go/src/features/check_out/provider/check_out_provider.dart';
import 'package:absensi_go/src/features/izin/provider/izin_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Reactive Logic: Listen to state changes for Navigation/Notifications
    ref.listen(authProvider, (previous, next) {
      next.whenOrNull(
        data: (userModel) {
          // ✅ Cek userModel langsung, bukan userModel?.data
          if (userModel != null) {
            // ==========================================
            // 2. INITIALIZE ALL USER DATA
            // Invalidate these so they fetch fresh data
            // the second the Homescreen loads
            // ==========================================
            ref.invalidate(attendanceProvider);
            ref.invalidate(getTodayCheckInProvider);
            ref.invalidate(checkOutProvider);
            ref.invalidate(izinProvider);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login   Berhasil'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigasi ke Homescreen
            context.pushAndRemoveAll(const Homescreen());
          }
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    });

    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          // Center content for better aesthetics on larger screens
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Welcome Back',
                    style: DefaultFont.header,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to your account',
                    style: DefaultFont.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  /// Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: formInputConstant(
                      prefixIconData: const Icon(Icons.email_outlined),
                      labelText: 'Alamat Email',
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Email wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  /// Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isObscured,
                    decoration:
                        formInputConstant(
                          labelText: 'Kata Sandi',
                          prefixIconData: const Icon(Icons.lock_outline),
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _isObscured = !_isObscured),
                          ),
                        ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Password wajib diisi'
                        : null,
                  ),

                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        /* Navigate to Forgot Password */
                      },
                      child: const Text(
                        'Lupa Kata Sandi?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// Login Button
                  ElevatedButton(
                    style: AppButtonStyles.defaultButton(),
                    onPressed: isLoading ? null : _handleLogin,
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

                  const SizedBox(height: 24),

                  /// Register Link
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: 'Belum punya akun? ',
                        children: [
                          TextSpan(
                            text: 'Daftar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => context.pushReplacement(
                                const RegisterScreen(),
                              ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      ref.read(authProvider.notifier).login(email, password);
    }
  }
}
