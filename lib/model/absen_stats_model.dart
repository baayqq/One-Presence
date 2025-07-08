class AbsenStatsResponse {
  final String message;
  final AbsenStatsData? data;

  AbsenStatsResponse({required this.message, this.data});

  factory AbsenStatsResponse.fromJson(Map<String, dynamic> json) =>
      AbsenStatsResponse(
        message: json['message'] ?? '',
        data:
            json['data'] == null ? null : AbsenStatsData.fromJson(json['data']),
      );
}

class AbsenStatsData {
  final int totalHadir;
  final int totalIzin;
  final int totalAlpha;
  final int totalTelat;

  AbsenStatsData({
    required this.totalHadir,
    required this.totalIzin,
    required this.totalAlpha,
    required this.totalTelat,
  });

  factory AbsenStatsData.fromJson(Map<String, dynamic> json) => AbsenStatsData(
    totalHadir: json['total_hadir'] ?? 0,
    totalIzin: json['total_izin'] ?? 0,
    totalAlpha: json['total_alpha'] ?? 0,
    totalTelat: json['total_telat'] ?? 0,
  );
}
