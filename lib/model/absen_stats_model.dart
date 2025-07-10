class AbsenStatsResponse {
  final String message;
  final AbsenStatsData data;

  AbsenStatsResponse({required this.message, required this.data});

  factory AbsenStatsResponse.fromJson(Map<String, dynamic> json) {
    return AbsenStatsResponse(
      message: json['message'] ?? '',
      data: AbsenStatsData.fromJson(json['data'] ?? {}),
    );
  }
}

class AbsenStatsData {
  final int totalAbsen;
  final int totalMasuk;
  final int totalIzin;
  final bool sudahAbsenHariIni;

  AbsenStatsData({
    required this.totalAbsen,
    required this.totalMasuk,
    required this.totalIzin,
    required this.sudahAbsenHariIni,
  });

  factory AbsenStatsData.fromJson(Map<String, dynamic> json) {
    return AbsenStatsData(
      totalAbsen: json['total_absen'] ?? 0,
      totalMasuk: json['total_masuk'] ?? 0,
      totalIzin: json['total_izin'] ?? 0,
      sudahAbsenHariIni: json['sudah_absen_hari_ini'] ?? false,
    );
  }
}
