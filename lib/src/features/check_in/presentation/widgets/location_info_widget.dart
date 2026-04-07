import 'package:flutter/material.dart';

class LocationInfo extends StatelessWidget {
  final String? address;

  const LocationInfo({required this.address, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on_rounded,
              size: 16,
              color: Color(0xFF1A1A2E),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                address ?? '-',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1A1A2E),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
