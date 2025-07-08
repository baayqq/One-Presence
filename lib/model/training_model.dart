class Training {
  final int id;
  final String title;

  Training({required this.id, required this.title});

  factory Training.fromJson(Map<String, dynamic> json) {
    return Training(id: json['id'], title: json['title']);
  }
}

class TrainingListResponse {
  final String message;
  final List<Training> data;

  TrainingListResponse({required this.message, required this.data});

  factory TrainingListResponse.fromJson(Map<String, dynamic> json) {
    return TrainingListResponse(
      message: json['message'],
      data:
          (json['data'] as List)
              .map((item) => Training.fromJson(item))
              .toList(),
    );
  }
}
