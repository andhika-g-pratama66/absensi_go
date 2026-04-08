import 'package:absensi_go/src/features/attendance/provider/attendance_provider.dart';
import 'package:absensi_go/src/features/attendance/provider/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HistorySection extends ConsumerWidget {
  const HistorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(attendanceHistoryProvider);

    return attendanceState.when(
      data: (state) {
        if (state.data!.isEmpty) {
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

        // We use a Column to keep the title above the list
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Constrain height
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
            ListView.builder(
              shrinkWrap: true, // Allows ListView to live inside a Column
              physics:
                  const NeverScrollableScrollPhysics(), // Parent scroll handles it
              itemCount: state.data!.length,
              itemBuilder: (context, index) {
                final h = state.data![index];

                // --- Logic Processing ---
                final date = h.attendanceDate ?? DateTime.now();
                final dayLabel = DateFormat('EEE').format(date).toUpperCase();
                final formattedDate = DateFormat('d MMMM yyyy').format(date);

                final checkIn = h.checkInTime ?? h.checkInTime ?? '--:--';
                final checkOut = h.checkOutTime ?? '--:--';
                final isIzin = h.alasanIzin != null && h.alasanIzin!.isNotEmpty;

                bool isLate = false;
                if (!isIzin && checkIn != '--:--') {
                  try {
                    final parts = checkIn.split(':');
                    if (parts.length >= 2) {
                      final hour = int.parse(parts[0]);
                      final minute = int.parse(parts[1]);
                      isLate = hour > 8 || (hour == 8 && minute > 0);
                    }
                  } catch (_) {
                    isLate = false;
                  }
                }

                // Prepare data map for the helper method
                final itemData = {
                  'day': dayLabel,
                  'date': formattedDate,
                  'range': isIzin
                      ? 'Izin: ${h.alasanIzin}'
                      : '$checkIn → $checkOut',
                  'status': isIzin
                      ? 'Sakit/Izin'
                      : (isLate ? 'Terlambat' : 'Hadir'),
                  'isHighlight':
                      isLate || isIzin, // Replaces 'late' to avoid null issues
                };

                return _historyItem(itemData);
              },
            ),
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
    // Fixed: Use null-coalescing ?? false to prevent the "null is not subtype of bool" crash
    final bool isHighlight = item['isHighlight'] as bool? ?? false;

    final dayBg = isHighlight
        ? const Color(0xFFFAECE7)
        : const Color(0xFFEAF3DE);
    final dayColor = isHighlight
        ? const Color(0xFF993C1D)
        : const Color(0xFF3B6D11);

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
                item['day'] as String? ?? '?',
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
                  item['date'] as String? ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['range'] as String? ?? '--:--',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Text(
            item['status'] as String? ?? '',
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
