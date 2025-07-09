import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onepresence/model/absen_status_model.dart';

Future<AbsenStatusResponse> fetchAbsenStatusToday(String token) async {
  final uri = Uri.parse('https://appabsensi.mobileprojp.com/api/absen/today');
  final response = await http.get(
    uri,
    headers: {'Authorization': 'Bearer $token'},
  );
  if (response.statusCode == 200) {
    return AbsenStatusResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Gagal mengambil status absen hari ini: ${response.body}');
  }
}
