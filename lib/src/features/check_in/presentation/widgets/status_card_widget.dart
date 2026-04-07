import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final jamMasuk = DateTime(now.year, now.month, now.day, 8, 0);
    final isLate = now.isAfter(jamMasuk);
    final statusLabel = isLate ? 'Terlambat' : 'Tepat Waktu';
    final statusColor = isLate
        ? const Color(0xFF993C1D)
        : const Color(0xFF3B6D11);
    final statusBg = isLate ? const Color(0xFFFAECE7) : const Color(0xFFEAF3DE);
    final statusIcon = isLate
        ? Icons.warning_rounded
        : Icons.check_circle_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Status Kehadiran',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            'Jam masuk 08:00',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
