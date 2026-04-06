import 'package:flutter/material.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          'Halaman Riwayat',
          style: TextStyle(fontSize: 16, color: Color(0xFF1A1A2E)),
        ),
      ),
    );
  }
}
