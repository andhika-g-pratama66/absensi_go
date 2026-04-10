import 'dart:convert';
import 'dart:developer';
import 'package:absensi_go/src/data/repositories/endpoint.dart';
import 'package:absensi_go/src/features/attendance/models/attendance_stats_model.dart';
import 'package:absensi_go/src/features/check_in/models/check_in_model.dart';
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AttendanceState {
  final StatsData? stats;
  final List<CheckInModel> history;
  final bool isLoading;
  final String? errorMessage;

  AttendanceState({
    this.stats,
    this.history = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AttendanceState copyWith({
    StatsData? stats,
    List<CheckInModel>? history,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AttendanceState(
      stats: stats ?? this.stats,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AttendanceNotifier extends AsyncNotifier<AttendanceState> {
  @override
  Future<AttendanceState> build() async {
    // Initial fetch for the current week
    return _fetchData();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await ref.watch(tokenProvider.future);
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<AttendanceState> _fetchData() async {
    final now = DateTime.now();
    // Ensure we start from midnight to avoid timestamp drift
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final friday = monday.add(const Duration(days: 4));

    final startDate = DateFormat('yyyy-MM-dd').format(monday);
    final endDate = DateFormat('yyyy-MM-dd').format(friday);

    try {
      final headers = await _getHeaders();
      final statsUri = Uri.parse(
        '${Endpoint.absenStat}?start=$startDate&end=$endDate',
      );
      final historyUri = Uri.parse(
        '${Endpoint.absenToday}?start=$startDate&end=$endDate',
      );

      // Run both requests in parallel
      final results = await Future.wait([
        http.get(statsUri, headers: headers),
        http.get(historyUri, headers: headers),
      ]);

      final statsResponse = results[0];
      final historyResponse = results[1];

      // --- 1. Parse Stats ---
      StatsData? stats;
      if (statsResponse.statusCode == 200) {
        final decoded = json.decode(statsResponse.body);
        if (decoded['data'] != null) {
          stats = StatsData.fromJson(decoded['data']);
        }
      }

      // --- 2. Parse History ---
      List<CheckInModel> history = [];
      if (historyResponse.statusCode == 200) {
        final decoded = json.decode(historyResponse.body);
        final dynamic data = decoded['data'];

        if (data is List) {
          history = data.map((item) => CheckInModel.fromJson(item)).toList();
        } else if (data is Map<String, dynamic>) {
          // Flattening the map structure based on common API patterns
          final list =
              data['history'] ??
              data['details'] ??
              (data.containsKey('attendance_date') ? [data] : []);
          if (list is List) {
            history = list.map((item) => CheckInModel.fromJson(item)).toList();
          }
        }
      }

      return AttendanceState(stats: stats, history: history, isLoading: false);
    } catch (e) {
      log('[AttendanceNotifier] Error: $e');
      return AttendanceState(
        errorMessage: 'Gagal memuat data absensi: $e',
        isLoading: false,
      );
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchData());
  }
}

final attendanceProvider =
    AsyncNotifierProvider<AttendanceNotifier, AttendanceState>(() {
      return AttendanceNotifier();
    });
