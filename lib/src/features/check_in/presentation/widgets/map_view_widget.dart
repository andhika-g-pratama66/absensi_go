import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  final bool hasLocation;
  final double? latitude;
  final double? longitude;
  final String? address;
  final bool isLoadingLocation;
  final Function(GoogleMapController) onMapCreated;

  const MapView({
    required this.hasLocation,
    this.latitude,
    this.longitude,
    this.address,
    required this.isLoadingLocation,
    required this.onMapCreated,
    super.key,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  @override
  Widget build(BuildContext context) {
    final initialPosition = widget.hasLocation
        ? LatLng(widget.latitude!, widget.longitude!)
        : const LatLng(-6.2088, 106.8456);

    final markers = widget.hasLocation
        ? {
            Marker(
              markerId: const MarkerId('my_location'),
              position: LatLng(widget.latitude!, widget.longitude!),
              infoWindow: InfoWindow(
                title: 'Lokasi Saya',
                snippet: widget.address ?? '',
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
                zoom: widget.hasLocation ? 17 : 12,
              ),
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: widget.onMapCreated,
            ),

            // Loading overlay saat mengambil lokasi
            if (widget.isLoadingLocation)
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
              child: _MyLocationButton(
                hasLocation: widget.hasLocation,
                onPressed: () {
                  // Will be handled by parent through onMapCreated
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyLocationButton extends StatelessWidget {
  final bool hasLocation;
  final VoidCallback onPressed;

  const _MyLocationButton({required this.hasLocation, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasLocation ? onPressed : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
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
    );
  }
}
