import 'package:flutter/material.dart';

class LocationEmpty extends StatelessWidget {
  const LocationEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.location_searching_rounded, size: 16, color: Colors.grey),
        SizedBox(width: 8),
        Text(
          'Lokasi belum tersedia',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }
}
