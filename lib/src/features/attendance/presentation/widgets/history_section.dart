import 'package:flutter/material.dart';

class HistorySection extends StatelessWidget {
  const HistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'day': 'SEN',
        'date': '6 April 2026',
        'range': '07:55 → 17:05',
        'status': 'Hadir',
        'late': false,
      },
      {
        'day': 'JUM',
        'date': '4 April 2026',
        'range': '08:12 → 17:00',
        'status': 'Terlambat',
        'late': true,
      },
      {
        'day': 'KAM',
        'date': '3 April 2026',
        'range': '07:50 → 17:10',
        'status': 'Hadir',
        'late': false,
      },
    ];

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
        border: Border.all(color: Colors.black.withOpacity(0.06)),
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
