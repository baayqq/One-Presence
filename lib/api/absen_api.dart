import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onepresence/model/absen_today_model.dart';
import 'package:onepresence/model/absen_checkin_response_model.dart';
import 'package:onepresence/model/training_detail_model.dart';
import 'package:onepresence/api/api_file.dart';

// Fungsi untuk mengambil data absen hari ini
Future<AbsenTodayResponse> fetchAbsenToday(String token) async {
  final uri = Uri.parse('https://appabsensi.mobileprojp.com/api/absen/today');
  final response = await http.get(
    uri,
    headers: {'Authorization': 'Bearer $token'},
  );
  if (response.statusCode == 200) {
    return AbsenTodayResponse.fromJson(jsonDecode(response.body));
  } else {
    final body = jsonDecode(response.body);
    final message = body['message'] ?? 'Gagal mengambil data absensi hari ini';
    throw Exception(message);
  }
}

// Fungsi untuk absen check-in
Future<AbsenCheckInResponse> absenCheckIn({
  required String token,
  required double lat,
  required double lng,
  required String address,
}) async {
  final uri = Uri.parse(
    'https://appabsensi.mobileprojp.com/api/absen/check-in',
  );
  var request =
      http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json'
        ..fields['check_in_lat'] = lat.toString()
        ..fields['check_in_lng'] = lng.toString()
        ..fields['check_in_address'] = address;

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    return AbsenCheckInResponse.fromJson(jsonDecode(response.body));
  } else {
    try {
      final body = jsonDecode(response.body);
      final message = body['message'] ?? 'Gagal check-in';
      throw Exception(message);
    } catch (_) {
      throw Exception('Gagal check-in: ${response.body}');
    }
  }
}

Future<TrainingDetailResponse> fetchTrainingDetail(int id) async {
  final response = await http.get(
    Uri.parse(trainingDetailUrl(id)),
    headers: {'Accept': 'application/json'},
  );
  if (response.statusCode == 200) {
    return TrainingDetailResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Gagal mengambil detail training: ${response.body}');
  }
}
