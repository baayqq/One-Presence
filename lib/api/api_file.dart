import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onepresence/api/endpoint.dart';
import 'package:onepresence/model/registmodel.dart';

class UserService {
  Future<Map<String, dynamic>> registUser(
    String name,
    String email,
    String password,
    String gender,
    String batchId,
    String trainingId,
  ) async {
    final response = await http.post(
      Uri.parse(Endpoint.register),
      headers: {'Accept': 'application/json'},
      body: {
        'name': name,
        'email': email,
        'password': password,
        'jenis_kelamin': gender,
        'batch_id': batchId,
        'training_id': trainingId,
      },
    );

    if (response.statusCode == 200) {
      return registerModelFromJson(response.body).toJson();
    } else if (response.statusCode == 422) {
      return {'message': 'Validasi gagal', 'errors': jsonDecode(response.body)};
    } else {
      throw Exception('Gagal mendaftar akun. [${response.statusCode}]');
    }
  }
}
