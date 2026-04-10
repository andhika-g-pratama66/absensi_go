import 'package:absensi_go/src/core/constants/app_colors.dart';
import 'package:absensi_go/src/core/constants/form_decoration.dart';
import 'package:absensi_go/src/core/utils/navigator.dart';
import 'package:absensi_go/src/data/repositories/auth_repository.dart';
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';
import 'package:absensi_go/src/features/forgot_password/presentation/new_password.dart';
import 'package:absensi_go/src/features/forgot_password/presentation/otp_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final _fpLoadingProvider = StateProvider<bool>((ref) => false);

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill email user yang sedang login (jika ada)
    final email =
        ref.read(authProvider).whenOrNull(data: (d) => d?.data?.user?.email) ??
        '';
    _emailCtrl.text = email;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(_fpLoadingProvider.notifier).state = true;
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.sendResetPasswordOtp(email: _emailCtrl.text.trim());

      if (!mounted) return;
      context.push(ResetPasswordOtpPage(email: _emailCtrl.text.trim()));
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) ref.read(_fpLoadingProvider.notifier).state = false;
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : AppColors.darkBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(_fpLoadingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Back
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE5E5E5)),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: AppColors.bodyText,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Icon
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.darkBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Ganti Password',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.bodyText,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Masukkan email akunmu. Kami akan\nmengirimkan kode OTP untuk verifikasi.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.labelText,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Step indicator
                    _StepRow(currentStep: 1),

                    const SizedBox(height: 28),

                    const Text(
                      'ALAMAT EMAIL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.labelText,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: modernInputDecoration(
                        prefixIcon: const Icon(Icons.mail_outline_rounded),
                        hintText: 'email@contoh.com',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email wajib diisi';
                        final ok = RegExp(
                          r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$',
                        ).hasMatch(v);
                        return ok ? null : 'Format email tidak valid';
                      },
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _sendOtp,
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
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Kirim Kode OTP'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info hint
                    _InfoHint(
                      'Kode OTP berlaku 5 menit. Periksa folder spam jika '
                      'tidak menemukannya di inbox.',
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          if (isLoading) const _LoadingOverlay(),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int currentStep; // 1, 2, atau 3

  const _StepRow({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final labels = ['Email', 'Kode OTP', 'Password Baru'];
    return Row(
      children: List.generate(labels.length, (i) {
        final step = i + 1;
        final isDone = step < currentStep;
        final isActive = step == currentStep;

        return Expanded(
          child: Row(
            children: [
              // Circle
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone || isActive
                      ? AppColors.darkBg
                      : const Color(0xFFE5E5E5),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(
                          Icons.check_rounded,
                          size: 13,
                          color: Colors.white,
                        )
                      : Text(
                          '$step',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? Colors.white
                                : AppColors.labelText,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isActive
                            ? AppColors.bodyText
                            : AppColors.labelText,
                      ),
                    ),
                    if (i < labels.length - 1)
                      Container(
                        height: 1,
                        margin: const EdgeInsets.only(top: 4, right: 8),
                        color: isDone
                            ? AppColors.darkBg
                            : const Color(0xFFE5E5E5),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─── Info hint box ─────────────────────────────────────────────────────────────
class _InfoHint extends StatelessWidget {
  final String text;
  const _InfoHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 15,
            color: AppColors.labelText,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.labelText,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Loading overlay ───────────────────────────────────────────────────────────
class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(40),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
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
    );
  }
}
