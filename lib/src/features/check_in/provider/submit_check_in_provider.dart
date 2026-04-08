import 'package:absensi_go/src/features/check_in/models/check_in_model.dart';
import 'package:absensi_go/src/data/repositories/check_in_repository.dart';
import 'package:absensi_go/src/features/check_out/provider/check_out_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

// ── CheckInState Class ──────────────────────────────────
class CheckInState {
  final double? latitude;
  final double? longitude;
  final String? address;
  final bool isLoadingLocation;
  final bool isSubmitting;
  final String? errorMessage;
  final CheckInModel? todayCheckIn;

  const CheckInState({
    this.latitude,
    this.longitude,
    this.address,
    this.isLoadingLocation = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.todayCheckIn,
  });

  bool get hasLocation => latitude != null && longitude != null;
  bool get hasCheckedIn => todayCheckIn != null;

  CheckInState copyWith({
    double? latitude,
    double? longitude,
    String? address,
    bool? isLoadingLocation,
    bool? isSubmitting,
    String? errorMessage,
    CheckInModel? todayCheckIn,
  }) {
    return CheckInState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage, // null clears it
      todayCheckIn: todayCheckIn ?? this.todayCheckIn,
    );
  }
}

// ── Notifier ────────────────────────────────────────────

class SubmitCheckInNotifier extends AsyncNotifier<CheckInState> {
  CheckInRepository get _repository => ref.read(checkInRepositoryProvider);

  @override
  Future<CheckInState> build() async {
    // This runs when the provider is first accessed

    // Return initial state with fetched data
    return CheckInState();
  }

  Future<void> getLocation() async {
    // FIX: Replaced valueOrNull with value
    final currentState = state.value ?? const CheckInState();
    state = AsyncData(
      currentState.copyWith(isLoadingLocation: true, errorMessage: null),
    );

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = AsyncData(
          state.value!.copyWith(
            isLoadingLocation: false,
            errorMessage:
                'Layanan lokasi tidak aktif. Aktifkan GPS terlebih dahulu.',
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = AsyncData(
            state.value!.copyWith(
              isLoadingLocation: false,
              errorMessage: 'Izin lokasi ditolak.',
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = AsyncData(
          state.value!.copyWith(
            isLoadingLocation: false,
            errorMessage:
                'Izin lokasi ditolak permanen. Buka pengaturan untuk mengaktifkan.',
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = 'Alamat tidak ditemukan';
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address = [
          place.street,
          place.subLocality,
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
      }

      state = AsyncData(
        state.value!.copyWith(
          isLoadingLocation: false,
          latitude: position.latitude,
          longitude: position.longitude,
          address: address,
        ),
      );
    } catch (e) {
      state = AsyncData(
        state.value!.copyWith(
          isLoadingLocation: false,
          errorMessage: 'Gagal mendapatkan lokasi: $e',
        ),
      );
    }
  }

  Future<bool> submitCheckIn() async {
    // FIX: Replaced valueOrNull with value
    final currentState = state.value;
    if (currentState == null || !currentState.hasLocation) return false;

    state = AsyncData(
      currentState.copyWith(isSubmitting: true, errorMessage: null),
    );

    try {
      final now = DateTime.now();
      final String formattedTime = DateFormat('HH:mm').format(now);

      final model = CheckInModel(
        attendanceDate: now,
        checkIn: formattedTime,
        checkInTime: formattedTime,
        checkInLat: currentState.latitude,
        checkInLng: currentState.longitude,
        checkInLocation: '${currentState.latitude},${currentState.longitude}',
        checkInAddress: currentState.address,
        status: 'masuk',
      );

      final savedCheckIn = await _repository.submitCheckIn(model);

      state = AsyncData(
        state.value!.copyWith(isSubmitting: false, todayCheckIn: savedCheckIn),
      );

      // Invalidate checkOutProvider to ensure it knows check-in happened
      ref.invalidate(checkOutProvider);

      return true;
    } on CheckInException catch (e) {
      state = AsyncData(
        state.value!.copyWith(isSubmitting: false, errorMessage: e.message),
      );
      return false;
    } catch (e) {
      state = AsyncData(
        state.value!.copyWith(
          isSubmitting: false,
          errorMessage: 'Gagal check in: $e',
        ),
      );
      return false;
    }
  }
}

// ── Provider ──────────────────────────────────────────

final submitCheckInProvider =
    AsyncNotifierProvider<SubmitCheckInNotifier, CheckInState>(() {
      return SubmitCheckInNotifier();
    });
