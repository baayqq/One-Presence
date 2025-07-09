import 'package:flutter/material.dart';
import 'package:onepresence/api/absen_history_api.dart';
import 'package:onepresence/model/absen_history_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AbsensiHistoryPage extends StatefulWidget {
  @override
  State<AbsensiHistoryPage> createState() => _AbsensiHistoryPageState();
}

class _AbsensiHistoryPageState extends State<AbsensiHistoryPage> {
  List<AbsenHistoryData> _absenHistory = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAbsenHistory();
  }

  Future<void> _fetchAbsenHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        setState(() {
          _error = 'Token tidak ditemukan.';
          _loading = false;
        });
        return;
      }
      final historyResponse = await fetchAbsenHistory(token);
      setState(() {
        _absenHistory = historyResponse.data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Absensi')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('Gagal memuat riwayat: $_error'))
              : _absenHistory.isEmpty
              ? const Center(child: Text('Belum ada riwayat absensi'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _absenHistory.length,
                itemBuilder: (context, index) {
                  final absen = _absenHistory[index];
                  final tgl =
                      absen.checkIn.length >= 10
                          ? absen.checkIn.substring(8, 10)
                          : '';
                  final bulan =
                      absen.checkIn.length >= 7
                          ? absen.checkIn.substring(5, 7)
                          : '';
                  final namaBulan = _getNamaBulan(bulan);
                  final jamMasuk =
                      absen.checkIn.length >= 19
                          ? absen.checkIn.substring(11, 19)
                          : '-';
                  final jamKeluar =
                      absen.checkOut != null && absen.checkOut!.length >= 19
                          ? absen.checkOut!.substring(11, 19)
                          : '-';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0x8f9CDBA6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Container(
                              width: 80,
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
                          const SizedBox(width: 18),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [const Text('Check In'), Text(jamMasuk)],
                          ),
                          const SizedBox(width: 32),
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
    );
  }
}
