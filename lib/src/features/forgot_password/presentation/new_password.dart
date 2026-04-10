import 'package:absensi_go/src/core/constants/app_colors.dart';
import 'package:absensi_go/src/core/constants/form_decoration.dart';
import 'package:absensi_go/src/core/utils/navigator.dart';
import 'package:absensi_go/src/data/repositories/auth_repository.dart';
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final _newPassLoadingProvider = StateProvider<bool>((ref) => false);
final _showNewPassProvider = StateProvider<bool>((ref) => false);
final _showConfirmPassProvider = StateProvider<bool>((ref) => false);

class NewPasswordPage extends ConsumerStatefulWidget {
  final String email;
  final String otp;

  const NewPasswordPage({super.key, required this.email, required this.otp});

  @override
  ConsumerState<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends ConsumerState<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(_newPassLoadingProvider.notifier).state = true;
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.resetPassword(
        email: widget.email,
        otp: widget.otp,
        newPassword: _newPassCtrl.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password berhasil diperbarui ✅'),
          backgroundColor: AppColors.darkBg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Kembali ke halaman profil (pop semua step: NewPass + OTP + Email)
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      context.pop(); // NewPasswordPage
      context.pop(); // ResetPasswordOtpPage
      context.pop(); // ForgotPasswordPage
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) ref.read(_newPassLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(_newPassLoadingProvider);
    final showNew = ref.watch(_showNewPassProvider);
    final showConfirm = ref.watch(_showConfirmPassProvider);

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

                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.darkBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Password Baru',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.bodyText,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Buat password baru yang kuat dan\nmudah kamu ingat.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.labelText,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 32),

                    _StepRow(currentStep: 3),

                    const SizedBox(height: 28),

                    const Text(
                      'KEAMANAN AKUN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.labelText,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Password baru
                    TextFormField(
                      controller: _newPassCtrl,
                      obscureText: !showNew,
                      decoration: modernInputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        hintText: 'Minimal 8 karakter',
                        suffixIcon: IconButton(
                          onPressed: () =>
                              ref.read(_showNewPassProvider.notifier).state =
                                  !showNew,
                          icon: Icon(
                            showNew
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.labelText,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib diisi';
                        if (v.length < 8) return 'Minimal 8 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Konfirmasi password
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: !showConfirm,
                      decoration: modernInputDecoration(
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        hintText: 'Ulangi password baru',
                        suffixIcon: IconButton(
                          onPressed: () =>
                              ref
                                      .read(_showConfirmPassProvider.notifier)
                                      .state =
                                  !showConfirm,
                          icon: Icon(
                            showConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.labelText,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib diisi';
                        if (v != _newPassCtrl.text)
                          return 'Password tidak cocok';
                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
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
                            : const Text('Simpan Password Baru'),
                      ),
                    ),

                    const SizedBox(height: 16),
                    _InfoHint(
                      'Gunakan kombinasi huruf besar, angka, dan simbol '
                      'agar password lebih aman.',
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
