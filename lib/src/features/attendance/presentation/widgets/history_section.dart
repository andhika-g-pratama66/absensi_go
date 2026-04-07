import 'package:absensi_go/src/features/attendance/provider/attendance_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HistorySection extends ConsumerWidget {
  const HistorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(attendanceProvider);

    return attendanceState.when(
      data: (state) {
        if (state.history.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Belum ada riwayat minggu ini',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          );
        }

        final items = state.history.map((h) {
          final date = h.attendanceDate ?? DateTime.now();
          final dayLabel = DateFormat('EEE').format(date).toUpperCase();
          final formattedDate = DateFormat('d MMMM yyyy').format(date);
          final checkIn = h.checkInTime ?? h.checkIn ?? '--:--';
          final checkOut = h.checkOutTime ?? '--:--';

          // Determine if late (after 08:00)
          bool isLate = false;
          try {
            final parts = checkIn.split(':');
            if (parts.length >= 2) {
              final hour = int.parse(parts[0]);
              final minute = int.parse(parts[1]);
              isLate = hour > 8 || (hour == 8 && minute > 0);
            }
          } catch (_) {}

          String status = isLate ? 'Terlambat' : 'Hadir';
          if (h.alasanIzin != null) {
            status = 'Sakit/Izin';
          }

          return {
            'day': dayLabel,
            'date': formattedDate,
            'range': '$checkIn → $checkOut',
            'status': status,
            'late': isLate || h.alasanIzin != null,
          };
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riwayat minggu ini',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => _historyItem(item)),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text('Error: $error', style: const TextStyle(fontSize: 11)),
        ),
      ),
    );
  }

  Widget _historyItem(Map<String, dynamic> item) {
    final isLate = item['late'] as bool;
    final dayBg = isLate ? const Color(0xFFFAECE7) : const Color(0xFFEAF3DE);
    final dayColor = isLate ? const Color(0xFF993C1D) : const Color(0xFF3B6D11);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: dayBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                item['day'] as String,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: dayColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['date'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['range'] as String,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Text(
            item['status'] as String,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: dayColor,
            ),
          ),
        ],
      ),
    );
  }
}
