import 'dart:developer';

import 'package:absensi_go/src/core/constants/default_font.dart';
import 'package:absensi_go/src/core/constants/form_decoration.dart';
import 'package:absensi_go/src/core/utils/navigator.dart';
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

  // 1. Sederhanakan fungsi _handleRegister.
  // Biarkan ini hanya bertugas memanggil fungsi di provider.
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

      // Panggil method register, tidak perlu await di sini
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

  @override
  Widget build(BuildContext context) {
    // 2. Gunakan ref.listen untuk memantau perubahan state registerProvider
    ref.listen(registerProvider, (previous, next) {
      next.whenOrNull(
        data: (result) {
          if (result != null) {
            // Reset state agar jika user log out, state ini tidak menyangkut
            ref.invalidate(authProvider);
            ref.invalidate(attendanceProvider);
            ref.invalidate(getTodayCheckInProvider);
            ref.invalidate(checkOutProvider);
            ref.invalidate(izinProvider);

            // ==========================================

            // Reset the register state so it doesn't linger
            ref.invalidate(registerProvider);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registrasi   Berhasil'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigasi ke Homescreen
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

    // Watchers
    final isPasswordObscured = ref.watch(obscuredPasswordProvider);
    final isConfirmPasswordObscured = ref.watch(
      obscuredConfirmPasswordProvider,
    );
    final isLoading = ref.watch(
      registerLoadingProvider,
    ); // Pastikan ini nge-watch status loading
    final selectedGender = ref.watch(genderProvider);
    final selectedTraining = ref.watch(selectedTrainingProvider);
    final selectedBatch = ref.watch(selectedBatchProvider);

    final trainingListAsync = ref.watch(trainingListProvider);
    final batchListAsync = ref.watch(batchListProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text('Buat Akun', style: DefaultFont.header),
                const SizedBox(height: 48),

                // --- Nama Lengkap ---
                Text('Nama Lengkap', style: DefaultFont.bodyBold),
                TextFormField(
                  controller: _nameController,
                  decoration: formInputConstant(
                    prefixIconData: const Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 20),

                // --- Email ---
                Text('Alamat Email', style: DefaultFont.bodyBold),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: formInputConstant(
                    prefixIconData: const Icon(Icons.email_outlined),
                  ),
                  validator: (v) =>
                      !v!.contains('@') ? 'Email tidak valid' : null,
                ),
                const SizedBox(height: 20),

                // --- Gender Dropdown ---
                Text('Jenis Kelamin', style: DefaultFont.bodyBold),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _genderOptions.values.contains(selectedGender)
                      ? selectedGender
                      : null,
                  items: _genderOptions.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.value,
                      child: Text(entry.key),
                    );
                  }).toList(),
                  onChanged: (val) =>
                      ref.read(genderProvider.notifier).state = val,
                  decoration: formInputConstant(),
                  validator: (v) => v == null ? 'Pilih jenis kelamin' : null,
                ),
                const SizedBox(height: 20),

                // --- Training Dropdown ---
                Text('Program Training', style: DefaultFont.bodyBold),
                trainingListAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (err, stack) => Text('Gagal memuat training: $err'),
                  data: (trainings) {
                    return DropdownButtonFormField<int>(
                      initialValue: selectedTraining,
                      isExpanded: true,
                      hint: const Text('Pilih Training'),
                      icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                      decoration: formInputConstant(),
                      items: trainings.map((training) {
                        return DropdownMenuItem<int>(
                          value: training.id,
                          child: Text(training.title ?? ""),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        ref.read(selectedTrainingProvider.notifier).state =
                            newValue;
                      },
                      validator: (value) =>
                          value == null ? 'Pilih program training' : null,
                    );
                  },
                ),
                const SizedBox(height: 20),

                // --- Batch Dropdown ---
                Text('Batch', style: DefaultFont.bodyBold),
                batchListAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (err, stack) => Text('Gagal memuat batch: $err'),
                  data: (batches) {
                    return DropdownButtonFormField<int>(
                      initialValue: selectedBatch,
                      isExpanded: true,
                      hint: const Text('Pilih Batch'),
                      icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                      decoration: formInputConstant(),
                      items: batches.map((batch) {
                        return DropdownMenuItem<int>(
                          value: batch.id,
                          child: Text(batch.batchKe ?? ""),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        ref.read(selectedBatchProvider.notifier).state =
                            newValue;
                      },
                      validator: (value) =>
                          value == null ? 'Pilih batch' : null,
                    );
                  },
                ),
                const SizedBox(height: 20),

                // --- Password ---
                Text('Kata Sandi', style: DefaultFont.bodyBold),
                TextFormField(
                  controller: _passwordController,
                  obscureText: isPasswordObscured,
                  decoration: formInputConstant(
                    prefixIconData: const Icon(Icons.lock_outline),
                    suffixIconData: IconButton(
                      onPressed: () =>
                          ref.read(obscuredPasswordProvider.notifier).state =
                              !isPasswordObscured,
                      icon: Icon(
                        isPasswordObscured
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (v) => v!.length < 6 ? 'Minimal 6 karakter' : null,
                ),
                const SizedBox(height: 20),

                // --- Confirm Password ---
                Text('Konfirmasi Kata Sandi', style: DefaultFont.bodyBold),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: isConfirmPasswordObscured,
                  decoration: formInputConstant(
                    prefixIconData: const Icon(Icons.lock_reset),
                    suffixIconData: IconButton(
                      onPressed: () =>
                          ref
                                  .read(
                                    obscuredConfirmPasswordProvider.notifier,
                                  )
                                  .state =
                              !isConfirmPasswordObscured,
                      icon: Icon(
                        isConfirmPasswordObscured
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (v) => v != _passwordController.text
                      ? 'Kata sandi tidak cocok'
                      : null,
                ),
                const SizedBox(height: 40),

                // --- Submit Button ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleRegister,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Daftar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
