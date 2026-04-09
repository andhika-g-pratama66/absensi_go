import 'dart:convert';

import 'package:absensi_go/src/core/constants/app_colors.dart';
import 'package:absensi_go/src/data/repositories/endpoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HomeHeader extends StatefulWidget {
  final AsyncValue authState;
  const HomeHeader({super.key, required this.authState});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  final String greeting = () {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat pagi';
    } else if (hour < 15) {
      return 'Selamat siang';
    } else if (hour < 18) {
      return 'Selamat sore';
    } else {
      return 'Selamat malam';
    }
  }();
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Cek apakah jam sekarang di antara pukul 08:00 dan 16:00
    bool isOfficeHours = now.hour >= 8 && now.hour < 16;
    return Container(
      width: double.infinity,
      color: AppColors.darkBg,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white38,
                          letterSpacing: 0.5,
                        ),
                      ),
                      widget.authState.when(
                        data: (user) => Text(
                          user?.data?.user?.name ?? 'User',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        loading: () => const Text(
                          'Memuat...',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                        error: (error, stackTrace) => const Text(
                          'Error',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTimeCard(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return widget.authState.when(
      data: (user) {
        final name = user?.data?.user?.name ?? '';
        final rawProfilePhoto = user?.data?.user?.profilePhoto;

        // Calculate initials
        String initials = 'U';
        final cleanName = name.trim();
        if (cleanName.isNotEmpty) {
          final parts = cleanName.split(RegExp(r'\s+'));
          if (parts.length >= 2) {
            initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
          } else {
            initials = cleanName[0].toUpperCase();
          }
        }

        // Handle profile photo display
        DecorationImage? decorationImage;
        if (rawProfilePhoto != null && rawProfilePhoto.isNotEmpty) {
          if (rawProfilePhoto.contains('/') && !rawProfilePhoto.contains(',')) {
            final fullUrl = Endpoint.publicImages + rawProfilePhoto;
            decorationImage = DecorationImage(
              image: NetworkImage(fullUrl),
              fit: BoxFit.cover,
            );
          } else {
            // It's base64 data - decode it
            try {
              // Strip the "data:image/png;base64," prefix if present
              final cleanBase64 = rawProfilePhoto.contains(',')
                  ? rawProfilePhoto.split(',').last
                  : rawProfilePhoto;

              final imageBytes = base64Decode(cleanBase64);
              decorationImage = DecorationImage(
                image: MemoryImage(imageBytes),
                fit: BoxFit.cover,
              );
            } catch (e) {
              // If decoding fails, we'll show initials (no decorationImage)
              debugPrint('Error decoding base64 image: $e');
            }
          }
        }

        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white12,
            border: Border.all(color: Colors.white24),
            image: decorationImage,
          ),
          // Fall back to initials if there is no image or decoding failed
          child: decorationImage == null
              ? Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : null,
        );
      },
      loading: () => Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white10,
        ),
        child: const Center(
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white38,
            ),
          ),
        ),
      ),
      error: (err, stack) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white12,
          border: Border.all(color: Colors.white24),
        ),
        child: const Center(
          child: Icon(Icons.person, color: Colors.white54, size: 20),
        ),
      ),
    );
  }

  Widget _buildTimeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat(
                  'EEEE, d MMMM yyyy',
                  'id_ID',
                ) // Menggunakan locale Indonesia
                .format(DateTime.now())
                .toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white38,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          const _LiveClock(), // Jam yang berdetik tiap detik
          const SizedBox(height: 8),
          const _StatusJamKerja(), // Indikator status yang ikut berdetik
        ],
      ),
    );
  }
}

// Widget baru agar status "Dalam jam kerja" terupdate tiap detik
class _StatusJamKerja extends StatelessWidget {
  const _StatusJamKerja();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      // Kita gunakan stream yang sama dengan clock agar sinkron
      stream: Stream.periodic(
        const Duration(seconds: 1),
        (_) => DateTime.now(),
      ),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        // Logika: Jam 08:00 sampai 15:59:59 dihitung dalam jam kerja
        final bool isOfficeHours = now.hour >= 8 && now.hour < 16;

        return Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOfficeHours ? AppColors.accent : Colors.grey,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isOfficeHours ? 'Dalam jam kerja' : 'Luar jam kerja',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        );
      },
    );
  }
}

/// A highly optimized widget that manages its own stream.
/// It prevents the entire HomeHeader from rebuilding every second.
class _LiveClock extends StatefulWidget {
  const _LiveClock();

  @override
  State<_LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<_LiveClock> {
  late final Stream<DateTime> _clockStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream exactly once
    _clockStream = Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: _clockStream,
      builder: (context, snapshot) {
        final time = snapshot.data ?? DateTime.now();
        return Text(
          DateFormat('HH:mm:ss').format(time),
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            letterSpacing: -1,
          ),
        );
      },
    );
  }
}
