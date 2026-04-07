import 'package:absensi_go/src/features/check_in/presentation/widgets/index.dart';
import 'package:absensi_go/src/features/check_out/provider/check_out_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CheckOutScreen extends ConsumerStatefulWidget {
  const CheckOutScreen({super.key});

  @override
  ConsumerState<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends ConsumerState<CheckOutScreen> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    try {
      _mapController?.dispose();
    } catch (e) {
      debugPrint('Error disposing map controller: $e');
    }
    _mapController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Watch the AsyncValue from checkOutProvider properly
    final asyncState = ref.watch(checkOutProvider);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        title: const Text(
          'Check Out',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        elevation: 0,
      ),
      // FIX: Using .when to handle the AsyncValue states (loading, error, data)
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

              if (state.errorMessage != null && !state.isSubmitting) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    state.errorMessage!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              LocationCard(
                hasLocation: state.hasLocation,
                latitude: state.latitude,
                longitude: state.longitude,
                address: state.address,
                isLoadingLocation: state.isLoadingLocation,
                errorMessage: state.errorMessage,
                onRefresh: () => ref.read(checkOutProvider.notifier).getLocation(),
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
              _buildCheckOutStatusCard(),
              const SizedBox(height: 32),
              _buildSubmitButton(context, ref, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckOutStatusCard() {
    final now = DateTime.now();
    final jamPulang = DateTime(now.year, now.month, now.day, 17, 0);
    final isEarly = now.isBefore(jamPulang);
    final statusLabel = isEarly ? 'Pulang Awal' : 'Sesuai Jadwal';
    final statusColor = isEarly
        ? const Color(0xFF993C1D)
        : const Color(0xFF3B6D11);
    final statusBg = isEarly ? const Color(0xFFFAECE7) : const Color(0xFFEAF3DE);
    final statusIcon = isEarly
        ? Icons.warning_rounded
        : Icons.check_circle_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Status Kepulangan',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            'Jam pulang 17:00',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    WidgetRef ref,
    CheckOutState state,
  ) {
    final canSubmit = state.hasLocation &&
        !state.isSubmitting &&
        !state.isLoadingLocation &&
        !state.hasCheckedOut;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: canSubmit
                ? () async {
                    final success = await ref
                        .read(checkOutProvider.notifier)
                        .submitCheckOut();
                    
                    if (context.mounted) {
                      final updatedState = ref.read(checkOutProvider).value;
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Check out berhasil!'),
                            backgroundColor: Color(0xFF3B6D11),
                          ),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              updatedState?.errorMessage ??
                                  'Gagal check out. Silakan coba lagi.',
                            ),
                            backgroundColor: const Color(0xFF993C1D),
                          ),
                        );
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
                    state.hasCheckedOut ? 'Sudah Check Out' : 'Check Out Sekarang',
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
