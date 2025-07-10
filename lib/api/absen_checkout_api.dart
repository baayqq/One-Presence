import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onepresence/model/absen_checkout_response_model.dart';
import 'package:intl/intl.dart';

Future<AbsenCheckOutResponse> absenCheckOut({
  required String token,
  required double lat,
  required double lng,
  required String address,
}) async {
  final now = DateTime.now();
  final dateStr = DateFormat('yyyy-MM-dd', 'id_ID').format(now);
  final timeStr = DateFormat('HH:mm', 'id_ID').format(now);
  final locationStr = '$lat,$lng';
  final uri = Uri.parse(
    'https://appabsensi.mobileprojp.com/api/absen/check-out',
  );
  var request =
      http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json'
        ..fields['attendance_date'] = dateStr
        ..fields['check_out'] = timeStr
        ..fields['check_out_lat'] = lat.toString()
        ..fields['check_out_lng'] = lng.toString()
        ..fields['check_out_location'] = locationStr
        ..fields['check_out_address'] = address;

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    return AbsenCheckOutResponse.fromJson(jsonDecode(response.body));
  } else {
    try {
      final body = jsonDecode(response.body);
      final message = body['message'] ?? 'Gagal check-out';
      throw Exception(message);
    } catch (_) {
      throw Exception('Gagal check-out: ${response.body}');
    }
  }
}
