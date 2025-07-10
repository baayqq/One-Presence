import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onepresence/model/absen_history_model.dart';

Future<AbsenHistoryResponse> fetchAbsenHistory(String token) async {
  final uri = Uri.parse('https://appabsensi.mobileprojp.com/api/absen/history');
  final response = await http.get(
    uri,
    headers: {'Authorization': 'Bearer $token'},
  );
  if (response.statusCode == 200) {
    return AbsenHistoryResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Gagal mengambil history absen: ${response.body}');
  }
}

Future<AbsenHistoryResponse> fetchAbsenHistoryNew(String token) async {
  final uri = Uri.parse('https://appabsensi.mobileprojp.com/api/absen/history');
  final response = await http.get(
    uri,
    headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
  );
  if (response.statusCode == 200) {
    return AbsenHistoryResponse.fromJson(jsonDecode(response.body));
  } else {
    final body = jsonDecode(response.body);
    final message = body['message'] ?? 'Gagal mengambil riwayat absensi';
    throw Exception(message);
  }
}
