class AbsenTodayResponse {
  final String message;
  final AbsenTodayData? data;

  AbsenTodayResponse({required this.message, this.data});

  factory AbsenTodayResponse.fromJson(Map<String, dynamic> json) =>
      AbsenTodayResponse(
        message: json['message'] ?? '',
        data:
            json['data'] != null ? AbsenTodayData.fromJson(json['data']) : null,
      );
}

class AbsenTodayData {
  final String tanggal;
  final String jamMasuk;
  final String jamKeluar;
  final String alamatMasuk;
  final String alamatKeluar;
  final String status;
  final String? alasanIzin;

  AbsenTodayData({
    required this.tanggal,
    required this.jamMasuk,
    required this.jamKeluar,
    required this.alamatMasuk,
    required this.alamatKeluar,
    required this.status,
    this.alasanIzin,
  });

  factory AbsenTodayData.fromJson(Map<String, dynamic> json) => AbsenTodayData(
    tanggal: json['tanggal'] ?? '',
    jamMasuk: json['jam_masuk'] ?? '',
    jamKeluar: json['jam_keluar'] ?? '',
    alamatMasuk: json['alamat_masuk'] ?? '',
    alamatKeluar: json['alamat_keluar'] ?? '',
    status: json['status'] ?? '',
    alasanIzin: json['alasan_izin'],
  );
}
