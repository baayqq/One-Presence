class RegisterError {
  final String message;
  final Map<String, List<String>> errors;

  RegisterError({required this.message, required this.errors});

  factory RegisterError.fromJson(Map<String, dynamic> json) {
    final errors = <String, List<String>>{};
    if (json['errors'] != null) {
      json['errors'].forEach((key, value) {
        errors[key] = List<String>.from(value);
      });
    }
    return RegisterError(message: json['message'] ?? '', errors: errors);
  }
}
