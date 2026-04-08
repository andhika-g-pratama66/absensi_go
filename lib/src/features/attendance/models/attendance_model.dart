// lib/src/features/attendance/provider/attendance_state.dart

import 'package:absensi_go/src/features/attendance/models/attendance_stats_model.dart';
import 'package:absensi_go/src/features/check_in/models/check_in_model.dart';

class AttendanceState {
  final StatsData? stats;
  final List<CheckInModel> history;

  AttendanceState({this.stats, this.history = const []});

  AttendanceState copyWith({StatsData? stats, List<CheckInModel>? history}) {
    return AttendanceState(
      stats: stats ?? this.stats,
      history: history ?? this.history,
    );
  }
}
