import 'package:absensi_go/src/core/utils/navigator.dart';
import 'package:absensi_go/src/features/check_in/presentation/check_in.dart';
import 'package:absensi_go/src/features/check_in/provider/check_in_provider.dart';
import 'package:absensi_go/src/features/check_out/presentation/check_out.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActionButtons extends ConsumerWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check In State (Now contains both check-in and check-out data from new API)
    final asyncCheckInState = ref.watch(checkInProvider);
    final checkInState = asyncCheckInState.value;
    final todayData = checkInState?.todayCheckIn;
    
    final hasCheckedIn = todayData?.checkInTime != null || todayData?.checkIn != null;
    final hasCheckedOut = todayData?.checkOutTime != null;

    // --- Check In UI Logic ---
    final checkInTimeValue = todayData?.checkInTime ?? todayData?.checkIn;
    final checkInTime = hasCheckedIn ? checkInTimeValue ?? '--:--' : '--:--';

    // Determine if late (after 08:00)
    bool isLate = false;
    if (hasCheckedIn && checkInTimeValue != null) {
      try {
        final parts = checkInTimeValue.split(':');
        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          isLate = hour > 8 || (hour == 8 && minute > 0);
        }
      } catch (e) {
        isLate = false;
      }
    }

    final checkInStatusLabel = !hasCheckedIn
        ? 'Belum'
        : (isLate ? 'Terlambat' : 'Tepat Waktu');
    final checkInStatusBg = !hasCheckedIn
        ? Colors.grey.shade100
        : (isLate ? const Color(0xFFFAECE7) : const Color(0xFFEAF3DE));
    final checkInStatusTextColor = !hasCheckedIn
        ? Colors.grey.shade500
        : (isLate ? const Color(0xFF993C1D) : const Color(0xFF3B6D11));
    final checkInTimeColor = hasCheckedIn
        ? const Color(0xFF1a1a2e)
        : Colors.grey.shade400;

    // --- Check Out UI Logic ---
    final checkOutTimeValue = todayData?.checkOutTime;
    final checkOutTime = hasCheckedOut ? checkOutTimeValue ?? '--:--' : '--:--';

    // Determine if early (before 17:00)
    bool isEarly = false;
    if (hasCheckedOut && checkOutTimeValue != null) {
      try {
        final parts = checkOutTimeValue.split(':');
        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          isEarly = hour < 17;
        }
      } catch (e) {
        isEarly = false;
      }
    }

    final checkOutStatusLabel = !hasCheckedOut
        ? 'Belum'
        : (isEarly ? 'Pulang Awal' : 'Sesuai Jadwal');
    final checkOutStatusBg = !hasCheckedOut
        ? Colors.grey.shade100
        : (isEarly ? const Color(0xFFFAECE7) : const Color(0xFFEAF3DE));
    final checkOutStatusTextColor = !hasCheckedOut
        ? Colors.grey.shade500
        : (isEarly ? const Color(0xFF993C1D) : const Color(0xFF3B6D11));
    final checkOutTimeColor = hasCheckedOut
        ? const Color(0xFF1a1a2e)
        : Colors.grey.shade400;

    return Row(
      children: [
        Expanded(
          child: _attendanceCard(
            context: context,
            icon: Icons.login_rounded,
            label: 'Masuk',
            time: checkInTime,
            iconBg: const Color(0xFFEAF3DE),
            iconColor: const Color(0xFF3B6D11),
            statusLabel: checkInStatusLabel,
            statusBg: checkInStatusBg,
            statusTextColor: checkInStatusTextColor,
            timeColor: checkInTimeColor,
            onTap: hasCheckedIn
                ? null
                : () => context.push(const CheckInScreen()),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _attendanceCard(
            context: context,
            icon: Icons.logout_rounded,
            label: 'Pulang',
            time: checkOutTime,
            iconBg: const Color(0xFFFAEEDA),
            iconColor: const Color(0xFF854F0B),
            statusLabel: checkOutStatusLabel,
            statusBg: checkOutStatusBg,
            statusTextColor: checkOutStatusTextColor,
            timeColor: checkOutTimeColor,
            onTap: hasCheckedOut || !hasCheckedIn
                ? null
                : () => context.push(const CheckOutScreen()),
            isDisabled: !hasCheckedIn,
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
    required VoidCallback? onTap,
    bool isDisabled = false,
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
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
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
      ),
    );
  }
}
