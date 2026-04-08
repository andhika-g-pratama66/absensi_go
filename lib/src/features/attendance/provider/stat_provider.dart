import 'dart:async';
import 'dart:convert';
import 'package:absensi_go/src/data/repositories/endpoint.dart';
import 'package:absensi_go/src/features/attendance/models/attendance_stats_model.dart';
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;
// Note: If using riverpod_generator, use @riverpod.
// Otherwise, follow the manual AsyncNotifier syntax below:

class AttendanceStatsNotifier extends AsyncNotifier<StatsData?> {
  @override
  FutureOr<StatsData?> build() {
    return _fetchStats();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await ref.read(tokenProvider.future);
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<StatsData?> _fetchStats() async {
    final now = DateTime.now();
    final past = DateTime(
      2020,
      1,
      1,
    ); // Tanggal jauh di masa depan untuk memastikan semua data diambil

    final startDate = DateFormat('yyyy-MM-dd').format(past);
    final endDate = DateFormat('yyyy-MM-dd').format(now);

    final response = await http.get(
      Uri.parse('${Endpoint.absenStat}?start=$startDate&end=$endDate'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return StatsData.fromJson(decoded['data']);
    }
    throw Exception('Failed to load stats: ${response.statusCode}');
  }

  // Allow manual refresh
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchStats());
  }
}

final attendanceStatsProvider =
    AsyncNotifierProvider<AttendanceStatsNotifier, StatsData?>(() {
      return AttendanceStatsNotifier();
    });
