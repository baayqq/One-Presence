// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class UserService{
//   // Future<Map<String, dynamic>> registUser(
//   //   String name,
//   //   String email,
//   //   String password,
//   // ) async {
//   //   final response = await http.post(
//   //     Uri.parse(Endpoint.register),
//   //     headers: {'Accept': 'application/json'},
//   //     body: {'name': name, 'email': email, 'password': password},
//   //   );

//   //   if (response.statusCode == 200) {
//   //     return registmodelFromJson(response.body).toJson();
//   //   } else if (response.statusCode == 422) {
//   //     return registErrorFromJson(response.body).toJson();
//   //   } else if (response.statusCode == 422) {
//   //     return registAlreadyFromJson(response.body).toJson();
//   //   } else {
//   //     throw Exception('Gagal Mendaftar Akun ${response.statusCode}');
//   //   }
//   // }

//   Future<Map<String, dynamic>> loginUser(
//     String name,
//     String email,
//     String password,
//   ) async {
//     final response = await http.post(
//       Uri.parse(Endpoint.login),
//       headers: {'Accept': 'application/json'},
//       body: {'name': name, 'email': email, 'password': password},
//     );

//     try {
//       final json = jsonDecode(response.body);
//       if (response.statusCode == 200) {
//         return loginmodelFromJson(response.body).toJson();
//       } else {
//         return {'message': json['message'] ?? 'Login gagal', 'error': true};
//       }
//     } catch (e) {
//       throw Exception('Gagal login. Kesalahan parsing atau server.');
//     }
//   }
// }