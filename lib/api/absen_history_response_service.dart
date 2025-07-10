import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onepresence/model/absen_history_response_model.dart';
import 'package:intl/intl.dart';

Future<AbsenHistoryResponse> getAbsenHistoryResponse(
  String token, {
  DateTime? date,
}) async {
  String url = 'https://appabsensi.mobileprojp.com/api/absen/history';
  if (date != null) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    url += '?attendance_date=$dateStr';
  }
  final uri = Uri.parse(url);
  final response = await http.get(
    uri,
    headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
  );
  if (response.statusCode == 200) {
    return AbsenHistoryResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Gagal mengambil history absen: ${response.body}');
  }
}
