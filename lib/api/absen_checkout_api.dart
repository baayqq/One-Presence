import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onepresence/model/absen_checkout_model.dart';

Future<AbsenCheckoutResponse> absenCheckOut({
  required String token,
  required double lat,
  required double lng,
  required String address,
}) async {
  final uri = Uri.parse(
    'https://appabsensi.mobileprojp.com/api/absen/check-out',
  );
  var request =
      http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['check_out_lat'] = lat.toString()
        ..fields['check_out_lng'] = lng.toString()
        ..fields['check_out_address'] = address;

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    return AbsenCheckoutResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Gagal check-out: ${response.body}');
  }
}
