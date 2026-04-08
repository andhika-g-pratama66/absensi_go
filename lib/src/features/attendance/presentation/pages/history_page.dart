import 'package:absensi_go/src/features/attendance/provider/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class RiwayatPage extends ConsumerWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(attendanceHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Riwayat Absensi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: attendanceState.when(
        data: (state) {
          if (state.data!.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada data riwayat absensi',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(attendanceHistoryProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.data!.length,
              itemBuilder: (context, index) {
                final item = state.data![index];
                final date = item.attendanceDate ?? DateTime.now();
                final checkIn = item.checkInTime ?? item.checkInTime ?? '--:--';
                final checkOut = item.checkOutTime ?? '--:--';
                final status = item.status?.toUpperCase() ?? 'HADIR';

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

                final statusColor = isLate || item.alasanIzin != null
                    ? const Color(0xFF993C1D)
                    : const Color(0xFF3B6D11);
                final statusBg = isLate || item.alasanIzin != null
                    ? const Color(0xFFFAECE7)
                    : const Color(0xFFEAF3DE);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat(
                              'EEEE, d MMMM yyyy',
                              'id_ID',
                            ).format(date),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isLate ? 'TERLAMBAT' : status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildTimeInfo(
                            'Check-in',
                            checkIn,
                            Icons.login_rounded,
                            const Color(0xFF3B6D11),
                          ),
                          const SizedBox(width: 24),
                          _buildTimeInfo(
                            'Check-out',
                            checkOut,
                            Icons.logout_rounded,
                            const Color(0xFF854F0B),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time, IconData icon, Color color) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
