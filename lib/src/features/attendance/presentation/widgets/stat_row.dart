import 'package:absensi_go/src/features/attendance/provider/stat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatRow extends ConsumerWidget {
  const StatRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(attendanceStatsProvider);

    return attendanceState.when(
      data: (state) {
        final stats = [
          {'label': 'Hadir', 'value': (state?.totalMasuk ?? 0).toString()},
          {'label': 'Izin', 'value': (state?.totalIzin ?? 0).toString()},
          {'label': 'Total', 'value': (state?.totalAbsen ?? 0).toString()},
        ];

        return Row(
          children: stats.map((s) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: s != stats.last ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      s['value']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s['label']!,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
