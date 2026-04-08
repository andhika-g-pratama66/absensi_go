import 'dart:async';
import 'dart:convert';

import 'package:absensi_go/src/data/repositories/endpoint.dart';
import 'package:absensi_go/src/features/attendance/models/history_model.dart'; // Import your new model
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

/// Refactored Notifier using HistoryModel as the state
class AttendanceHistoryNotifier extends AsyncNotifier<HistoryModel> {
  @override
  FutureOr<HistoryModel> build() {
    return _fetchHistory();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await ref.read(tokenProvider.future);
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<HistoryModel> _fetchHistory() async {
    final now = DateTime.now();
    // Get start of current week (Monday) and end (Friday)
    final past = DateTime(2026);

    final startDate = DateFormat('yyyy-MM-dd').format(past);
    final endDate = DateFormat('yyyy-MM-dd').format(now);

    final response = await http.get(
      Uri.parse('${Endpoint.history}?start=$startDate&end=$endDate'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      // Use the model's factory directly.
      // Your model already handles the 'data' list mapping.
      return HistoryModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load history: ${response.statusCode}');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchHistory());
  }
}

/// Updated provider definition
final attendanceHistoryProvider =
    AsyncNotifierProvider<AttendanceHistoryNotifier, HistoryModel>(() {
      return AttendanceHistoryNotifier();
    });
