import 'dart:developer';

import 'package:absensi_go/src/core/constants/form_decoration.dart';
import 'package:absensi_go/src/core/utils/navigator.dart';
import 'package:absensi_go/src/core/constants/app_colors.dart';
import 'package:absensi_go/src/features/attendance/presentation/homescreen.dart';
import 'package:absensi_go/src/features/attendance/provider/attendance_provider.dart';
import 'package:absensi_go/src/features/auth/presentation/login_view.dart';
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';
import 'package:absensi_go/src/features/auth/provider/register_provider.dart';
import 'package:absensi_go/src/features/batch/provider/batch_provider.dart';
import 'package:absensi_go/src/features/check_in/provider/get_today_check_in_provider.dart';
import 'package:absensi_go/src/features/check_out/provider/check_out_provider.dart';
import 'package:absensi_go/src/features/izin/provider/izin_provider.dart';
import 'package:absensi_go/src/features/training/provider/training_provider.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

/// Section header: uppercase label + optional divider above
class _SectionHeader extends StatelessWidget {
  final String title;
  final bool showDividerAbove;

  const _SectionHeader(this.title, {this.showDividerAbove = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDividerAbove) ...[
          const SizedBox(height: 8),
          const Divider(color: AppColors.sectionDivider, thickness: 0.8),
          const SizedBox(height: 20),
        ],
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.labelText,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Field label above each input
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

/// Modern input decoration — replaces formInputConstant()

// ─── Progress Indicator ───────────────────────────────────────────────────────
class _StepProgressBar extends StatelessWidget {
  final int currentStep; // 1-indexed
  final int totalSteps;

  const _StepProgressBar({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final isDone = i + 1 < currentStep;
        final isActive = i + 1 == currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < totalSteps - 1 ? 6 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.darkBg
                  : isActive
                  ? AppColors.primaryLight
                  : AppColors.sectionDivider,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Main Screen ──────────────────────────────────────────────────────────────
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final Map<String, String> _genderOptions = {
    'Laki-Laki': 'L',
    'Perempuan': 'P',
  };

  // ─── Logic: tidak diubah ──────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(genderProvider.notifier).state = null;
      ref.read(selectedTrainingProvider.notifier).state = null;
      ref.read(selectedBatchProvider.notifier).state = null;
    });
    log("RegisterScreen Initialized");
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      final gender = ref.read(genderProvider);
      final trainingId = ref.read(selectedTrainingProvider);
      final batchId = ref.read(selectedBatchProvider);

      if (gender == null || trainingId == null || batchId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon lengkapi semua pilihan'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      ref
          .read(registerProvider.notifier)
          .registerUser(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            jenisKelamin: gender,
            batchId: batchId,
            trainingId: trainingId,
          );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.listen(registerProvider, (previous, next) {
      next.whenOrNull(
        data: (result) {
          if (result != null) {
            ref.invalidate(authProvider);
            ref.invalidate(attendanceProvider);
            ref.invalidate(getTodayCheckInProvider);
            ref.invalidate(checkOutProvider);
            ref.invalidate(izinProvider);
            ref.invalidate(registerProvider);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registrasi Berhasil'),
                backgroundColor: Colors.green,
              ),
            );

            context.pushAndRemoveAll(const Homescreen());
          }
        },
        error: (e, stackTrace) {
          String errorMessage = 'Gagal mendaftar: $e';
          if (e.toString().toLowerCase().contains('email') &&
              (e.toString().toLowerCase().contains('exists') ||
                  e.toString().toLowerCase().contains('terdaftar'))) {
            errorMessage = 'Email ini sudah terdaftar. Gunakan email lain.';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        },
      );
    });

    final isPasswordObscured = ref.watch(obscuredPasswordProvider);
    final isConfirmPasswordObscured = ref.watch(
      obscuredConfirmPasswordProvider,
    );
    final registerState = ref.watch(registerProvider);
    final selectedGender = ref.watch(genderProvider);
    final selectedTraining = ref.watch(selectedTrainingProvider);
    final selectedBatch = ref.watch(selectedBatchProvider);
    final trainingListAsync = ref.watch(trainingListProvider);
    final batchListAsync = ref.watch(batchListProvider);
    final isLoading =
        registerState.isLoading ||
        trainingListAsync.isLoading ||
        batchListAsync.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: Stack(
        children: [
          // ── Main Content ──────────────────────────────────────────────────
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
                      const SizedBox(height: 16),

                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.sectionDivider),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: AppColors.bodyText,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Progress bar
                      const _StepProgressBar(currentStep: 2, totalSteps: 3),
                      const SizedBox(height: 24),

                      // Title
                      const Text(
                        'Buat akun baru',
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
                        'Lengkapi data diri untuk memulai',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.labelText,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── SEKSI 1: Informasi Pribadi ────────────────────────
                      const _SectionHeader(
                        'Informasi pribadi',
                        showDividerAbove: false,
                      ),

                      // Nama Lengkap
                      const _FieldLabel('Nama lengkap'),
                      TextFormField(
                        controller: _nameController,
                        decoration: modernInputDecoration(
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          hintText: 'Masukkan nama lengkap',
                        ),
                        validator: (v) =>
                            v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      const _FieldLabel('Alamat email'),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: modernInputDecoration(
                          prefixIcon: const Icon(Icons.mail_outline_rounded),
                          hintText: 'email@contoh.com',
                        ),
                        validator: (v) =>
                            !v!.contains('@') ? 'Email tidak valid' : null,
                      ),
                      const SizedBox(height: 16),

                      // Jenis Kelamin
                      const _FieldLabel('Jenis kelamin'),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _genderOptions.values.contains(selectedGender)
                            ? selectedGender
                            : null,
                        hint: const Text(
                          'Pilih jenis kelamin',
                          style: TextStyle(
                            color: AppColors.hintText,
                            fontSize: 14,
                          ),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.labelText,
                        ),
                        decoration: modernInputDecoration(
                          prefixIcon: const Icon(Icons.wc_outlined),
                        ),
                        items: _genderOptions.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.value,
                            child: Text(entry.key),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            ref.read(genderProvider.notifier).state = val,
                        validator: (v) =>
                            v == null ? 'Pilih jenis kelamin' : null,
                      ),

                      // ── SEKSI 2: Program Pelatihan ────────────────────────
                      const _SectionHeader('Program pelatihan'),

                      // Training
                      const _FieldLabel('Program training'),
                      trainingListAsync.when(
                        loading: () => DropdownButtonFormField<int>(
                          isExpanded: true,
                          items: const [],
                          onChanged: null,
                          decoration: modernInputDecoration(
                            prefixIcon: const Icon(Icons.school_outlined),
                            hintText: 'Memuat data...',
                          ),
                        ),
                        error: (err, stack) => Text(
                          'Gagal memuat training: $err',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                        data: (trainings) => DropdownButtonFormField<int>(
                          initialValue: selectedTraining,
                          isExpanded: true,
                          hint: const Text(
                            'Pilih training',
                            style: TextStyle(
                              color: AppColors.hintText,
                              fontSize: 14,
                            ),
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.labelText,
                          ),
                          decoration: modernInputDecoration(
                            prefixIcon: const Icon(Icons.school_outlined),
                          ),
                          items: trainings.map((training) {
                            return DropdownMenuItem<int>(
                              value: training.id,
                              child: Text(training.title ?? ''),
                            );
                          }).toList(),
                          onChanged: (newValue) =>
                              ref
                                      .read(selectedTrainingProvider.notifier)
                                      .state =
                                  newValue,
                          validator: (value) =>
                              value == null ? 'Pilih program training' : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Batch
                      const _FieldLabel('Batch'),
                      batchListAsync.when(
                        loading: () => DropdownButtonFormField<int>(
                          isExpanded: true,
                          items: const [],
                          onChanged: null,
                          decoration: modernInputDecoration(
                            prefixIcon: const Icon(
                              Icons.calendar_today_outlined,
                            ),
                            hintText: 'Memuat data...',
                          ),
                        ),
                        error: (err, stack) => Text(
                          'Gagal memuat batch: $err',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                        data: (batches) => DropdownButtonFormField<int>(
                          initialValue: selectedBatch,
                          isExpanded: true,
                          hint: const Text(
                            'Pilih batch',
                            style: TextStyle(
                              color: AppColors.hintText,
                              fontSize: 14,
                            ),
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.labelText,
                          ),
                          decoration: modernInputDecoration(
                            prefixIcon: const Icon(
                              Icons.calendar_today_outlined,
                            ),
                          ),
                          items: batches.map((batch) {
                            return DropdownMenuItem<int>(
                              value: batch.id,
                              child: Text(batch.batchKe ?? ''),
                            );
                          }).toList(),
                          onChanged: (newValue) =>
                              ref.read(selectedBatchProvider.notifier).state =
                                  newValue,
                          validator: (value) =>
                              value == null ? 'Pilih batch' : null,
                        ),
                      ),

                      // ── SEKSI 3: Keamanan Akun ────────────────────────────
                      const _SectionHeader('Keamanan akun'),

                      // Password
                      const _FieldLabel('Kata sandi'),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: isPasswordObscured,
                        decoration: modernInputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          hintText: 'Minimal 6 karakter',
                          suffixIcon: IconButton(
                            onPressed: () =>
                                ref
                                        .read(obscuredPasswordProvider.notifier)
                                        .state =
                                    !isPasswordObscured,
                            icon: Icon(
                              isPasswordObscured
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                              color: AppColors.labelText,
                            ),
                          ),
                        ),
                        validator: (v) =>
                            v!.length < 6 ? 'Minimal 6 karakter' : null,
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      const _FieldLabel('Konfirmasi kata sandi'),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: isConfirmPasswordObscured,
                        decoration: modernInputDecoration(
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          hintText: 'Ulangi kata sandi',
                          suffixIcon: IconButton(
                            onPressed: () =>
                                ref
                                        .read(
                                          obscuredConfirmPasswordProvider
                                              .notifier,
                                        )
                                        .state =
                                    !isConfirmPasswordObscured,
                            icon: Icon(
                              isConfirmPasswordObscured
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                              color: AppColors.labelText,
                            ),
                          ),
                        ),
                        validator: (v) => v != _passwordController.text
                            ? 'Kata sandi tidak cocok'
                            : null,
                      ),

                      const SizedBox(height: 32),

                      // ── Submit Button ─────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleRegister,
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
                          child: const Text('Daftar sekarang'),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Back to Login ─────────────────────────────────────
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Sudah punya akun? ',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.labelText,
                            ),
                            children: [
                              TextSpan(
                                text: 'Login',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkBg,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => context.pushReplacement(
                                    const LoginScreen(),
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

          // ── Loading Overlay ───────────────────────────────────────────────
          if (isLoading)
            Container(
              color: Colors.black.withAlpha(40),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.darkBg,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
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
