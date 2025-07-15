import 'package:flutter/material.dart';
import 'package:onepresence/api/absen_stats_api.dart';
import 'package:onepresence/model/absen_stats_model.dart';
import 'package:onepresence/api/absen_history_api.dart';
import 'package:onepresence/model/absen_history_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:onepresence/model/izin_absen_model.dart';
import 'package:onepresence/api/api_file.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class RekapAbs extends StatefulWidget {
  const RekapAbs({super.key});

  @override
  State<RekapAbs> createState() => _RekapAbsState();
}

class _RekapAbsState extends State<RekapAbs> {
  DateTime? _selectedMonth;
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

  void _pickMonth() async {
    final now = DateTime.now();
    final picked = await showMonthPicker(
      context: context,
      initialDate: _selectedMonth ?? DateTime(now.year, now.month),
      firstDate: DateTime(2020, 1),
      lastDate: DateTime(now.year + 1, 12),
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
              return Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xff106D6B),
                  // borderRadius: BorderRadius.only(
                  //   bottomLeft: Radius.circular(40),
                  //   bottomRight: Radius.circular(40),
                  // ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(height: 48),
                      Card(
                        // color: Color(0xffF1EEDC),
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
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.assignment_late),
                          label: const Text('Ajukan Izin'),
                          // style: ElevatedButton.styleFrom(
                          //   backgroundColor: Color(0xffF1EEDC),
                          // ),
                          onPressed: () async {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                DateTime? selectedDate = DateTime.now();
                                TextEditingController alasanController =
                                    TextEditingController();
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      title: const Text('Ajukan Izin Absen'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            title: Text(
                                              selectedDate == null
                                                  ? 'Pilih Tanggal'
                                                  : DateFormat(
                                                    'yyyy-MM-dd',
                                                  ).format(selectedDate!),
                                            ),
                                            trailing: Icon(Icons.date_range),
                                            onTap: () async {
                                              final picked =
                                                  await showDatePicker(
                                                    context: context,
                                                    initialDate:
                                                        selectedDate ??
                                                        DateTime.now(),
                                                    firstDate: DateTime(2020),
                                                    lastDate: DateTime.now()
                                                        .add(
                                                          const Duration(
                                                            days: 365,
                                                          ),
                                                        ),
                                                  );
                                              if (picked != null) {
                                                setState(() {
                                                  selectedDate = picked;
                                                });
                                              }
                                            },
                                          ),
                                          TextField(
                                            controller: alasanController,
                                            decoration: const InputDecoration(
                                              labelText: 'Alasan Izin',
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text('Batal'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            if (selectedDate != null &&
                                                alasanController
                                                    .text
                                                    .isNotEmpty) {
                                              try {
                                                final prefs =
                                                    await SharedPreferences.getInstance();
                                                final token =
                                                    prefs.getString('token') ??
                                                    '';
                                                final tanggalIzin = DateFormat(
                                                  'yyyy-MM-dd',
                                                ).format(selectedDate!);
                                                final izinResponse =
                                                    await UserService()
                                                        .ajukanIzinAbsen(
                                                          token: token,
                                                          date: tanggalIzin,
                                                          alasanIzin:
                                                              alasanController
                                                                  .text,
                                                        );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      izinResponse.message,
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );
                                                Navigator.pop(context, true);
                                              } catch (e) {
                                                String errorMsg =
                                                    'Gagal mengajukan izin';
                                                try {
                                                  final errorJson =
                                                      e.toString();
                                                  final match = RegExp(
                                                    r'"message":"([^"]+)"',
                                                  ).firstMatch(errorJson);
                                                  if (match != null) {
                                                    errorMsg = match.group(1)!;
                                                  } else {
                                                    errorMsg = e
                                                        .toString()
                                                        .replaceAll(
                                                          'Exception: ',
                                                          '',
                                                        );
                                                  }
                                                } catch (_) {}
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(errorMsg),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          child: const Text('Ajukan'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                            if (result == true) {
                              _loadData();
                            }
                          },
                        ),
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

        Padding(
          padding: const EdgeInsets.only(left: 18, right: 18, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'History Absensi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton.icon(
                icon: const Icon(Icons.date_range),
                label: Text(
                  _selectedMonth == null
                      ? 'Pilih Bulan'
                      : DateFormat(
                        'MMMM yyyy',
                        'id_ID',
                      ).format(_selectedMonth!),
                ),
                onPressed: _pickMonth,
              ),
            ],
          ),
        ),

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
                if (_selectedMonth != null) {
                  final monthStr = _selectedMonth!.month.toString().padLeft(
                    2,
                    '0',
                  );
                  final yearStr = _selectedMonth!.year.toString();
                  data =
                      data
                          .where(
                            (e) =>
                                e.attendanceDate.length >= 7 &&
                                e.attendanceDate.substring(0, 4) == yearStr &&
                                e.attendanceDate.substring(5, 7) == monthStr,
                          )
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
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.grey[100],
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                tgl,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                namaBulan,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
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
                                      // fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 8),
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
                                      // fontWeight: FontWeight.bold,
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
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                  : null,
                        ),
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
