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

class HomeSpage extends StatefulWidget {
  const HomeSpage({super.key});

  @override
  State<HomeSpage> createState() => _HomeSpageState();
}

class _HomeSpageState extends State<HomeSpage> {
  late Timer _timer;
  DateTime _now = DateTime.now();
  AbsenTodayData? _absenToday;
  bool _loadingAbsenToday = true;
  String? _absenTodayError;
  List<AbsenHistoryData> _absenHistory = [];
  bool _loadingHistory = true;
  String? _historyError;

  @override
  void initState() {
    super.initState();
    _startClock();
    _fetchAbsenToday();
    _fetchAbsenHistory();
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  Future<void> _fetchAbsenToday() async {
    setState(() {
      _loadingAbsenToday = true;
      _absenTodayError = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        setState(() {
          _absenTodayError = 'Token tidak ditemukan.';
          _loadingAbsenToday = false;
        });
        return;
      }
      final absenTodayResponse = await fetchAbsenToday(token);
      setState(() {
        _absenToday = absenTodayResponse.data;
        _loadingAbsenToday = false;
      });
    } catch (e) {
      setState(() {
        _absenTodayError = e.toString();
        _loadingAbsenToday = false;
      });
    }
  }

  Future<void> _fetchAbsenHistory() async {
    setState(() {
      _loadingHistory = true;
      _historyError = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        setState(() {
          _historyError = 'Token tidak ditemukan.';
          _loadingHistory = false;
        });
        return;
      }
      final historyResponse = await fetchAbsenHistory(token);
      setState(() {
        _absenHistory = historyResponse.data;
        _loadingHistory = false;
      });
    } catch (e) {
      setState(() {
        _historyError = e.toString();
        _loadingHistory = false;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeNow = DateFormat('hh:mm:ss a').format(_now);
    final dateNow = DateFormat('EEE, dd MMMM yyyy', 'en_US').format(_now);

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: const BoxDecoration(
              color: Color(0xff468585),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(200),
                bottomRight: Radius.circular(200),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.account_circle,
                        size: 72,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Bayu Saputra',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ],
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
                            color: Colors.teal,
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
                                  : _absenTodayError != null
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
                                                _getOnlyTime(
                                                  _absenToday?.jamMasuk,
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
                                                _getOnlyTime(
                                                  _absenToday?.jamKeluar,
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
                                  backgroundColor: Colors.teal,
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
                                  backgroundColor: Colors.grey.shade300,
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

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'History Absensi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AbsensiHistoryPage(),
                      ),
                    );
                  },
                  child: Icon(Icons.history, color: Colors.teal),
                ),
              ],
            ),
          ),

          // ===== List absensi scrollable =====
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child:
                  _loadingHistory
                      ? const Center(child: CircularProgressIndicator())
                      : _historyError != null
                      ? Center(
                        child: Text('Gagal memuat riwayat: $_historyError'),
                      )
                      : _absenHistory.isEmpty
                      ? const Center(child: Text('Belum ada riwayat absensi'))
                      : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: _absenHistory.length,
                        itemBuilder: (context, index) {
                          final absen = _absenHistory[index];
                          // Format tanggal: 13\nJuli
                          final tgl =
                              absen.checkIn.length >= 10
                                  ? absen.checkIn.substring(8, 10)
                                  : '';
                          final bulan =
                              absen.checkIn.length >= 7
                                  ? absen.checkIn.substring(5, 7)
                                  : '';
                          final namaBulan = _getNamaBulan(bulan);
                          // Format jam
                          final jamMasuk =
                              absen.checkIn.length >= 19
                                  ? absen.checkIn.substring(11, 19)
                                  : '-';
                          final jamKeluar =
                              absen.checkOut != null &&
                                      absen.checkOut!.length >= 19
                                  ? absen.checkOut!.substring(11, 19)
                                  : '-';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0x8f9CDBA6),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Container(
                                      width: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: const Color(0xffDEF9C4),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$tgl\n$namaBulan',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 28),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Check In'),
                                      Text(jamMasuk),
                                    ],
                                  ),
                                  const SizedBox(width: 52),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Check Out'),
                                      Text(jamKeluar),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
    );
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

  String _getOnlyTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateTimeStr.replaceFirst(' ', 'T'));
      return DateFormat('HH:mm:ss').format(dt);
    } catch (_) {
      return dateTimeStr.length >= 8
          ? dateTimeStr.substring(dateTimeStr.length - 8)
          : dateTimeStr;
    }
  }
}
