import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onepresence/model/absen_stats_model.dart';

Future<AbsenStatsResponse> fetchAbsenStats(String token) async {
  final uri = Uri.parse('https://appabsensi.mobileprojp.com/api/absen/stats');
  final response = await http.get(
    uri,
    headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
  );
  if (response.statusCode == 200) {
    return AbsenStatsResponse.fromJson(jsonDecode(response.body));
  } else {
    final body = jsonDecode(response.body);
    final message = body['message'] ?? 'Gagal mengambil statistik absensi';
    throw Exception(message);
  }
}
