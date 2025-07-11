import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onepresence/api/endpoint.dart';
import 'package:onepresence/model/registmodel.dart';
import 'package:onepresence/model/training_model.dart' as trainingModel;
import 'package:onepresence/model/register_error_model.dart';
import 'package:onepresence/model/batch_model.dart' as batchModel;
import 'package:onepresence/model/login_model.dart';
import 'package:onepresence/model/login_error_model.dart';
import 'package:onepresence/model/profile_model.dart';
import 'dart:io';
import 'package:onepresence/model/izin_absen_model.dart';

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
      final error = RegisterError.fromJson(jsonDecode(response.body));
      return {'message': error.message, 'errors': error.errors};
    } else {
      throw Exception('Gagal mendaftar akun. [${response.statusCode}]');
    }
  }

  Future<List<trainingModel.Training>> getTrainings() async {
    final response = await http.get(
      Uri.parse('https://appabsensi.mobileprojp.com/api/trainings'),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final listResponse = trainingModel.TrainingListResponse.fromJson(
        jsonData,
      );
      return listResponse.data;
    } else {
      throw Exception('Gagal mengambil data pelatihan');
    }
  }

  Future<List<batchModel.Batch>> getBatches() async {
    final response = await http.get(
      Uri.parse('https://appabsensi.mobileprojp.com/api/batches'),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final listResponse = batchModel.BatchListResponse.fromJson(jsonData);
      return listResponse.data;
    } else {
      throw Exception('Gagal mengambil data batch');
    }
  }

  Future<LoginResponse> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('https://appabsensi.mobileprojp.com/api/login'),
      headers: {'Accept': 'application/json'},
      body: {'email': email, 'password': password},
    );
    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      final error = LoginError.fromJson(jsonDecode(response.body));
      throw Exception(error.message);
    }
  }

  Future<ProfileResponse> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('https://appabsensi.mobileprojp.com/api/profile'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return ProfileResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal mengambil data profil. [${response.statusCode}]');
    }
  }

  Future<EditProfileResponse> editProfile(
    String token,
    String name,
    String email,
  ) async {
    final response = await http.put(
      Uri.parse('https://appabsensi.mobileprojp.com/api/profile'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: {'name': name, 'email': email},
    );
    if (response.statusCode == 200) {
      return EditProfileResponse.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 422) {
      return EditProfileResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal update profil. [${response.statusCode}]');
    }
  }

  Future<EditProfilePhotoResponse> editProfilePhoto(
    String token,
    String filePath,
  ) async {
    final bytes = await File(filePath).readAsBytes();
    final base64Image = 'data:image/png;base64,' + base64Encode(bytes);
    final uri = Uri.parse(
      'https://appabsensi.mobileprojp.com/api/profile/photo',
    );
    final response = await http.put(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'profile_photo': base64Image}),
    );
    if (response.statusCode == 200) {
      return EditProfilePhotoResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal update foto profil. [${response.statusCode}]');
    }
  }

  Future<IzinAbsenResponse> ajukanIzinAbsen({
    required String token,
    required String date, // yyyy-MM-dd
    required String alasanIzin,
  }) async {
    final response = await http.post(
      Uri.parse('https://appabsensi.mobileprojp.com/api/izin'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: {'date': date, 'alasan_izin': alasanIzin},
    );
    if (response.statusCode == 200) {
      return IzinAbsenResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal mengajukan izin: ${response.body}');
    }
  }
}

String baseUrl = 'https://appabsensi.mobileprojp.com/api';
String trainingDetailUrl(int id) => '$baseUrl/trainings/$id';
