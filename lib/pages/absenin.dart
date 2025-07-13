import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onepresence/api/absen_status_api.dart';
import 'package:onepresence/model/absen_status_model.dart';
import 'package:onepresence/api/absen_api.dart';
import 'package:onepresence/pages/in_navbot/home_page.dart';
import 'package:onepresence/pages/navBott.dart';
import 'package:onepresence/model/absen_checkin_response_model.dart';

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
  bool _checkedIn = false;
  final double _radius = 4.0; // meter
  final LatLng _officeLocation = const LatLng(
    -6.210879,
    106.812942,
  ); // Ganti dengan lokasi kantor
  double _distance = 0.0;
  bool _isSubmitting = false;
  bool _refreshingStatus = false; // guard untuk mencegah loop

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
    print('DEBUG: _getCurrentLocation called');
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
    print('DEBUG: _getCurrentLocation finished');
  }

  @override
  void initState() {
    super.initState();
    print('DEBUG: initState called');
    _getCurrentLocation();
    print('DEBUG: initState finished');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('DEBUG: didChangeDependencies called');
    _refreshAbsenStatus();
    print('DEBUG: didChangeDependencies finished');
  }

  Future<void> _refreshAbsenStatus() async {
    if (_refreshingStatus) {
      print('DEBUG: _refreshAbsenStatus skipped (already running)');
      return;
    }
    _refreshingStatus = true;
    print('DEBUG: _refreshAbsenStatus started');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      _refreshingStatus = false;
      print('DEBUG: _refreshAbsenStatus finished (no token)');
      return;
    }
    try {
      final response = await fetchAbsenToday(token);
      final data = response.data;
      setState(() {
        if (data == null ||
            data.jamMasuk == null ||
            data.jamMasuk.isEmpty ||
            !isToday(data.jamMasuk)) {
          _checkedIn = false;
        } else if (isToday(data.jamMasuk) &&
            (data.jamKeluar == null ||
                data.jamKeluar.isEmpty ||
                !isToday(data.jamKeluar))) {
          _checkedIn = true;
        } else if (isToday(data.jamKeluar)) {
          _checkedIn = true;
        }
      });
    } catch (e) {
      if (e.toString().contains(
        'Belum ada data absensi pada tanggal tersebut',
      )) {
        setState(() {
          _checkedIn = false;
        });
      } else {
        setState(() {
          // _absenStatusMessage = 'Gagal cek status absen: $e'; // Removed as per edit hint
        });
      }
    } finally {
      _refreshingStatus = false;
      print('DEBUG: _refreshAbsenStatus finished');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xff106D6B)),
      body: Column(
        children: [
          // Google Map
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 80),
                decoration: const BoxDecoration(color: Color(0xff106D6B)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Radius lokasi: $_radius meter',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xffF1EEDC),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Jarak ke kantor: ${_distance.toStringAsFixed(2)} meter',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xffF1EEDC),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed:
                            (!_checkedIn &&
                                    _distance <= _radius &&
                                    !_isSubmitting)
                                ? () async {
                                  if (!mounted) return;
                                  setState(() {
                                    _isSubmitting = true;
                                  });
                                  try {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final token = prefs.getString('token');
                                    if (token == null) {
                                      throw Exception('Token tidak ditemukan');
                                    }
                                    final response = await absenCheckIn(
                                      token: token,
                                      lat: _currentPosition.latitude,
                                      lng: _currentPosition.longitude,
                                      address: _currentAddress,
                                    );
                                    if (!mounted) return;
                                    if (response is Map &&
                                        response.containsKey('message') &&
                                        response['message']
                                            .toString()
                                            .toLowerCase()
                                            .contains('sudah')) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            response['message'].toString(),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        _checkedIn = true;
                                      });
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Absen masuk berhasil!',
                                          ),
                                          backgroundColor: Colors.greenAccent,
                                        ),
                                      );
                                      await Future.delayed(
                                        Duration(milliseconds: 500),
                                      );
                                      if (!mounted) return;
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HomeBottom(),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                    await _refreshAbsenStatus();
                                  } catch (e) {
                                    if (!mounted) return;
                                    String errorMsg = 'Gagal check-in';
                                    try {
                                      final errorJson = e.toString();
                                      final match = RegExp(
                                        r'"message":"([^"]+)"',
                                      ).firstMatch(errorJson);
                                      if (match != null) {
                                        errorMsg = match.group(1)!;
                                      } else {
                                        errorMsg = e.toString().replaceAll(
                                          'Exception: ',
                                          '',
                                        );
                                      }
                                    } catch (_) {}
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(errorMsg),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    await _refreshAbsenStatus();
                                  } finally {
                                    if (!mounted) return;
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
                                  'Check in',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                      if (_checkedIn)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Sudah check-in',
                            style: const TextStyle(color: Colors.green),
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
