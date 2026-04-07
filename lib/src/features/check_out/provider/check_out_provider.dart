import 'package:absensi_go/src/data/models/check_out_model.dart';
import 'package:absensi_go/src/data/repositories/check_out_repository.dart';
import 'package:absensi_go/src/features/check_in/provider/check_in_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

// ── CheckOutState Class ──────────────────────────────────
class CheckOutState {
  final double? latitude;
  final double? longitude;
  final String? address;
  final bool isLoadingLocation;
  final bool isSubmitting;
  final String? errorMessage;
  final CheckOutModel? todayCheckOut;

  const CheckOutState({
    this.latitude,
    this.longitude,
    this.address,
    this.isLoadingLocation = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.todayCheckOut,
  });

  bool get hasLocation => latitude != null && longitude != null;
  bool get hasCheckedOut => todayCheckOut != null;

  CheckOutState copyWith({
    double? latitude,
    double? longitude,
    String? address,
    bool? isLoadingLocation,
    bool? isSubmitting,
    String? errorMessage,
    CheckOutModel? todayCheckOut,
  }) {
    return CheckOutState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage, // null clears it
      todayCheckOut: todayCheckOut ?? this.todayCheckOut,
    );
  }
}

// ── Notifier ────────────────────────────────────────────

class CheckOutNotifier extends AsyncNotifier<CheckOutState> {
  CheckOutRepository get _repository => ref.read(checkOutRepositoryProvider);

  @override
  Future<CheckOutState> build() async {
    final todayCheckOut = await _repository.getTodayCheckOut();
    return CheckOutState(todayCheckOut: todayCheckOut);
  }

  Future<void> getLocation() async {
    final currentState = state.value ?? const CheckOutState();
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

  Future<bool> submitCheckOut() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasLocation) return false;

    state = AsyncData(
      currentState.copyWith(isSubmitting: true, errorMessage: null),
    );

    try {
      final now = DateTime.now();
      final String formattedTime = DateFormat('HH:mm').format(now);

      final model = CheckOutModel(
        attendanceDate: now,
        checkOut: formattedTime,
        checkOutTime: formattedTime,
        checkOutLat: currentState.latitude,
        checkOutLng: currentState.longitude,
        checkOutLocation: '${currentState.latitude},${currentState.longitude}',
        checkOutAddress: currentState.address,
        status: 'pulang',
      );

      final savedCheckOut = await _repository.submitCheckOut(model);

      state = AsyncData(
        state.value!.copyWith(
          isSubmitting: false,
          todayCheckOut: savedCheckOut,
        ),
      );

      // Invalidate checkInProvider to refresh the home screen state
      ref.invalidate(checkInProvider);

      return true;
    } on CheckOutException catch (e) {
      state = AsyncData(
        state.value!.copyWith(isSubmitting: false, errorMessage: e.message),
      );
      return false;
    } catch (e) {
      state = AsyncData(
        state.value!.copyWith(
          isSubmitting: false,
          errorMessage: 'Gagal check out: $e',
        ),
      );
      return false;
    }
  }
}

// ── Provider ──────────────────────────────────────────

final checkOutProvider = AsyncNotifierProvider<CheckOutNotifier, CheckOutState>(
  () {
    return CheckOutNotifier();
  },
);
