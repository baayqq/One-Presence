import 'package:flutter/material.dart';
import 'package:onepresence/api/absen_stats_api.dart';
import 'package:onepresence/model/absen_stats_model.dart';
import 'package:onepresence/api/absen_history_api.dart';
import 'package:onepresence/model/absen_history_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class RekapAbs extends StatefulWidget {
  const RekapAbs({super.key});

  @override
  State<RekapAbs> createState() => _RekapAbsState();
}

class _RekapAbsState extends State<RekapAbs> {
  DateTime? _selectedDate;
  Future<AbsenStatsResponse>? _statsFuture;
  Future<AbsenHistoryResponse>? _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    setState(() {
      _statsFuture = fetchAbsenStats(token);
      _historyFuture = fetchAbsenHistoryNew(token);
    });
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<AbsenStatsResponse>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Gagal memuat statistik: ${snapshot.error}');
              } else if (snapshot.hasData) {
                final stats = snapshot.data!.data;
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statBox('Total Absen', stats.totalAbsen),
                        _statBox('Masuk', stats.totalMasuk),
                        _statBox('Izin', stats.totalIzin),
                        Column(
                          children: [
                            const Text(
                              'Hari Ini',
                              style: TextStyle(fontSize: 12),
                            ),
                            Icon(
                              stats.sudahAbsenHariIni
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color:
                                  stats.sudahAbsenHariIni
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'History Absensi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.date_range),
                label: Text(
                  _selectedDate == null
                      ? 'Pilih Tanggal'
                      : DateFormat(
                        'dd MMM yyyy',
                        'id_ID',
                      ).format(_selectedDate!),
                ),
                onPressed: _pickDate,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<AbsenHistoryResponse>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Gagal memuat history: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  List<AbsenHistoryItem> data = snapshot.data!.data;
                  if (_selectedDate != null) {
                    final filterStr = DateFormat(
                      'yyyy-MM-dd',
                    ).format(_selectedDate!);
                    data =
                        data
                            .where((e) => e.attendanceDate == filterStr)
                            .toList();
                  }
                  if (data.isEmpty) {
                    return const Center(child: Text('-'));
                  }
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, idx) {
                      final absen = data[idx];
                      final tgl =
                          absen.attendanceDate.length >= 10
                              ? absen.attendanceDate.substring(8, 10)
                              : '-';
                      final bulan =
                          absen.attendanceDate.length >= 7
                              ? absen.attendanceDate.substring(5, 7)
                              : '-';
                      final namaBulan = _getNamaBulan(bulan);
                      final jamMasuk = absen.checkInTime ?? '-';
                      final jamKeluar = absen.checkOutTime ?? '-';
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                tgl,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                namaBulan,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Check in',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    jamMasuk,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Check out',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    jamKeluar,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          subtitle:
                              absen.status == 'izin' && absen.alasanIzin != null
                                  ? Text(
                                    'Izin: ${absen.alasanIzin!}',
                                    style: const TextStyle(
                                      color: Colors.orange,
                                    ),
                                  )
                                  : null,
                        ),
                      );
                    },
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
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
