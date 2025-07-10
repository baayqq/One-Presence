class AbsenCheckInResponse {
  final String message;
  final AbsenCheckInData data;

  AbsenCheckInResponse({required this.message, required this.data});

  factory AbsenCheckInResponse.fromJson(Map<String, dynamic> json) {
    return AbsenCheckInResponse(
      message: json['message'],
      data: AbsenCheckInData.fromJson(json['data']),
    );
  }
}

class AbsenCheckInData {
  final int id;
  final String attendanceDate;
  final String checkInTime;
  final double checkInLat;
  final double checkInLng;
  final String checkInLocation;
  final String checkInAddress;
  final String status;
  final String? alasanIzin;

  AbsenCheckInData({
    required this.id,
    required this.attendanceDate,
    required this.checkInTime,
    required this.checkInLat,
    required this.checkInLng,
    required this.checkInLocation,
    required this.checkInAddress,
    required this.status,
    this.alasanIzin,
  });

  factory AbsenCheckInData.fromJson(Map<String, dynamic> json) {
    return AbsenCheckInData(
      id: json['id'],
      attendanceDate: json['attendance_date'],
      checkInTime: json['check_in_time'],
      checkInLat: (json['check_in_lat'] as num).toDouble(),
      checkInLng: (json['check_in_lng'] as num).toDouble(),
      checkInLocation: json['check_in_location'],
      checkInAddress: json['check_in_address'],
      status: json['status'],
      alasanIzin: json['alasan_izin'],
    );
  }
}
