import 'package:absensi_go/src/core/utils/navigator.dart';
import 'package:absensi_go/src/features/check_in/presentation/check_in.dart';
import 'package:absensi_go/src/features/check_in/provider/get_today_check_in_provider.dart';

import 'package:absensi_go/src/features/check_out/presentation/check_out.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActionButtons extends ConsumerWidget {
  const ActionButtons({super.key});

  // Helper to parse time and check if late/early
  bool _isAfterTime(String? timeStr, int hourLimit, int minuteLimit) {
    if (timeStr == null || timeStr.isEmpty || timeStr == '--:--') return false;
    try {
      // Handles formats like "08:30" or "08:30:00"
      final parts = timeStr.split(':');
      if (parts.length < 2) return false;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (hour > hourLimit) return true;
      if (hour == hourLimit && minute > minuteLimit) return true;
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCheckInState = ref.watch(getTodayCheckInProvider);
    final todayData = asyncCheckInState.value;

    // --- State Check ---
    final checkInTimeStr = todayData?.checkInTime;
    final checkOutTimeStr = todayData?.checkOutTime; // add fallback

    final bool hasCheckedIn =
        checkInTimeStr != null && checkInTimeStr.isNotEmpty;
    final bool hasCheckedOut =
        checkOutTimeStr != null && checkOutTimeStr.isNotEmpty;

    // --- Status Logic ---
    // Late if check in is AFTER 08:00
    final isLate = hasCheckedIn && _isAfterTime(checkInTimeStr, 8, 0);

    // Early if check out is BEFORE 17:00 (i.e., NOT after 16:59)
    final isEarly = hasCheckedOut && !_isAfterTime(checkOutTimeStr, 16, 59);

    String _formatTime(String? timeStr) {
      if (timeStr == null || timeStr.isEmpty) return '--:--';
      final parts = timeStr.split(':');
      if (parts.length < 2) return '--:--';
      return '${parts[0]}:${parts[1]}'; // returns "HH:mm" only
    }

    return Row(
      children: [
        // --- CHECK IN CARD ---
        Expanded(
          child: _attendanceCard(
            context: context,
            icon: Icons.login_rounded,
            label: 'Masuk',
            time: _formatTime(hasCheckedIn ? checkInTimeStr : null),
            iconBg: const Color(0xFFEAF3DE),
            iconColor: const Color(0xFF3B6D11),
            statusLabel: !hasCheckedIn
                ? 'Belum'
                : (isLate ? 'Terlambat' : 'Tepat Waktu'),
            statusBg: !hasCheckedIn
                ? Colors.grey.shade100
                : (isLate ? const Color(0xFFFAECE7) : const Color(0xFFEAF3DE)),
            statusTextColor: !hasCheckedIn
                ? Colors.grey.shade500
                : (isLate ? const Color(0xFF993C1D) : const Color(0xFF3B6D11)),
            timeColor: hasCheckedIn
                ? const Color(0xFF1a1a2e)
                : Colors.grey.shade400,
            onTap: hasCheckedIn
                ? null
                : () async {
                    await context.push(const CheckInScreen());
                    ref.invalidate(getTodayCheckInProvider);
                  },
          ),
        ),
        const SizedBox(width: 10),
        // --- CHECK OUT CARD ---
        Expanded(
          child: _attendanceCard(
            context: context,
            icon: Icons.logout_rounded,
            label: 'Pulang',
            time: _formatTime(hasCheckedOut ? checkOutTimeStr : null),
            iconBg: const Color(0xFFFAEEDA),
            iconColor: const Color(0xFF854F0B),
            statusLabel: !hasCheckedOut
                ? 'Belum'
                : (isEarly ? 'Pulang Awal' : 'Sesuai Jadwal'),
            statusBg: !hasCheckedOut
                ? Colors.grey.shade100
                : (isEarly ? const Color(0xFFFAECE7) : const Color(0xFFEAF3DE)),
            statusTextColor: !hasCheckedOut
                ? Colors.grey.shade500
                : (isEarly ? const Color(0xFF993C1D) : const Color(0xFF3B6D11)),
            timeColor: hasCheckedOut
                ? const Color(0xFF1a1a2e)
                : Colors.grey.shade400,
            onTap: () async {
              await context.push(const CheckOutScreen());
              ref.invalidate(getTodayCheckInProvider);
            },
            // isDisabled: !hasCheckedIn || hasCheckedOut,
          ),
        ),
      ],
    );
  }

  Widget _attendanceCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String time,
    required Color iconBg,
    required Color iconColor,
    required String statusLabel,
    required Color statusBg,
    required Color statusTextColor,
    required Color timeColor,
    required VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.06)),
        boxShadow: [
          if (!isDisabled && onTap != null)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap == null
              ? null
              : () async {
                  await Future.delayed(const Duration(milliseconds: 150));
                  onTap();
                },
          borderRadius: BorderRadius.circular(14),
          splashColor: iconColor.withAlpha(40),
          highlightColor: iconColor.withAlpha(6),
          child: Opacity(
            opacity: isDisabled ? 0.6 : 1.0,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: iconColor, size: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: timeColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
