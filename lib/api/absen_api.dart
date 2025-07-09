import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onepresence/model/absen_today_model.dart';

Future<AbsenTodayResponse> fetchAbsenToday(String token) async {
  final uri = Uri.parse('https://appabsensi.mobileprojp.com/api/absen/today');
  final response = await http.get(
    uri,
    headers: {'Authorization': 'Bearer $token'},
  );
  if (response.statusCode == 200) {
    return AbsenTodayResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Gagal mengambil data absensi hari ini: ${response.body}');
  }
}

Future<dynamic> absenCheckIn({
  required String token,
  required double lat,
  required double lng,
  required String address,
  required String imagePath,
}) async {
  final uri = Uri.parse(
    'https://appabsensi.mobileprojp.com/api/absen/check-in',
  );
  var request =
      http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['check_in_lat'] = lat.toString()
        ..fields['check_in_lng'] = lng.toString()
        ..fields['check_in_address'] = address;

  request.files.add(await http.MultipartFile.fromPath('photo', imagePath));

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Gagal check-in: ${response.body}');
  }
}
