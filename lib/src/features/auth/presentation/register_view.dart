import 'dart:developer';

import 'package:absensi_go/src/core/constants/default_font.dart';
import 'package:absensi_go/src/core/constants/form_decoration.dart';
import 'package:absensi_go/src/core/utils/navigator.dart';
import 'package:absensi_go/src/features/auth/presentation/login_view.dart';
import 'package:absensi_go/src/features/auth/provider/register_provider.dart';
import 'package:absensi_go/src/features/batch/provider/batch_provider.dart';
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

  // Controller tetap berada di State karena terikat langsung dengan lifecycle widget
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final Map<String, String> _genderOptions = {
    'Laki-Laki': 'L',
    'Perempuan': 'P',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      // 1. Get current values from providers
      final gender = ref.read(genderProvider);
      final trainingId = ref.read(selectedTrainingProvider);
      final batchId = ref.read(selectedBatchProvider);

      // 2. Add a quick check (Optional but recommended)
      if (gender == null || trainingId == null || batchId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon lengkapi semua pilihan')),
        );
        return;
      }

      try {
        await ref
            .read(registerProvider.notifier)
            .registerUser(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              jenisKelamin: gender,
              batchId: batchId,
              trainingId: trainingId,
            );

        if (!mounted) return;
        log('Registration successful');

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Registrasi berhasil')));

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) context.pushReplacement(const LoginScreen());
        });
      } catch (e) {
        log('Registration Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. Pantau perubahan state (akan otomatis build ulang widget JIKA state ini berubah)
    final isPasswordObscured = ref.watch(obscuredPasswordProvider);
    final isConfirmPasswordObscured = ref.watch(
      obscuredConfirmPasswordProvider,
    );
    final isLoading = ref.watch(registerLoadingProvider);
    final selectedGender = ref.watch(genderProvider);
    final selectedTraining = ref.watch(selectedTrainingProvider);
    final selectedBatch = ref.watch(selectedBatchProvider);
    // Pantau data dari API
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

                Text('Nama Lengkap', style: DefaultFont.bodyBold),
                TextFormField(
                  controller: _nameController,
                  decoration: formInputConstant(
                    prefixIconData: const Icon(Icons.person_2_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                Text('Alamat Email', style: DefaultFont.bodyBold),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: formInputConstant(
                    prefixIconData: const Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                Text('Jenis Kelamin', style: DefaultFont.bodyBold),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  // Menggunakan initialValue untuk Flutter versi baru
                  initialValue: _genderOptions.entries
                      .where((entry) => entry.value == selectedGender)
                      .map((entry) => entry.key)
                      .firstOrNull,
                  icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  borderRadius: BorderRadius.circular(12),

                  // Mapping dari Map ke DropdownMenuItem
                  items: _genderOptions.keys.map((String label) {
                    return DropdownMenuItem(
                      value:
                          label, // Value di sini adalah 'Laki-Laki' atau 'Perempuan'
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(label),
                      ),
                    );
                  }).toList(),

                  onChanged: (label) {
                    // Simpan ke provider menggunakan value singkatnya ('L' atau 'P')
                    if (label != null) {
                      ref.read(genderProvider.notifier).state =
                          _genderOptions[label];
                    }
                  },
                  decoration: formInputConstant(),
                  validator: (value) =>
                      value == null ? 'Pilih jenis kelamin' : null,
                ),
                const SizedBox(height: 20),
                Text('Program Training', style: DefaultFont.bodyBold),
                trainingListAsync.when(
                  loading: () =>
                      const CircularProgressIndicator(), // Tampilan saat fetch API
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

                Text('Kata Sandi', style: DefaultFont.bodyBold),
                TextFormField(
                  controller: _passwordController,
                  obscureText:
                      isPasswordObscured, // Gunakan state dari Riverpod
                  decoration: formInputConstant(
                    prefixIconData: const Icon(Icons.lock_outline_rounded),
                    suffixIconData: IconButton(
                      onPressed: () {
                        // Toggle state menggunakan ref.read
                        ref.read(obscuredPasswordProvider.notifier).state =
                            !isPasswordObscured;
                      },
                      icon: Icon(
                        isPasswordObscured
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text('Konfirmasi Kata Sandi', style: DefaultFont.bodyBold),
                TextFormField(
                  // validator: (value) {},
                  obscureText:
                      isConfirmPasswordObscured, // Gunakan state dari Riverpod
                  decoration: formInputConstant(
                    prefixIconData: const Icon(Icons.lock_outline_rounded),
                    suffixIconData: IconButton(
                      onPressed: () {
                        ref
                                .read(obscuredConfirmPasswordProvider.notifier)
                                .state =
                            !isConfirmPasswordObscured;
                      },
                      icon: Icon(
                        isConfirmPasswordObscured
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Daftar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                Center(
                  child: Text.rich(
                    TextSpan(
                      text: 'Sudah punya akun? ',
                      children: [
                        TextSpan(
                          text: 'Masuk',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.pushReplacement(const LoginScreen());
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
