import 'package:absensi_go/src/features/check_in/presentation/widgets/location_empty_widget.dart';
import 'package:absensi_go/src/features/check_in/presentation/widgets/location_error_widget.dart';
import 'package:absensi_go/src/features/check_in/presentation/widgets/location_info_widget.dart';
import 'package:absensi_go/src/features/check_in/presentation/widgets/map_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationCard extends StatelessWidget {
  final bool hasLocation;
  final double? latitude;
  final double? longitude;
  final String? address;
  final bool isLoadingLocation;
  final String? errorMessage;
  final VoidCallback onRefresh;
  final Function(GoogleMapController) onMapCreated;

  const LocationCard({
    required this.hasLocation,
    this.latitude,
    this.longitude,
    this.address,
    required this.isLoadingLocation,
    this.errorMessage,
    required this.onRefresh,
    required this.onMapCreated,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
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
                if (!isLoadingLocation)
                  GestureDetector(
                    onTap: onRefresh,
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
          MapView(
            hasLocation: hasLocation,
            latitude: latitude,
            longitude: longitude,
            address: address,
            isLoadingLocation: isLoadingLocation,
            onMapCreated: onMapCreated,
          ),

          // Info Alamat & Koordinat
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildLocationInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    if (isLoadingLocation) {
      return const SizedBox.shrink();
    }

    if (errorMessage != null) {
      return LocationError(
        message: errorMessage!,
        onRetry: onRefresh,
      );
    }

    if (hasLocation) {
      return LocationInfo(address: address);
    }

    return const LocationEmpty();
  }
}
