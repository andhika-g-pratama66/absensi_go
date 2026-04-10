import 'package:absensi_go/src/core/utils/navigator.dart';
import 'package:absensi_go/src/features/check_in/presentation/check_in.dart';
import 'package:absensi_go/src/features/check_in/provider/get_today_check_in_provider.dart';
import 'package:absensi_go/src/features/check_out/presentation/check_out.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActionButtons extends ConsumerWidget {
  const ActionButtons({super.key});

  bool _isAfterTime(String? timeStr, int hourLimit, int minuteLimit) {
    if (timeStr == null || timeStr.isEmpty || timeStr == '--:--') return false;
    try {
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

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '--:--';
    final parts = timeStr.split(':');
    if (parts.length < 2) return '--:--';
    return '${parts[0]}:${parts[1]}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCheckInState = ref.watch(getTodayCheckInProvider);
    final todayData = asyncCheckInState.value;

    final checkInTimeStr = todayData?.checkInTime;
    final checkOutTimeStr = todayData?.checkOutTime;

    final bool hasCheckedIn =
        checkInTimeStr != null && checkInTimeStr.isNotEmpty;
    final bool hasCheckedOut =
        checkOutTimeStr != null && checkOutTimeStr.isNotEmpty;

    final isLate = hasCheckedIn && _isAfterTime(checkInTimeStr, 8, 0);
    final isEarly = hasCheckedOut && !_isAfterTime(checkOutTimeStr, 16, 59);

    return FadeInUp(
      duration: const Duration(microseconds: 200),
      child: Row(
        children: [
          Expanded(
            child: _AttendanceCard(
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
                  : (isLate
                        ? const Color(0xFFFAECE7)
                        : const Color(0xFFEAF3DE)),
              statusTextColor: !hasCheckedIn
                  ? Colors.grey.shade500
                  : (isLate
                        ? const Color(0xFF993C1D)
                        : const Color(0xFF3B6D11)),
              timeColor: hasCheckedIn
                  ? const Color(0xFF1a1a2e)
                  : Colors.grey.shade400,
              tapHint: hasCheckedIn ? null : 'Tap untuk absen masuk',
              onTap: () async {
                await context.push(const CheckInScreen());
                ref.invalidate(getTodayCheckInProvider);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _AttendanceCard(
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
                  : (isEarly
                        ? const Color(0xFFFAECE7)
                        : const Color(0xFFEAF3DE)),
              statusTextColor: !hasCheckedOut
                  ? Colors.grey.shade500
                  : (isEarly
                        ? const Color(0xFF993C1D)
                        : const Color(0xFF3B6D11)),
              timeColor: hasCheckedOut
                  ? const Color(0xFF1a1a2e)
                  : Colors.grey.shade400,
              tapHint: hasCheckedOut ? null : 'Tap untuk absen pulang',
              onTap: () async {
                await context.push(const CheckOutScreen());
                ref.invalidate(getTodayCheckInProvider);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceCard extends StatefulWidget {
  const _AttendanceCard({
    required this.icon,
    required this.label,
    required this.time,
    required this.iconBg,
    required this.iconColor,
    required this.statusLabel,
    required this.statusBg,
    required this.statusTextColor,
    required this.timeColor,
    required this.onTap,
    this.tapHint,
    this.isDisabled = false,
  });

  final IconData icon;
  final String label;
  final String time;
  final Color iconBg;
  final Color iconColor;
  final String statusLabel;
  final Color statusBg;
  final Color statusTextColor;
  final Color timeColor;
  final VoidCallback? onTap;
  final String? tapHint;
  final bool isDisabled;

  @override
  State<_AttendanceCard> createState() => _AttendanceCardState();
}

class _AttendanceCardState extends State<_AttendanceCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isClickable = widget.onTap != null && !widget.isDisabled;

    return GestureDetector(
      onTapDown: isClickable ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isClickable ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isClickable
          ? () => setState(() => _isPressed = false)
          : null,
      onTap: isClickable
          ? () async {
              await Future.delayed(const Duration(milliseconds: 150));
              widget.onTap!();
            }
          : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isPressed
                  ? widget.iconColor.withOpacity(0.35)
                  : isClickable
                  ? const Color.fromRGBO(0, 0, 0, 0.10)
                  : const Color.fromRGBO(0, 0, 0, 0.06),
              width: _isPressed ? 1.5 : 1.0,
            ),
            boxShadow: isClickable && !_isPressed
                ? [
                    BoxShadow(
                      color: widget.iconColor.withOpacity(0.10),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Opacity(
            opacity: widget.isDisabled ? 0.6 : 1.0,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: icon + status badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _isPressed ? widget.iconBg : widget.iconBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.iconColor,
                          size: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: widget.statusBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: widget.statusTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Label
                  Text(
                    widget.label,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),

                  // Time
                  Text(
                    widget.time,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: widget.timeColor,
                    ),
                  ),

                  // Tap hint — only shown when actionable
                  if (widget.tapHint != null) ...[
                    const SizedBox(height: 8),
                    AnimatedOpacity(
                      opacity: _isPressed ? 0.4 : 0.55,
                      duration: const Duration(milliseconds: 100),
                      child: Row(
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 11,
                            color: widget.iconColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            widget.tapHint!,
                            style: TextStyle(
                              fontSize: 10,
                              color: widget.iconColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
