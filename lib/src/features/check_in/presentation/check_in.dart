import 'package:absensi_go/src/features/check_in/provider/check_in_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkInProvider);
    final now = DateTime.now();

    // Animasikan kamera ke posisi terbaru saat koordinat berubah
    if (_mapController != null && state.hasLocation) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(state.latitude!, state.longitude!),
            zoom: 17,
          ),
        ),
      );
    }

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeCard(now),
            const SizedBox(height: 16),
            _buildLocationCard(context, ref, state),
            const SizedBox(height: 16),
            _buildStatusCard(),
            const SizedBox(height: 32),
            _buildSubmitButton(context, ref, state),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard(DateTime now) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, d MMMM yyyy').format(now).toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white38,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, _) => Text(
              DateFormat('HH:mm:ss').format(DateTime.now()),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _timeChip(
                icon: Icons.calendar_today_rounded,
                label: DateFormat('dd/MM/yyyy').format(now),
              ),
              const SizedBox(width: 8),
              _timeChip(
                icon: Icons.access_time_rounded,
                label: DateFormat('HH:mm').format(now),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white54),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(
    BuildContext context,
    WidgetRef ref,
    CheckInState state,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lokasi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                if (!state.isLoadingLocation)
                  GestureDetector(
                    onTap: () =>
                        ref.read(checkInProvider.notifier).getLocation(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3DE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 12,
                            color: Color(0xFF3B6D11),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Perbarui',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF3B6D11),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Google Maps Widget
          _buildMapView(state),

          // Info Alamat & Koordinat
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildLocationInfo(context, ref, state),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView(CheckInState state) {
    final initialPosition = state.hasLocation
        ? LatLng(state.latitude!, state.longitude!)
        : const LatLng(-6.2088, 106.8456);

    final markers = state.hasLocation
        ? {
            Marker(
              markerId: const MarkerId('my_location'),
              position: LatLng(state.latitude!, state.longitude!),
              infoWindow: InfoWindow(
                title: 'Lokasi Saya',
                snippet: state.address ?? '',
              ),
            ),
          }
        : <Marker>{};

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.zero),
      child: SizedBox(
        height: 200,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialPosition,
                zoom: state.hasLocation ? 17 : 12,
              ),
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
                // Langsung animasi setelah map siap
                if (state.hasLocation) {
                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(state.latitude!, state.longitude!),
                        zoom: 17,
                      ),
                    ),
                  );
                }
              },
            ),

            // Loading overlay saat mengambil lokasi
            if (state.isLoadingLocation)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Mendapatkan lokasi...',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Tombol "My Location" custom di kanan bawah peta
            Positioned(
              right: 10,
              bottom: 10,
              child: GestureDetector(
                onTap: () {
                  if (_mapController != null && state.hasLocation) {
                    _mapController!.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(state.latitude!, state.longitude!),
                          zoom: 17,
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.my_location_rounded,
                    size: 18,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(
    BuildContext context,
    WidgetRef ref,
    CheckInState state,
  ) {
    if (state.isLoadingLocation) {
      return const SizedBox.shrink();
    }

    if (state.errorMessage != null) {
      return _LocationError(
        message: state.errorMessage!,
        onRetry: () => ref.read(checkInProvider.notifier).getLocation(),
      );
    }

    if (state.hasLocation) {
      return _LocationInfo(state: state);
    }

    return const _LocationEmpty();
  }

  Widget _buildStatusCard() {
    final now = DateTime.now();
    final jamMasuk = DateTime(now.year, now.month, now.day, 8, 0);
    final isLate = now.isAfter(jamMasuk);
    final statusLabel = isLate ? 'Terlambat' : 'Tepat Waktu';
    final statusColor = isLate
        ? const Color(0xFF993C1D)
        : const Color(0xFF3B6D11);
    final statusBg = isLate ? const Color(0xFFFAECE7) : const Color(0xFFEAF3DE);
    final statusIcon = isLate
        ? Icons.warning_rounded
        : Icons.check_circle_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
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
                'Status Kehadiran',
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
            'Jam masuk 08:00',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    WidgetRef ref,
    CheckInState state,
  ) {
    final canSubmit =
        state.hasLocation && !state.isSubmitting && !state.isLoadingLocation;

    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: canSubmit
            ? () async {
                final success = await ref
                    .read(checkInProvider.notifier)
                    .submitCheckIn();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Check in berhasil!'),
                      backgroundColor: const Color(0xFF3B6D11),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  Navigator.pop(context);
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
          disabledBackgroundColor: Colors.grey.shade200,
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
            : const Text(
                'Check In Sekarang',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
      ),
    );
  }
}

// ── Sub Widgets ──────────────────────────────────────────

class _LocationError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _LocationError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.location_off_rounded,
              size: 16,
              color: Color(0xFF993C1D),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 12, color: Color(0xFF993C1D)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onRetry,
          child: const Text(
            'Coba lagi',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF1A1A2E),
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationInfo extends StatelessWidget {
  final CheckInState state;
  const _LocationInfo({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on_rounded,
              size: 16,
              color: Color(0xFF1A1A2E),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                state.address ?? '-',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1A1A2E),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LocationEmpty extends StatelessWidget {
  const _LocationEmpty();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.location_searching_rounded, size: 16, color: Colors.grey),
        SizedBox(width: 8),
        Text(
          'Lokasi belum tersedia',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }
}
