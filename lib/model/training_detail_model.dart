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
  final String description;
  final String startDate;
  final String endDate;
  final String location;
  final String mentor;

  TrainingDetailData({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.mentor,
  });

  factory TrainingDetailData.fromJson(Map<String, dynamic> json) {
    return TrainingDetailData(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      location: json['location'],
      mentor: json['mentor'],
    );
  }
}
