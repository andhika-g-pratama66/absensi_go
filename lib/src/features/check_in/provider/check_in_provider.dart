import 'package:absensi_go/src/data/models/check_in_model.dart';
import 'package:absensi_go/src/data/repositories/check_in_repository.dart';
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class CheckInState {
  final bool isLoadingLocation;
  final bool isSubmitting;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? errorMessage;

  const CheckInState({
    this.isLoadingLocation = false,
    this.isSubmitting = false,
    this.latitude,
    this.longitude,
    this.address,
    this.errorMessage,
  });

  bool get hasLocation => latitude != null && longitude != null;

  CheckInState copyWith({
    bool? isLoadingLocation,
    bool? isSubmitting,
    double? latitude,
    double? longitude,
    String? address,
    String? errorMessage,
  }) {
    return CheckInState(
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      errorMessage: errorMessage,
    );
  }
}

class CheckInNotifier extends StateNotifier<CheckInState> {
  final CheckInRepository _repository;

  CheckInNotifier(this._repository) : super(const CheckInState()) {
    getLocation();
  }

  Future<void> getLocation() async {
    state = state.copyWith(isLoadingLocation: true, errorMessage: null);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoadingLocation: false,
          errorMessage:
              'Layanan lokasi tidak aktif. Aktifkan GPS terlebih dahulu.',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            isLoadingLocation: false,
            errorMessage: 'Izin lokasi ditolak.',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoadingLocation: false,
          errorMessage:
              'Izin lokasi ditolak permanen. Buka pengaturan untuk mengaktifkan.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
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

      state = state.copyWith(
        isLoadingLocation: false,
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingLocation: false,
        errorMessage: 'Gagal mendapatkan lokasi: $e',
      );
    }
  }

  Future<bool> submitCheckIn() async {
    if (!state.hasLocation) return false;

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final now = DateTime.now();
      final isLate = now.isAfter(DateTime(now.year, now.month, now.day, 8, 0));

      final model = CheckInModel(
        attendanceDate: now,
        checkIn: DateFormat('HH:mm:ss').format(now),
        checkInLat: state.latitude,
        checkInLng: state.longitude,
        checkInAddress: state.address,
        status: isLate ? 'terlambat' : 'tepat_waktu',
      );

      await _repository.submitCheckIn(model);

      state = state.copyWith(isSubmitting: false);
      return true;
    } on CheckInException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Gagal check in: $e',
      );
      return false;
    }
  }
}

// ── Repository Provider ───────────────────────────────────

final checkInRepositoryProvider = Provider<CheckInRepository>((ref) {
  final repo = CheckInRepositoryImpl();

  ref.watch(tokenProvider).whenData((token) {
    if (token != null) {
      repo.setAuthToken(token);
    }
  });

  return repo;
});

// ── State Provider ────────────────────────────────────────

final checkInProvider =
    StateNotifierProvider.autoDispose<CheckInNotifier, CheckInState>(
      (ref) => CheckInNotifier(ref.read(checkInRepositoryProvider)),
    );
