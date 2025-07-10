import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onepresence/model/model_absen.dart';
import 'package:intl/intl.dart';

Future<Absen> getAbsenToday(String token, DateTime attendanceDate) async {
  final dateStr = DateFormat('yyyy-MM-dd', 'id_ID').format(attendanceDate);
  final uri = Uri.parse(
    'https://appabsensi.mobileprojp.com/api/absen/today?attendance_date=$dateStr',
  );
  final response = await http.get(
    uri,
    headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
  );
  if (response.statusCode == 200) {
    return absenFromJson(response.body);
  } else {
    throw Exception('Gagal mengambil data absen: ${response.body}');
  }
}
