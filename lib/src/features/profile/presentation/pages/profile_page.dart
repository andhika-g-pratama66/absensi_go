import 'dart:convert';

import 'package:absensi_go/src/core/utils/navigator.dart';
import 'package:absensi_go/src/data/repositories/endpoint.dart';
import 'package:absensi_go/src/features/attendance/provider/bottom_nav_index_provider.dart';
import 'package:absensi_go/src/features/attendance/provider/history_provider.dart';
import 'package:absensi_go/src/features/attendance/provider/stat_provider.dart';
import 'package:absensi_go/src/features/auth/presentation/login_view.dart';
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';
import 'package:absensi_go/src/features/change_password/presentation/change_password_page.dart';
import 'package:absensi_go/src/features/forgot_password/presentation/forgot_password.dart';
import 'package:absensi_go/src/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Design Tokens (konsisten dengan Login & Register) ────────────────────────
class _AppColors {
  static const primary = Color(0xFF1A1A2E);
  static const primaryLight = Color(0xFF4A4A6A);
  static const primarySurface = Color(0xFFE8E8F0);

  static const bodyText = Color(0xFF1A1A2E);
  static const labelText = Color(0xFF888888);

  static const cardBorder = Color(0x0F000000); // black ~6%
  static const dividerColor = Color(0x0F000000);
  static const pageBg = Color(0xFFF7F7F9);
}

class ProfilPage extends ConsumerWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ─── Logic: tidak diubah ──────────────────────────────────────────────
    final userModel = ref.watch(authProvider);
    final stat = ref.watch(attendanceStatsProvider);
    final user = userModel.whenOrNull(data: (data) => data);

    final name = user?.data?.user?.name ?? '';
    final email = user?.data?.user?.email ?? '';
    final gender = user?.data?.user?.jenisKelamin ?? '';
    final training = user?.data?.user?.training?.title ?? '';
    final batch = user?.data?.user?.batch?.batchKe ?? '';

    final now = DateTime.now();
    String status = 'Tidak Aktif';
    final endDate = user?.data?.user?.batch?.endDate;
    if (endDate != null) {
      try {
        status = endDate.isAfter(now) ? 'Peserta Aktif' : 'Tidak Aktif';
      } catch (e) {
        status = 'Tidak Aktif';
      }
    }

    final cleanName = name.trim();
    final parts = cleanName.isNotEmpty ? cleanName.split(RegExp(r'\s+')) : [];
    String initials = 'U';
    if (parts.length >= 2) {
      if (parts[0].isNotEmpty && parts[1].isNotEmpty) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
    } else if (parts.length == 1 && parts[0].isNotEmpty) {
      initials = parts[0][0].toUpperCase();
    }
    // ─────────────────────────────────────────────────────────────────────

    return Scaffold(
      backgroundColor: _AppColors.pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(
                name,
                email,
                initials,
                status,
                user?.data?.user?.profilePhoto,
              ),
              _buildStatCard(
                hadir: stat.value?.totalMasuk.toString() ?? '0',
                total: stat.value?.totalAbsen.toString() ?? '0',
                sakit: stat.value?.totalIzin.toString() ?? '0',
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('INFORMASI PRIBADI'),
                    const SizedBox(height: 10),
                    _buildInfoCard(name, email, gender, training, batch),
                    const SizedBox(height: 16),
                    _buildSectionLabel('KEAMANAN AKUN'),
                    const SizedBox(height: 16),
                    _buildAccountSecurityGroup(context),
                    const SizedBox(height: 10),
                    _buildLogoutButton(context, ref),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    String name,
    String email,
    String initials,
    String status,
    String? rawProfilePhoto,
  ) {
    final isActive = status == 'Peserta Aktif';

    return FadeInDown(
      child: Container(
        width: double.infinity,
        color: _AppColors.primary,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 52),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profil Saya',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                // Subtle version badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'AbsensiGo',
                    style: TextStyle(fontSize: 11, color: Colors.white38),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Avatar + info row
            Row(
              children: [
                _buildAvatar(rawProfilePhoto, initials),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? 'User' : name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white38,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),

                      // Status pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0x2200C853)
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive
                                ? const Color(0x4400C853)
                                : Colors.white12,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive
                                    ? const Color(0xFF4ade80)
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: 11,
                                color: isActive
                                    ? const Color(0xFF4ade80)
                                    : Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String? rawProfilePhoto, String initials) {
    DecorationImage? decorationImage;

    if (rawProfilePhoto != null && rawProfilePhoto.isNotEmpty) {
      if (rawProfilePhoto.contains('/') && !rawProfilePhoto.contains(',')) {
        decorationImage = DecorationImage(
          image: NetworkImage(Endpoint.publicImages + rawProfilePhoto),
          fit: BoxFit.cover,
        );
      } else {
        try {
          final cleanBase64 = rawProfilePhoto.contains(',')
              ? rawProfilePhoto.split(',').last
              : rawProfilePhoto;
          final imageBytes = base64Decode(cleanBase64);
          decorationImage = DecorationImage(
            image: MemoryImage(imageBytes),
            fit: BoxFit.cover,
          );
        } catch (e) {
          debugPrint('Error decoding profile photo: $e');
        }
      }
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white12,
        border: Border.all(color: Colors.white24, width: 2),
        image: decorationImage,
      ),
      child: decorationImage == null
          ? Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildStatCard({
    required String hadir,
    required String total,
    required String sakit,
  }) {
    return Transform.translate(
      offset: const Offset(0, -26),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              _statItem(hadir, 'Hadir'),
              _divider(),
              _statItem(sakit, 'Sakit/Izin'),
              _divider(),
              _statItem(total, 'Total'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return VerticalDivider(
      width: 0.5,
      indent: 12,
      endIndent: 12,
      color: Colors.black.withValues(alpha: 0.06),
    );
  }
}

// ─── Standalone Helper Widgets ────────────────────────────────────────────────

Widget _statItem(String value, String label) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: _AppColors.labelText,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSectionLabel(String label) {
  return Text(
    label,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: _AppColors.labelText,
      letterSpacing: 0.8,
    ),
  );
}

Widget _buildInfoCard(
  String name,
  String email,
  String jenisKelamin,
  String training,
  String batch,
) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _AppColors.cardBorder),
    ),
    child: Column(
      children: [
        _infoRow(
          iconBg: const Color(0xFFE6F1FB),
          icon: Icons.person_rounded,
          iconColor: const Color(0xFF185FA5),
          label: 'Nama Lengkap',
          value: name.isEmpty ? '-' : name,
          isLast: false,
        ),
        _infoRow(
          iconBg: const Color(0xFFEAF3DE),
          icon: Icons.email_rounded,
          iconColor: const Color(0xFF3B6D11),
          label: 'Email',
          value: email.isEmpty ? '-' : email,
          isLast: false,
        ),
        _infoRow(
          iconBg: const Color(0xFFFAEEDA),
          icon: Icons.wc_rounded,
          iconColor: const Color(0xFF854F0B),
          label: 'Jenis Kelamin',
          value: jenisKelamin.isEmpty
              ? '-'
              : jenisKelamin.toUpperCase() == 'L'
              ? 'Laki-Laki'
              : jenisKelamin.toUpperCase() == 'P'
              ? 'Perempuan'
              : '-',
          isLast: false,
        ),
        _infoRow(
          iconBg: const Color(0xFFFAEEDA),
          icon: Icons.calendar_today_rounded,
          iconColor: const Color(0xFF854F0B),
          label: 'Batch',
          value: batch.isEmpty ? '-' : batch,
          isLast: false,
        ),
        _infoRow(
          iconBg: _AppColors.primarySurface,
          icon: Icons.school_rounded,
          iconColor: _AppColors.primaryLight,
          label: 'Pelatihan',
          value: training.isEmpty ? '-' : training,
          isLast: true,
        ),
      ],
    ),
  );
}

Widget _infoRow({
  required Color iconBg,
  required IconData icon,
  required Color iconColor,
  required String label,
  required String value,
  required bool isLast,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      border: isLast
          ? null
          : const Border(bottom: BorderSide(color: _AppColors.dividerColor)),
    ),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: _AppColors.labelText,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _AppColors.bodyText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildAccountSecurityGroup(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _AppColors.cardBorder),
    ),
    child: Column(
      children: [
        // Menu Edit Profil
        _menuItem(
          icon: Icons.edit_rounded,
          iconBg: _AppColors.primarySurface,
          iconColor: _AppColors.primaryLight,
          label: 'Edit Profil',
          onTap: () => context.push(const EditProfilPage()),
          showDivider: true,
        ),
        // Menu Ganti Password
        _menuItem(
          icon: Icons.lock_reset_rounded,
          iconBg: const Color(0xFFE6F1FB),
          iconColor: const Color(0xFF185FA5),
          label: 'Ganti Password',
          onTap: () => context.push(const ForgotPasswordPage()),
          showDivider: false,
        ),
      ],
    ),
  );
}

Widget _menuItem({
  required IconData icon,
  required Color iconBg,
  required Color iconColor,
  required String label,
  required VoidCallback onTap,
  required bool showDivider,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(
      16,
    ), // Menjaga efek splash tetap di dalam rounded corner
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _AppColors.bodyText,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: _AppColors.labelText,
              ),
            ],
          ),
        ),
        if (showDivider)
          const Padding(
            padding:
                EdgeInsets.only(), // Divider menjorok agar sejajar dengan teks
            child: Divider(height: 1, color: _AppColors.dividerColor),
          ),
      ],
    ),
  );
}

Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
  return GestureDetector(
    onTap: () async {
      // Make this async
      // 1. Clear the data via the notifier (which should clear SharedPreferences/SecureStorage)
      await ref.read(authProvider.notifier).logout();

      // 2. Invalidate all relevant providers to ensure they return to initial state
      ref.invalidate(authProvider);
      ref.invalidate(attendanceStatsProvider);
      ref.invalidate(attendanceHistoryProvider);
      ref.invalidate(localStorageProvider);
      // 3. Reset the navigation index
      ref.read(bottomNavIndexProvider.notifier).setIndex(0);

      // 4. Navigate away
      if (context.mounted) {
        context.pushAndRemoveAll(const LoginScreen());
      }
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAECE7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF5C4B3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.logout_rounded,
              size: 16,
              color: Color(0xFF993C1D),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Keluar',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF993C1D),
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: Color(0xFFF0997B),
          ),
        ],
      ),
    ),
  );
}
