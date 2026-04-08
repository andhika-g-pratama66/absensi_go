import 'dart:convert';

import 'package:absensi_go/src/core/utils/navigator.dart';
import 'package:absensi_go/src/data/repositories/endpoint.dart';
import 'package:absensi_go/src/features/attendance/provider/stat_provider.dart';
import 'package:absensi_go/src/features/auth/presentation/login_view.dart';
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';
import 'package:absensi_go/src/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilPage extends ConsumerWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Use the new currentUserProvider! It safely returns UserModel?
    final userModel = ref.watch(authProvider);
    final stat = ref.watch(attendanceStatsProvider);
    final user = userModel.whenOrNull(data: (data) => data);

    // ✅ Extraction is now beautifully clean and synchronous
    final name = user?.data?.user?.name ?? '';
    final email = user?.data?.user?.email ?? '';
    final gender = user?.data?.user?.jenisKelamin ?? '';
    final training = user?.data?.user?.training?.title ?? '';
    final batch = user?.data?.user?.batch?.batchKe ?? '';

    // Status check logic
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

    // Initials logic
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

    return SafeArea(
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('INFORMASI PRIBADI'),
                  const SizedBox(height: 10),
                  _buildInfoCard(name, email, gender, training, batch),
                  const SizedBox(height: 16),
                  _buildEditButton(context),
                  const SizedBox(height: 10),
                  _buildLogoutButton(context, ref),
                ],
              ),
            ),
          ],
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
    return Container(
      width: double.infinity,
      color: const Color(0xFF1A1A2E),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profil Saya',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildAvatar(rawProfilePhoto, initials),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'User' : name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white38,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: status == 'Peserta Aktif'
                                  ? const Color(0xFF4ade80) // Hijau jika Aktif
                                  : const Color(
                                      0xFFEF4444,
                                    ), // Merah jika Tidak Aktif
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            status,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white60,
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
      width: 60,
      height: 60,
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
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
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
      offset: const Offset(0, -24),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              _statItem(hadir, 'Hadir'),
              _divider(),
              _statItem(sakit, 'Sakit'),
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

  // (Keep your _statItem, _buildHeader, etc. as they were)
}

Widget _statItem(String value, String label) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSectionLabel(String label) {
  return Text(
    label,
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: Colors.grey.shade500,
      letterSpacing: 0.3,
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
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
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
          icon: Icons.school_rounded,
          iconColor: const Color(0xFF854F0B),
          label: 'Batch',
          value: batch.isEmpty ? '-' : batch,
          isLast: false,
        ),
        _infoRow(
          iconBg: const Color(0xFFEEEDFE),
          icon: Icons.work_rounded,
          iconColor: const Color(0xFF534AB7),
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
          : Border(
              bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
            ),
    ),
    child: Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 15),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A2E),
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

Widget _buildEditButton(BuildContext context) {
  return GestureDetector(
    onTap: () => context.push(const EditProfilPage()),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.edit_rounded,
              size: 15,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Edit Profil',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    ),
  );
}

Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
  return GestureDetector(
    onTap: () {
      ref.read(authProvider.notifier).logout();
      context.pushReplacement(const LoginScreen());
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAECE7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF5C4B3)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.logout_rounded,
              size: 15,
              color: Color(0xFF993C1D),
            ),
          ),
          const SizedBox(width: 12),
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
            size: 18,
            color: Color(0xFFF0997B),
          ),
        ],
      ),
    ),
  );
}
