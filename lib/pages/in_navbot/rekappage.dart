import 'package:flutter/material.dart';
import 'package:onepresence/api/api_file.dart';
import 'package:onepresence/model/absen_stats_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AbsenStatsResponse>(
      future: fetchStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Gagal memuat data: \\${snapshot.error}'));
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
}
