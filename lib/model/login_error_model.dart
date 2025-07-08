class LoginError {
  final String message;
  final dynamic data;

  LoginError({required this.message, this.data});

  factory LoginError.fromJson(Map<String, dynamic> json) =>
      LoginError(message: json['message'] ?? '', data: json['data']);
}
