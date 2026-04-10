import 'package:absensi_go/src/core/constants/app_colors.dart';
import 'package:absensi_go/src/core/constants/form_decoration.dart';
import 'package:absensi_go/src/core/utils/navigator.dart';
import 'package:absensi_go/src/features/attendance/presentation/homescreen.dart';
import 'package:absensi_go/src/features/attendance/provider/attendance_provider.dart';
import 'package:absensi_go/src/features/auth/presentation/register_view.dart';
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';
import 'package:absensi_go/src/features/check_in/provider/get_today_check_in_provider.dart';
import 'package:absensi_go/src/features/check_out/provider/check_out_provider.dart';
import 'package:absensi_go/src/features/forgot_password/presentation/forgot_password.dart';
import 'package:absensi_go/src/features/izin/provider/izin_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Design Tokens (sama dengan RegisterScreen) ───────────────────────────────

/// Modern input decoration — konsisten dengan RegisterScreen

// ─── Login Screen ─────────────────────────────────────────────────────────────
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

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      ref.read(authProvider.notifier).login(email, password);

      // ref.read(localStorageProvider).saveToken();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ─── Logic: tidak diubah ──────────────────────────────────────────────
    ref.listen(authProvider, (previous, next) {
      next.whenOrNull(
        data: (userModel) {
          if (userModel != null) {
            ref.invalidate(attendanceProvider);
            ref.invalidate(getTodayCheckInProvider);
            ref.invalidate(checkOutProvider);
            ref.invalidate(izinProvider);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login Berhasil'),
                backgroundColor: Colors.green,
              ),
            );

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
      backgroundColor: const Color(0xFFF7F7F9),
      body: Stack(
        children: [
          // ── Main Content ────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: AbsorbPointer(
                  absorbing: isLoading,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),

                      // ── Logo / Brand Mark ─────────────────────────────
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.darkBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primaryLight.withOpacity(0.5),
                          ),
                        ),
                        child: const Icon(
                          Icons.fingerprint_rounded,
                          color: AppColors.darkBg,
                          size: 28,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Title ─────────────────────────────────────────
                      const Text(
                        'Selamat datang',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.bodyText,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Masuk untuk melanjutkan',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.labelText,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ── Email ─────────────────────────────────────────
                      const _FieldLabel('Alamat email'),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: modernInputDecoration(
                          prefixIcon: const Icon(Icons.mail_outline_rounded),
                          hintText: 'email@contoh.com',
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Email wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // ── Password ──────────────────────────────────────
                      const _FieldLabel('Kata sandi'),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscured,
                        decoration: modernInputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          hintText: 'Masukkan kata sandi',
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _isObscured = !_isObscured),
                            icon: Icon(
                              _isObscured
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                              color: AppColors.labelText,
                            ),
                          ),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Password wajib diisi'
                            : null,
                      ),

                      const SizedBox(height: 12),
                      Align(
                        alignment: AlignmentGeometry.topRight,
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.labelText,
                            ),
                            children: [
                              TextSpan(
                                text: 'Lupa Kata Sandi?',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkBg,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () =>
                                      context.push(const ForgotPasswordPage()),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // ── Submit Button ─────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkBg,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.primaryLight,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          child: const Text(
                            'Masuk',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Register Link ─────────────────────────────────
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Belum punya akun? ',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.labelText,
                            ),
                            children: [
                              TextSpan(
                                text: 'Daftar',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkBg,
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

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Loading Overlay ─────────────────────────────────────────────
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.darkBg,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Mohon tunggu...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.bodyText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Reusable Widget (duplikat dari register agar standalone) ─────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.bodyText,
        ),
      ),
    );
  }
}
