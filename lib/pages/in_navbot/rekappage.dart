import 'package:flutter/material.dart';
import 'package:onepresence/api/api_file.dart';
import 'package:onepresence/model/absen_stats_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onepresence/api/absen_history_api.dart';
import 'package:onepresence/model/absen_history_model.dart';

class RekapAbs extends StatefulWidget {
  const RekapAbs({super.key});

  @override
  State<RekapAbs> createState() => _RekapAbsState();
}

class _RekapAbsState extends State<RekapAbs> {
  Future<AbsenStatsResponse> fetchStats() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return UserService().getAbsenStats(token);
  }

  List<AbsenHistoryData> _absenHistory = [];
  bool _loadingHistory = true;
  String? _historyError;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchAbsenHistory();
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

  List<AbsenHistoryData> get _filteredHistory {
    if (_selectedDate == null) return _absenHistory;
    final selectedStr = _selectedDateStr();
    return _absenHistory
        .where((absen) => absen.checkIn.startsWith(selectedStr))
        .toList();
  }

  String _selectedDateStr() {
    if (_selectedDate == null) return '';
    return '${_selectedDate!.year.toString().padLeft(4, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AbsenStatsResponse>(
      future: fetchStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.data != null) {
          final stats = snapshot.data!.data!;
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Rekapitulasi Kehadiran',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildStatRow('Total Hadir', stats.totalHadir, Colors.green),
                const SizedBox(height: 16),
                _buildStatRow('Total Izin', stats.totalIzin, Colors.blue),
                const SizedBox(height: 16),
                _buildStatRow('Total Alpha', stats.totalAlpha, Colors.red),
                const SizedBox(height: 16),
                _buildStatRow('Total Telat', stats.totalTelat, Colors.orange),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          _selectedDate == null
                              ? 'Pilih Tanggal'
                              : _selectedDateStr(),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ),
                    if (_selectedDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedDate = null;
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child:
                      _loadingHistory
                          ? const Center(child: CircularProgressIndicator())
                          : _historyError != null
                          ? Center(
                            child: Text('Gagal memuat riwayat: $_historyError'),
                          )
                          : _filteredHistory.isEmpty
                          ? const Center(
                            child: Text('Tidak ada absen pada tanggal ini.'),
                          )
                          : ListView.builder(
                            itemCount: _filteredHistory.length,
                            itemBuilder: (context, index) {
                              final absen = _filteredHistory[index];
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
                                  absen.checkOut != null &&
                                          absen.checkOut!.length >= 19
                                      ? absen.checkOut!.substring(11, 19)
                                      : '-';
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text('Check In'),
                                          Text(jamMasuk),
                                        ],
                                      ),
                                      const SizedBox(width: 32),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
              ],
            ),
          );
        } else {
          return const Center(child: Text('Data tidak ditemukan.'));
        }
      },
    );
  }

  Widget _buildStatRow(String label, int value, Color color) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 18))),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
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
}
