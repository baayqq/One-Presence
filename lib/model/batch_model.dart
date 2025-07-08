class TrainingInBatch {
  final int id;
  final String title;

  TrainingInBatch({required this.id, required this.title});

  factory TrainingInBatch.fromJson(Map<String, dynamic> json) {
    return TrainingInBatch(id: json['id'], title: json['title']);
  }
}

class Batch {
  final int id;
  final String batchKe;
  final String startDate;
  final String endDate;
  final List<TrainingInBatch> trainings;

  Batch({
    required this.id,
    required this.batchKe,
    required this.startDate,
    required this.endDate,
    required this.trainings,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'],
      batchKe: json['batch_ke'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      trainings:
          (json['trainings'] as List)
              .map((t) => TrainingInBatch.fromJson(t))
              .toList(),
    );
  }
}

class BatchListResponse {
  final String message;
  final List<Batch> data;

  BatchListResponse({required this.message, required this.data});

  factory BatchListResponse.fromJson(Map<String, dynamic> json) {
    return BatchListResponse(
      message: json['message'],
      data: (json['data'] as List).map((item) => Batch.fromJson(item)).toList(),
    );
  }
}
