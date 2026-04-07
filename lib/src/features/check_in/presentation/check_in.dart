import 'package:absensi_go/src/features/check_in/presentation/widgets/index.dart';
import 'package:absensi_go/src/features/check_in/provider/check_in_provider.dart';
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
    final asyncState = ref.watch(checkInProvider);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
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
                  onRefresh: () => ref.read(checkInProvider.notifier).getLocation(),
                  onMapCreated: (controller) {
                    _mapController = controller;
                    if (state.hasLocation && mounted) {
                      try {
                        controller.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(state.latitude!, state.longitude!),
                              zoom: 17,
                            ),
                          ),
                        );
                      } catch (e) {
                        debugPrint('Map animation error: $e');
                      }
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
    final canSubmit = _isRequestIzin
        ? (_izinDate != null && _alasanIzinController.text.isNotEmpty)
        : (state.hasLocation &&
              !state.isSubmitting &&
              !state.isLoadingLocation &&
              !state.hasCheckedIn);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: canSubmit
                ? () async {
                    if (_isRequestIzin) {
                      final izinModel = IzinModel(
                        attendanceDate: _izinDate,
                        status: 'izin',
                        alasanIzin: _alasanIzinController.text,
                      );

                      try {
                        await ref
                            .read(izinProvider.notifier)
                            .submitIzin(izinModel);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Izin berhasil diajukan!'),
                              backgroundColor: const Color(0xFF3B6D11),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal mengajukan izin: $e'),
                              backgroundColor: const Color(0xFF993C1D),
                            ),
                          );
                        }
                      }
                    } else {
                      final success = await ref
                          .read(checkInProvider.notifier)
                          .submitCheckIn();

                      if (context.mounted) {
                        final updatedState = ref.read(checkInProvider).value;
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
                : null,
            style: TextButton.styleFrom(
              backgroundColor: canSubmit
                  ? const Color(0xFF1A1A2E)
                  : Colors.grey.shade200,
              foregroundColor: canSubmit ? Colors.white : Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: state.isSubmitting
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
        ),
      ],
    );
  }
}
