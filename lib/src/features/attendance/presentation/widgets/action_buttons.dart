import 'package:absensi_go/src/core/utils/navigator.dart';
import 'package:absensi_go/src/features/check_in/presentation/check_in.dart';
import 'package:absensi_go/src/features/check_in/provider/check_in_provider.dart';
import 'package:absensi_go/src/features/attendance/presentation/check_out.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActionButtons extends ConsumerWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkInProvider);
    final hasCheckedIn = state.hasCheckedIn;
    final statusLabel = hasCheckedIn ? 'Hadir' : 'Belum';
    final timeValue = state.todayCheckIn?.checkInTime?.trim().isNotEmpty == true
        ? state.todayCheckIn!.checkInTime!.trim()
        : state.todayCheckIn?.checkIn?.trim().isNotEmpty == true
        ? state.todayCheckIn!.checkIn!.trim()
        : null;
    final time = hasCheckedIn ? timeValue ?? '--:--' : '--:--';
    final statusBg = hasCheckedIn
        ? const Color(0xFFEAF3DE)
        : Colors.grey.shade100;
    final statusTextColor = hasCheckedIn
        ? const Color(0xFF3B6D11)
        : Colors.grey.shade500;
    final timeColor = hasCheckedIn
        ? const Color(0xFF1a1a2e)
        : Colors.grey.shade400;

    return Row(
      children: [
        Expanded(
          child: _attendanceCard(
            context: context,
            icon: Icons.login_rounded,
            label: 'Masuk',
            time: time,
            iconBg: const Color(0xFFEAF3DE),
            iconColor: const Color(0xFF3B6D11),
            statusLabel: statusLabel,
            statusBg: statusBg,
            statusTextColor: statusTextColor,
            timeColor: timeColor,
            onTap: () => context.push(const CheckInScreen()),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _attendanceCard(
            context: context,
            icon: Icons.logout_rounded,
            label: 'Pulang',
            time: '--:--',
            iconBg: const Color(0xFFFAEEDA),
            iconColor: const Color(0xFF854F0B),
            statusLabel: 'Belum',
            statusBg: Colors.grey.shade100,
            statusTextColor: Colors.grey.shade500,
            timeColor: Colors.grey.shade400,
            onTap: () => context.push(const CheckOutScreen()),
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
    Color? statusBg,
    Color? statusTextColor,
    Color? timeColor,
    required VoidCallback onTap,
  }) {
    final sBg = statusBg ?? const Color(0xFFEAF3DE);
    final sTxt = statusTextColor ?? const Color(0xFF3B6D11);
    final tColor = timeColor ?? const Color(0xFF1a1a2e);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.06)),
        ),
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
                    color: sBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: sTxt,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 2),
            Text(
              time,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: tColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
