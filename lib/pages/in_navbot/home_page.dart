import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onepresence/pages/absenin.dart';
import 'package:onepresence/pages/absenout.dart';
import 'package:onepresence/api/absen_api.dart';
import 'package:onepresence/model/absen_today_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onepresence/api/absen_history_api.dart';
import 'package:onepresence/model/absen_history_model.dart';
import 'package:onepresence/pages/absensi_history_page.dart';
import 'package:onepresence/api/api_file.dart';
import 'package:onepresence/model/profile_model.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:onepresence/api/absen_api.dart';
import 'package:onepresence/model/absen_history_response_model.dart'
    as absenresp;
import 'package:onepresence/api/absen_today_service.dart';
import 'package:onepresence/model/model_absen.dart';

class HomeSpage extends StatefulWidget {
  const HomeSpage({super.key});

  @override
  State<HomeSpage> createState() => _HomeSpageState();
}

class _HomeSpageState extends State<HomeSpage> {
  late Timer _timer;
  DateTime _now = DateTime.now();
  Absen? _absenToday;
  bool _loadingAbsenToday = true;
  String? _absenTodayError;
  List<AbsenHistoryItem> _absenHistory = [];
  absenresp.AbsenHistoryResponse? _historyResponse;
  bool _loadingHistory = true;
  String? _historyError;
  ProfileData? _profile;
  List<AbsenHistoryItem> _last7History = [];
  bool _loading7History = true;
  String? _history7Error;

  @override
  void initState() {
    super.initState();
    _startClock();
    _fetchAbsenToday();
    _fetchAbsenHistory();
    _fetchAbsen7History();
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
      _refreshProfileIfMounted(); // panggil tanpa await, agar tidak menunggu async di timer
    });
  }

  void _refreshProfileIfMounted() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final profileResponse = await UserService().getProfile(token);
    if (!mounted) return;
    setState(() {
      _profile = profileResponse.data;
    });
  }

  Future<void> _fetchAbsenToday() async {
    if (!mounted) return;
    setState(() {
      _loadingAbsenToday = true;
      _absenTodayError = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        if (!mounted) return;
        setState(() {
          _absenTodayError = 'Token tidak ditemukan.';
          _loadingAbsenToday = false;
        });
        return;
      }
      final absenTodayResponse = await getAbsenToday(token, DateTime.now());
      if (!mounted) return;
      setState(() {
        _absenToday = absenTodayResponse;
        _loadingAbsenToday = false;
      });
      print('Absen today: ${_absenToday?.data?.checkInTime}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _absenTodayError = e.toString();
        _loadingAbsenToday = false;
      });
    }
  }

  Future<void> _fetchAbsenHistory() async {
    if (!mounted) return;
    setState(() {
      _loadingHistory = true;
      _historyError = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        if (!mounted) return;
        setState(() {
          _historyError = 'Token tidak ditemukan.';
          _loadingHistory = false;
        });
        return;
      }
      final historyResponse = await fetchAbsenHistory(token);
      if (!mounted) return;
      setState(() {
        _absenHistory = historyResponse.data;
        _loadingHistory = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _historyError = e.toString();
        _loadingHistory = false;
      });
    }
  }

  Future<void> _fetchAbsen7History() async {
    if (!mounted) return;
    setState(() {
      _loading7History = true;
      _history7Error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        if (!mounted) return;
        setState(() {
          _history7Error = 'Token tidak ditemukan.';
          _loading7History = false;
        });
        return;
      }
      final response = await fetchAbsenHistoryNew(token);
      final all = response.data;
      all.sort((a, b) => b.attendanceDate.compareTo(a.attendanceDate));
      if (!mounted) return;
      setState(() {
        _last7History = all.take(7).toList();
        _loading7History = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _history7Error = e.toString();
        _loading7History = false;
      });
    }
  }

  List<absenresp.AbsenHistoryItem> get _last7DaysHistory {
    if (_historyResponse == null) return [];
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));
    return _historyResponse!.data.where((item) {
      final date = DateTime.tryParse(item.attendanceDate);
      if (date == null) return false;
      return !date.isBefore(sevenDaysAgo) && !date.isAfter(now);
    }).toList();
  }

  Future<ProfileData?> _fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final profileResponse = await UserService().getProfile(token);
    return profileResponse.data;
  }

  // Helper untuk handle base64, url, atau path
  ImageProvider? base64ImageProvider(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    if (base64String.startsWith('data:image')) {
      try {
        final bytes = base64Decode(base64String.split(',').last);
        return MemoryImage(bytes);
      } catch (_) {
        return null;
      }
    }
    if (base64String.startsWith('http')) {
      return NetworkImage(base64String);
    }
    return NetworkImage(
      'https://appabsensi.mobileprojp.com/public/$base64String',
    );
  }

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

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeNow = DateFormat('HH:mm:ss', 'id_ID').format(_now);
    final dateNow = DateFormat('EEE, dd MMMM yyyy', 'id_ID').format(_now);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header dan live attendance
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: const BoxDecoration(
              color: Color(0xff106D6B),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(200),
                bottomRight: Radius.circular(200),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SizedBox(height: 12),
                  Row(
                    children: [
                      _profile != null &&
                              _profile!.profilePhoto != null &&
                              _profile!.profilePhoto!.isNotEmpty
                          ? ClipOval(
                            child: Image(
                              image:
                                  base64ImageProvider(_profile!.profilePhoto!)!,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Icon(
                                    Icons.account_circle,
                                    size: 72,
                                    color: Colors.white,
                                  ),
                            ),
                          )
                          : const Icon(
                            Icons.account_circle,
                            size: 72,
                            color: Colors.white,
                          ),
                      const SizedBox(width: 20),
                      Expanded(
                        child:
                            _profile == null
                                ? const SizedBox(
                                  height: 40,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _profile!.name,
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Fiture akan segera hadir',
                                                ),
                                                backgroundColor:
                                                    Colors.redAccent,
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.dark_mode),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      _profile!.trainingTitle.isNotEmpty
                                          ? _profile!.trainingTitle
                                          : (_profile!.training != null
                                              ? _profile!.training!.title
                                              : '-'),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ===== Live Attendance Container =====
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Live Attendance',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          timeNow,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff106D6B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateNow,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              _loadingAbsenToday
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : (_absenTodayError != null &&
                                      _absenToday != null)
                                  ? Center(
                                    child: Text(
                                      'Gagal memuat absen: $_absenTodayError',
                                    ),
                                  )
                                  : Column(
                                    children: [
                                      const Text(
                                        'Absen Hari Ini',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                (_absenToday
                                                                ?.data
                                                                ?.checkInTime ==
                                                            null ||
                                                        _absenToday
                                                                ?.data
                                                                ?.checkInTime ==
                                                            '')
                                                    ? '-'
                                                    : _getOnlyTime(
                                                      _absenToday!
                                                          .data!
                                                          .checkInTime,
                                                    ),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                              const Text(
                                                'Check in',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 40),
                                          Column(
                                            children: [
                                              Text(
                                                (_absenToday
                                                                ?.data
                                                                ?.checkOutTime ==
                                                            null ||
                                                        _absenToday
                                                                ?.data
                                                                ?.checkOutTime ==
                                                            '')
                                                    ? '-'
                                                    : _getOnlyTime(
                                                      _absenToday!
                                                          .data!
                                                          .checkOutTime,
                                                    ),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                              const Text(
                                                'Check out',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Absens(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff106D6B),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Check in',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AbsensOut(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xffF1EEDC),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Check out',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Absensi 7 Hari',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // GestureDetector(
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => DetailAbs(),
                //       ),
                //     );
                //   },
                //   child: Icon(Icons.history),
                // ),
              ],
            ),
          ),
          // Hanya bagian history yang scrollable
          Expanded(
            child:
                _loading7History
                    ? const Center(child: CircularProgressIndicator())
                    : _history7Error != null
                    ? Center(child: Text('Gagal memuat data:  _history7Error'))
                    : _last7History.isEmpty
                    ? const Center(
                      child: Text('-', style: TextStyle(fontSize: 18)),
                    )
                    : ListView.builder(
                      itemCount: _last7History.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, idx) {
                        final absen = _last7History[idx];
                        final tgl =
                            absen.attendanceDate.length >= 10
                                ? absen.attendanceDate.substring(8, 10)
                                : '-';
                        final bulan =
                            absen.attendanceDate.length >= 7
                                ? absen.attendanceDate.substring(5, 7)
                                : '-';
                        final namaBulan = _getNamaBulan(bulan);
                        final jamMasuk = absen.checkInTime ?? '--';
                        final jamKeluar = absen.checkOutTime ?? '--';
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16,
                          ),
                          child: Container(
                            width: double.infinity,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Color(0xffF1EEDC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Color(0x9fF1EEDC),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            tgl,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            namaBulan,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 24),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [Text(jamMasuk), Text('Check in')],
                                ),
                                SizedBox(width: 24),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(jamKeluar),
                                    Text('Check out'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  String _getOnlyTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateTimeStr.replaceFirst(' ', 'T'));
      return DateFormat('HH:mm:ss', 'id_ID').format(dt);
    } catch (_) {
      return dateTimeStr.length >= 8
          ? dateTimeStr.substring(dateTimeStr.length - 8)
          : dateTimeStr;
    }
  }

  String _getNamaBulan(String bulan) {
    switch (bulan) {
      case '01':
        return 'Jan';
      case '02':
        return 'Feb';
      case '03':
        return 'Mar';
      case '04':
        return 'Apr';
      case '05':
        return 'Mei';
      case '06':
        return 'Jun';
      case '07':
        return 'Jul';
      case '08':
        return 'Agu';
      case '09':
        return 'Sep';
      case '10':
        return 'Okt';
      case '11':
        return 'Nov';
      case '12':
        return 'Des';
      default:
        return '';
    }
  }
}
