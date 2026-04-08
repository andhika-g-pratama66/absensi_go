import 'package:absensi_go/src/data/repositories/check_in_repository.dart';
import 'package:absensi_go/src/features/check_in/models/check_in_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GetTodayCheckInProvider extends AsyncNotifier<CheckInModel> {
  CheckInRepository get _repository => ref.read(checkInRepositoryProvider);

  @override
  Future<CheckInModel> build() async {
    // This runs when the provider is first accessed

    // Return initial state with fetched data
    return CheckInModel();
  }

  bool _isLoading = false;
  String _errorMessage = '';

  // Getters

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Simulate API Call
  Future<void> fetchTodayCheckIn() async {
    _isLoading = true;
    _errorMessage = '';
    try {
      final todayCheckIn = await _repository.getTodayCheckIn();
      state = AsyncValue.data(
        CheckInModel(
          checkIn: todayCheckIn?.checkIn,
          checkInTime: todayCheckIn?.checkInTime,
          checkInLat: todayCheckIn?.checkInLat,
          checkInLng: todayCheckIn?.checkInLng,
          checkInAddress: todayCheckIn?.checkInAddress,
          alasanIzin: todayCheckIn?.alasanIzin,
          checkInLocation: todayCheckIn?.checkInLocation,
          checkOutTime: todayCheckIn?.checkOutTime,
          checkOutAddress: todayCheckIn?.checkOutAddress,
        ),
      );
    } catch (e) {
      _errorMessage = 'Failed to fetch today\'s check-in: $e';
      state = AsyncValue.error(_errorMessage, StackTrace.current);
    } finally {
      _isLoading = false;
      // Notify listeners about the state change
      state = AsyncValue.loading();
    }
  }
}

final getTodayCheckInProvider =
    AsyncNotifierProvider<GetTodayCheckInProvider, CheckInModel>(() {
      return GetTodayCheckInProvider();
    });
