import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onepresence/api/absen_checkout_api.dart';
import 'package:onepresence/model/absen_checkout_model.dart';
import 'package:onepresence/pages/in_navbot/home_page.dart';
import 'package:onepresence/pages/navBott.dart';
import 'package:onepresence/api/absen_api.dart';

class AbsensOut extends StatefulWidget {
  const AbsensOut({super.key});

  @override
  State<AbsensOut> createState() => _AbsensOutState();
}

class _AbsensOutState extends State<AbsensOut> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(-6.210879, 106.812942);
  String _currentAddress = 'Memuat alamat...';
  Marker? _marker;
  bool _loading = true;
  String? _userName;
  bool _checkedOut = false;
  final double _radius = 10.0; // meter
  final LatLng _officeLocation = const LatLng(
    -6.210879,
    106.812942,
  ); // Ganti dengan lokasi kantor
  double _distance = 0.0;
  bool _isSubmitting = false;

  // Helper untuk cek apakah tanggal pada string adalah hari ini
  bool isToday(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return false;
    try {
      final dt = DateTime.parse(dateTimeStr.replaceFirst(' ', 'T'));
      final now = DateTime.now();
      return dt.year == now.year && dt.month == now.month && dt.day == now.day;
    } catch (_) {
      return false;
    }
  }

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
      _distance = Geolocator.distanceBetween(
        _currentPosition.latitude,
        _currentPosition.longitude,
        _officeLocation.latitude,
        _officeLocation.longitude,
      );

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
      if (!mounted) return;
      setState(() {
        _currentAddress = "Gagal mendapatkan lokasi: $e";
        _loading = false;
      });
    }
  }

  Future<void> _getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userName = prefs.getString('username') ?? 'User';
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getUserName();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshAbsenStatus();
  }

  Future<void> _refreshAbsenStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;
    final response = await fetchAbsenToday(token);
    final data = response.data;
    setState(() {
      if (data == null ||
          data.jamKeluar == null ||
          data.jamKeluar.isEmpty ||
          !isToday(data.jamKeluar)) {
        _checkedOut = false;
      } else if (isToday(data.jamKeluar)) {
        _checkedOut = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          // Google Map
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 12, right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 300,
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
          // Isi absen di bawah
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  decoration: const BoxDecoration(color: Color(0xff468585)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nama: ${_userName ?? ''}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Status: ${_checkedOut ? 'Sudah check-out' : 'Belum check-out'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: _checkedOut ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Radius lokasi: $_radius meter',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Jarak ke kantor: ${_distance.toStringAsFixed(2)} meter',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              (!_checkedOut &&
                                      _distance <= _radius &&
                                      !_isSubmitting)
                                  ? () async {
                                    setState(() {
                                      _isSubmitting = true;
                                    });
                                    try {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      final token = prefs.getString('token');
                                      if (token == null) {
                                        throw Exception(
                                          'Token tidak ditemukan',
                                        );
                                      }
                                      final response = await absenCheckOut(
                                        token: token,
                                        lat: _currentPosition.latitude,
                                        lng: _currentPosition.longitude,
                                        address: _currentAddress,
                                      );
                                      setState(() {
                                        _checkedOut = true;
                                      });
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(response.message),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HomeBottom(),
                                        ),
                                        (route) => false,
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Gagal check-out: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    } finally {
                                      setState(() {
                                        _isSubmitting = false;
                                      });
                                    }
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 32,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child:
                              _isSubmitting
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    'Check out',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                        if (_distance > _radius)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Anda harus berada dalam radius $_radius meter dari kantor.',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _getCurrentLocation,
        icon: const Icon(Icons.location_searching),
        label: const Text('Perbarui Lokasi'),
      ),
    );
  }
}
