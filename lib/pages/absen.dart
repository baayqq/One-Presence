import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class Absens extends StatefulWidget {
  const Absens({super.key});

  @override
  State<Absens> createState() => _AbsensState();
}

class _AbsensState extends State<Absens> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(-6.210879, 106.812942);
  String _currentAddress = 'Memuat alamat...';
  Marker? _marker;
  bool _loading = true;

  Future<void> _getCurrentLocation() async {
    setState(() {
      _loading = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = LatLng(position.latitude, position.longitude);

      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition.latitude,
        _currentPosition.longitude,
      );

      Placemark? place = placemarks.isNotEmpty ? placemarks.first : null;

      setState(() {
        _marker = Marker(
          markerId: const MarkerId('lokasi_saya'),
          position: _currentPosition,
          infoWindow: InfoWindow(
            title: 'Lokasi Anda',
            snippet: place != null ? '${place.street}, ${place.locality}' : '',
          ),
        );

        _currentAddress =
            place != null
                ? "${place.name}, ${place.street}, ${place.locality}, ${place.country}"
                : "Alamat tidak ditemukan";

        _loading = false;

        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentPosition, zoom: 16),
          ),
        );
      });
    } catch (e) {
      setState(() {
        _currentAddress = "Gagal mendapatkan lokasi: $e";
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          // Google Map
          Padding(
            padding: const EdgeInsets.only(top: 140, left: 12, right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 400,
                width: double.infinity,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 14,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  markers: _marker != null ? {_marker!} : {},
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
              ),
            ),
          ),

          // Alamat di atas Map
          Positioned(
            top: 32,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child:
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : Text(
                          _currentAddress,
                          style: const TextStyle(fontSize: 14),
                        ),
              ),
            ),
          ),
        ],
      ),

      // Tombol Refresh Lokasi
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _getCurrentLocation,
        icon: const Icon(Icons.location_searching),
        label: const Text('Perbarui Lokasi'),
      ),
    );
  }
}
