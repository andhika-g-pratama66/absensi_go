import 'dart:async';

import 'package:absensi_go/src/core/constants/app_colors.dart';
import 'package:absensi_go/src/core/utils/navigator.dart';
import 'package:absensi_go/src/data/repositories/auth_repository.dart';
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';
import 'package:absensi_go/src/features/forgot_password/presentation/new_password.dart';
import 'package:absensi_go/src/features/forgot_password/provider/change_password_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class ResetPasswordOtpPage extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordOtpPage({super.key, required this.email});

  @override
  ConsumerState<ResetPasswordOtpPage> createState() =>
      _ResetPasswordOtpPageState();
}

class _ResetPasswordOtpPageState extends ConsumerState<ResetPasswordOtpPage> {
  final List<TextEditingController> _ctrl = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _fn = List.generate(6, (_) => FocusNode());

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Tambahkan ini:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fn.first.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrl) c.dispose();
    for (final f in _fn) f.dispose();
    super.dispose();
  }

  void _startCountdown() {
    ref.read(otpCountdownProvider.notifier).state = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final cur = ref.read(otpCountdownProvider);
      if (cur <= 1) {
        t.cancel();
        ref.read(otpCountdownProvider.notifier).state = 0;
      } else {
        ref.read(otpCountdownProvider.notifier).state = cur - 1;
      }
    });
  }

  String get _otp => _ctrl.map((c) => c.text).join();

  Future<void> _resend() async {
    ref.read(otpResendProvider.notifier).state = true;
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.sendResetPasswordOtp(email: widget.email);

      if (!mounted) return;
      _showSnack('Kode OTP baru telah dikirim 📩', isError: false);
      _startCountdown();
      for (final c in _ctrl) c.clear();
      _fn.first.requestFocus();
    } catch (e) {
      _showSnack(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) ref.read(otpResendProvider.notifier).state = false;
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

  void _verifyAndNext() {
    if (_otp.length < 6) {
      _showSnack('Masukkan kode OTP lengkap 6 digit', isError: true);
      return;
    }

    // Karena API Anda tidak perlu verifikasi tengah (langsung di akhir),
    // kita cukup pindah ke page berikutnya membawa email & otp.
    context.push(NewPasswordPage(email: widget.email, otp: _otp));
  }

  void _onChanged(String val, int i) {
    if (val.length == 1 && i < 5) _fn[i + 1].requestFocus();
    if (_otp.length == 6) FocusScope.of(context).unfocus();
  }

  void _onKey(KeyEvent e, int i) {
    if (e is KeyDownEvent &&
        e.logicalKey == LogicalKeyboardKey.backspace &&
        _ctrl[i].text.isEmpty &&
        i > 0) {
      _fn[i - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVerifying = ref.watch(otpLoadingProvider);
    final isResending = ref.watch(otpResendProvider);
    final countdown = ref.watch(otpCountdownProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
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
                  Icons.pin_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Masukkan Kode OTP',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bodyText,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.labelText,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Kode 6 digit dikirim ke\n'),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.bodyText,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _StepRow(currentStep: 2),

              const SizedBox(height: 28),

              const Text(
                'KODE VERIFIKASI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.labelText,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),

              // ── 6 Kotak OTP ─────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (i) => KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: (e) => _onKey(e, i),
                    child: SizedBox(
                      width: 46,
                      height: 56,
                      child: TextFormField(
                        controller: _ctrl[i],
                        focusNode: _fn[i],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.bodyText,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E5E5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.darkBg,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (v) => _onChanged(v, i),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isVerifying ? null : _verifyAndNext,
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
                  child: isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Verifikasi Kode'),
                ),
              ),

              const SizedBox(height: 24),

              // Resend / countdown
              Center(
                child: countdown > 0
                    ? RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.labelText,
                          ),
                          children: [
                            const TextSpan(text: 'Kirim ulang dalam '),
                            TextSpan(
                              text: '$countdown detik',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.bodyText,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: isResending ? null : _resend,
                        child: AnimatedOpacity(
                          opacity: isResending ? 0.5 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE5E5E5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isResending)
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.darkBg,
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.refresh_rounded,
                                    size: 16,
                                    color: AppColors.darkBg,
                                  ),
                                const SizedBox(width: 7),
                                const Text(
                                  'Kirim Ulang OTP',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.bodyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 20),
              _InfoHint(
                'Kode OTP berlaku 5 menit. Periksa folder spam jika '
                'tidak menemukannya di inbox.',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
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
