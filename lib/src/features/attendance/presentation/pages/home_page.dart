import 'package:absensi_go/src/features/attendance/presentation/widgets/action_buttons.dart';
import 'package:absensi_go/src/features/attendance/presentation/widgets/history_section.dart';
import 'package:absensi_go/src/features/attendance/presentation/widgets/home_header.dart';
import 'package:absensi_go/src/features/attendance/presentation/widgets/stat_row.dart';
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            HomeHeader(authState: authState),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ActionButtons(),
                  SizedBox(height: 12),
                  StatRow(),
                  SizedBox(height: 24),
                  HistorySection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
