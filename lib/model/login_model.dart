class LoginResponse {
  final String message;
  final LoginData? data;

  LoginResponse({required this.message, this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    message: json['message'] ?? '',
    data: json['data'] == null ? null : LoginData.fromJson(json['data']),
  );
}

class LoginData {
  final String token;
  final LoginUser user;

  LoginData({required this.token, required this.user});

  factory LoginData.fromJson(Map<String, dynamic> json) =>
      LoginData(token: json['token'], user: LoginUser.fromJson(json['user']));
}

class LoginUser {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String createdAt;
  final String updatedAt;

  LoginUser({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoginUser.fromJson(Map<String, dynamic> json) => LoginUser(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    emailVerifiedAt: json['email_verified_at'],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
  );
}
