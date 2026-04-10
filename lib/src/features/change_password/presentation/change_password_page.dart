import 'package:absensi_go/src/core/constants/app_colors.dart';
import 'package:absensi_go/src/core/utils/navigator.dart';
import 'package:absensi_go/src/data/repositories/endpoint.dart';
import 'package:animate_do/animate_do.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';
import 'package:flutter_riverpod/legacy.dart';

// ─── Design Tokens (sama dengan ProfilPage) ───────────────────────────────────

// ─── Provider: loading state ──────────────────────────────────────────────────
final _loadingProvider = StateProvider<bool>((ref) => false);

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() =>
      AppColorshangePasswordPageState();
}

class AppColorshangePasswordPageState
    extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(_loadingProvider.notifier).state = true;
    try {
      final token =
          ref.read(authProvider).whenOrNull(data: (d) => d?.data?.token) ?? '';

      final dio = Dio();
      final response = await dio.post(
        '${Endpoint.baseUrl}/change-password', // ← sesuaikan endpoint
        data: {
          'old_password': _oldPassCtrl.text,
          'new_password': _newPassCtrl.text,
          'new_password_confirmation': _confirmCtrl.text,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        _showSnack('Password berhasil diperbarui 🎉', isError: false);
        context.pop();
      } else {
        _showSnack('Gagal memperbarui password', isError: true);
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Terjadi kesalahan';
      _showSnack(msg, isError: true);
    } finally {
      if (mounted) ref.read(_loadingProvider.notifier).state = false;
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? const Color(0xFF993C1D) : AppColors.darkBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(_loadingProvider);

    return Scaffold(
      backgroundColor: AppColors.inputBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            FadeInDown(
              child: Container(
                width: double.infinity,
                color: AppColors.darkBg,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Ganti Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Form ─────────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: FadeInUp(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _sectionLabel('KEAMANAN AKUN'),
                        const SizedBox(height: 12),

                        // Card berisi 3 field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.darkBg),
                          ),
                          child: Column(
                            children: [
                              _passwordField(
                                controller: _oldPassCtrl,
                                label: 'Password Lama',
                                hint: 'Masukkan password saat ini',
                                icon: Icons.lock_outline_rounded,
                                iconBg: const Color(0xFFE6F1FB),
                                iconColor: const Color(0xFF185FA5),
                                showPass: _showOld,
                                onToggle: () =>
                                    setState(() => _showOld = !_showOld),
                                isLast: false,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Wajib diisi'
                                    : null,
                              ),
                              _passwordField(
                                controller: _newPassCtrl,
                                label: 'Password Baru',
                                hint: 'Min. 8 karakter',
                                icon: Icons.lock_rounded,
                                iconBg: const Color(0xFFEAF3DE),
                                iconColor: const Color(0xFF3B6D11),
                                showPass: _showNew,
                                onToggle: () =>
                                    setState(() => _showNew = !_showNew),
                                isLast: false,
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Wajib diisi';
                                  if (v.length < 8) return 'Minimal 8 karakter';
                                  return null;
                                },
                              ),
                              _passwordField(
                                controller: _confirmCtrl,
                                label: 'Konfirmasi Password Baru',
                                hint: 'Ulangi password baru',
                                icon: Icons.verified_user_rounded,
                                iconBg: AppColors.primarySurface,
                                iconColor: AppColors.primaryLight,
                                showPass: _showConfirm,
                                onToggle: () => setState(
                                  () => _showConfirm = !_showConfirm,
                                ),
                                isLast: true,
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Wajib diisi';
                                  if (v != _newPassCtrl.text)
                                    return 'Password tidak cocok';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: isLoading ? null : _submit,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: isLoading
                                    ? AppColors.primaryLight
                                    : AppColors.darkBg,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Simpan Password',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Info hint
                        Row(
                          children: const [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 13,
                              color: AppColors.labelText,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Pastikan password baru mudah diingat dan tidak digunakan di platform lain.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.labelText,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

Widget _sectionLabel(String label) {
  return Text(
    label,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.labelText,
      letterSpacing: 0.8,
    ),
  );
}

Widget _passwordField({
  required TextEditingController controller,
  required String label,
  required String hint,
  required IconData icon,
  required Color iconBg,
  required Color iconColor,
  required bool showPass,
  required VoidCallback onToggle,
  required bool isLast,
  String? Function(String?)? validator,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      border: isLast
          ? null
          : const Border(bottom: BorderSide(color: Color(0x0F000000))),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: TextFormField(
            controller: controller,
            obscureText: !showPass,
            validator: validator,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.darkBg,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(
                fontSize: 11,
                color: AppColors.labelText,
              ),
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 12,
                color: Color(0xFFCCCCCC),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Icon(
                  showPass
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 16,
                  color: AppColors.labelText,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
