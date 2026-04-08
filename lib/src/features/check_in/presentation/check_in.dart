import 'dart:developer';

import 'package:absensi_go/src/core/constants/app_colors.dart';
import 'package:absensi_go/src/features/attendance/provider/attendance_provider.dart';
import 'package:absensi_go/src/features/check_in/presentation/widgets/index.dart';
import 'package:absensi_go/src/features/check_in/provider/get_today_check_in_provider.dart';
import 'package:absensi_go/src/features/check_in/provider/submit_check_in_provider.dart';
import 'package:absensi_go/src/features/check_out/provider/check_out_provider.dart';
import 'package:absensi_go/src/features/izin/models/izin_model.dart';
import 'package:absensi_go/src/features/izin/provider/izin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  GoogleMapController? _mapController;
  late TextEditingController _alasanIzinController;
  bool _isRequestIzin = false;
  DateTime? _izinDate;

  @override
  void initState() {
    super.initState();
    _alasanIzinController = TextEditingController();
    // ADD THIS:
    _alasanIzinController.addListener(() {
      setState(
        () {},
      ); // This refreshes the UI to check if the button should be enabled
    });
    _izinDate = DateTime.now();
  }

  @override
  void dispose() {
    try {
      _mapController?.dispose();
    } catch (e) {
      debugPrint('Error disposing map controller: $e');
    }
    _mapController = null;
    _alasanIzinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(submitCheckInProvider);
    final now = DateTime.now();
    ref.listen(submitCheckInProvider, (previous, next) {
      next.whenData((state) {
        if (state.hasLocation && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(state.latitude!, state.longitude!),
              17, // Zoom level
            ),
          );
        }
      });
    });
    // -------------------------

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkBg,
        title: const Text(
          'Check In',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        elevation: 0,
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (state) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TimeCard(now: now),
              const SizedBox(height: 16),
              ActivityToggle(
                isRequestIzin: _isRequestIzin,
                onChanged: (value) {
                  if (value != _isRequestIzin) {
                    try {
                      _mapController?.dispose();
                    } catch (e) {
                      debugPrint(
                        'Error disposing controller on mode switch: $e',
                      );
                    }
                    _mapController = null;
                  }
                  setState(() => _isRequestIzin = value);
                },
              ),
              const SizedBox(height: 16),
              if (!_isRequestIzin) ...[
                LocationCard(
                  hasLocation: state.hasLocation,
                  latitude: state.latitude,
                  longitude: state.longitude,
                  address: state.address,
                  isLoadingLocation: state.isLoadingLocation,
                  errorMessage: state.errorMessage,
                  onRefresh: () =>
                      ref.read(submitCheckInProvider.notifier).getLocation(),

                  onMapCreated: (controller) {
                    ref.read(submitCheckInProvider.notifier).getLocation();
                    _mapController = controller;
                    // Target immediately if location already exists when map is built
                    if (state.hasLocation) {
                      controller.moveCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(state.latitude!, state.longitude!),
                          17,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                const StatusCard(),
              ] else ...[
                IzinForm(
                  izinDate: _izinDate,
                  alasanIzinController: _alasanIzinController,
                  onDateChanged: (date) => setState(() => _izinDate = date),
                ),
              ],
              const SizedBox(height: 32),
              _buildSubmitButton(context, ref, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    WidgetRef ref,
    CheckInState state,
  ) {
    // Watch izin state untuk loading & error yang benar
    final izinState = ref.watch(izinProvider);

    final bool isSubmittingIzin = izinState.isSubmitting;
    final bool canSubmit = _isRequestIzin
        ? (_izinDate != null &&
              _alasanIzinController.text.trim().isNotEmpty &&
              !isSubmittingIzin)
        : (state.hasLocation &&
              !state.isSubmitting &&
              !state.isLoadingLocation &&
              !state.hasCheckedIn);

    // Listen untuk error/success dari izinProvider
    ref.listen(izinProvider, (previous, next) {
      if (previous?.errorMessage == null && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: const Color(0xFF993C1D),
          ),
        );
      }
      if (previous?.successMessage == null && next.successMessage != null) {
        ref.invalidate(attendanceProvider);
        ref.invalidate(getTodayCheckInProvider);
        ref.invalidate(checkOutProvider);
        ref.invalidate(izinProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: const Color(0xFF3B6D11),
          ),
        );
        Navigator.pop(context, ref);
      }
    });

    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: canSubmit
            ? () async {
                if (_isRequestIzin) {
                  log('_izinDate: $_izinDate');
                  log('alasan: ${_alasanIzinController.text.trim()}');
                  final izinModel = IzinModel(
                    attendanceDate: _izinDate,
                    alasanIzin: _alasanIzinController.text.trim(),
                  );
                  await ref.read(izinProvider.notifier).submitIzin(izinModel);
                } else {
                  final success = await ref
                      .read(submitCheckInProvider.notifier)
                      .submitCheckIn();

                  if (context.mounted) {
                    final updatedState = ref.read(submitCheckInProvider).value;
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Check in berhasil!'),
                          backgroundColor: Color(0xFF3B6D11),
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            updatedState?.errorMessage ??
                                'Gagal check in. Silakan coba lagi.',
                          ),
                          backgroundColor: const Color(0xFF993C1D),
                        ),
                      );
                    }
                  }
                }
              }
            : null, // null = tombol otomatis disabled
        style: TextButton.styleFrom(
          backgroundColor: canSubmit
              ? const Color(0xFF1A1A2E)
              : Colors.grey.shade400,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: (isSubmittingIzin || state.isSubmitting)
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                _isRequestIzin
                    ? 'Ajukan Izin'
                    : (state.hasCheckedIn
                          ? 'Sudah Check In'
                          : 'Check In Sekarang'),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }
}
