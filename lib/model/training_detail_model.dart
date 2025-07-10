class TrainingDetailResponse {
  final String message;
  final TrainingDetailData? data;

  TrainingDetailResponse({required this.message, this.data});

  factory TrainingDetailResponse.fromJson(Map<String, dynamic> json) {
    return TrainingDetailResponse(
      message: json['message'],
      data:
          json['data'] != null
              ? TrainingDetailData.fromJson(json['data'])
              : null,
    );
  }
}

class TrainingDetailData {
  final int id;
  final String title;
  final String? description;
  final int? participantCount;
  final String? standard;
  final String? duration;
  final String? createdAt;
  final String? updatedAt;
  final List<dynamic>? units;
  final List<dynamic>? activities;

  TrainingDetailData({
    required this.id,
    required this.title,
    this.description,
    this.participantCount,
    this.standard,
    this.duration,
    this.createdAt,
    this.updatedAt,
    this.units,
    this.activities,
  });

  factory TrainingDetailData.fromJson(Map<String, dynamic> json) {
    return TrainingDetailData(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      participantCount: json['participant_count'],
      standard: json['standard'],
      duration: json['duration'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      units: json['units'],
      activities: json['activities'],
    );
  }
}
