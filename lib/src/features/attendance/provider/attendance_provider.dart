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
    final token = await ref.read(tokenProvider.future);
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<AttendanceState> _fetchData() async {
    final now = DateTime.now();
    // Calculate Monday of this week correctly
    // If today is Sunday (7), weekday is 7. Monday is now - (7-1) = now - 6.
    // If today is Monday (1), weekday is 1. Monday is now - (1-1) = now.
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final friday = monday.add(const Duration(days: 4));

    final startDate = DateFormat('yyyy-MM-dd').format(monday);
    final endDate = DateFormat('yyyy-MM-dd').format(friday);

    try {
      final headers = await _getHeaders();

      // 1. Fetch Stats from absenStat endpoint
      final statsResponse = await http.get(
        Uri.parse('${Endpoint.absenStat}?start=$startDate&end=$endDate'),
        headers: headers,
      );

      log('[AttendanceNotifier] Stats Status: ${statsResponse.statusCode}');
      log('[AttendanceNotifier] Stats Body: ${statsResponse.body}');

      StatsData? stats;
      if (statsResponse.statusCode == 200) {
        final decoded = json.decode(statsResponse.body);
        if (decoded['data'] != null) {
          stats = StatsData.fromJson(decoded['data']);
        }
      }

      // 2. Fetch History from absenToday endpoint (using range params as requested)
      final historyResponse = await http.get(
        Uri.parse('${Endpoint.absenToday}?start=$startDate&end=$endDate'),
        headers: headers,
      );

      log('[AttendanceNotifier] History Status: ${historyResponse.statusCode}');
      log('[AttendanceNotifier] History Body: ${historyResponse.body}');

      List<CheckInModel> history = [];
      if (historyResponse.statusCode == 200) {
        final decoded = json.decode(historyResponse.body);
        final dynamic data = decoded['data'];

        if (data is List) {
          log('[AttendanceNotifier] History data is List. Parsing...');
          history = data.map((item) => CheckInModel.fromJson(item)).toList();
        } else if (data is Map<String, dynamic>) {
          log('[AttendanceNotifier] History data is Map. Checking for list or single record...');
          if (data['history'] is List) {
            history = (data['history'] as List)
                .map((item) => CheckInModel.fromJson(item))
                .toList();
          } else if (data['details'] is List) {
            history = (data['details'] as List)
                .map((item) => CheckInModel.fromJson(item))
                .toList();
          } else if (data.containsKey('attendance_date')) {
            history = [CheckInModel.fromJson(data)];
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
