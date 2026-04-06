import 'package:absensi_go/src/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HomeHeader extends StatelessWidget {
  final AsyncValue authState;
  const HomeHeader({super.key, required this.authState});

  @override
  Widget build(BuildContext context) {
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
                      const Text(
                        'Selamat pagi',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white38,
                          letterSpacing: 0.5,
                        ),
                      ),
                      authState.when(
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
                        error: (_, __) => const Text(
                          'Error',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Icon(
                  Icons.notifications_rounded,
                  color: Colors.white60,
                  size: 18,
                ),
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
    String initials = 'U';
    authState.whenData((user) {
      final name = user?.data?.user?.name ?? '';
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (name.isNotEmpty) {
        initials = name[0].toUpperCase();
      }
    });
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white12,
        border: Border.all(color: Colors.white24),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat(
              'EEEE, d MMMM yyyy',
            ).format(DateTime.now()).toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white38,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, _) => Text(
              DateFormat('HH:mm:ss').format(DateTime.now()),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Dalam jam kerja',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
