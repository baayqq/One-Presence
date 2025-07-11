class IzinAbsenResponse {
  final String message;
  final IzinAbsenData data;

  IzinAbsenResponse({required this.message, required this.data});

  factory IzinAbsenResponse.fromJson(Map<String, dynamic> json) =>
      IzinAbsenResponse(
        message: json['message'] ?? '',
        data: IzinAbsenData.fromJson(json['data']),
      );
}

class IzinAbsenData {
  final int id;
  final String attendanceDate;
  final String? checkInTime;
  final double? checkInLat;
  final double? checkInLng;
  final String? checkInLocation;
  final String? checkInAddress;
  final String status;
  final String alasanIzin;

  IzinAbsenData({
    required this.id,
    required this.attendanceDate,
    this.checkInTime,
    this.checkInLat,
    this.checkInLng,
    this.checkInLocation,
    this.checkInAddress,
    required this.status,
    required this.alasanIzin,
  });

  factory IzinAbsenData.fromJson(Map<String, dynamic> json) => IzinAbsenData(
    id: json['id'],
    attendanceDate: json['attendance_date'] ?? '',
    checkInTime: json['check_in_time'],
    checkInLat:
        json['check_in_lat'] != null
            ? (json['check_in_lat'] as num).toDouble()
            : null,
    checkInLng:
        json['check_in_lng'] != null
            ? (json['check_in_lng'] as num).toDouble()
            : null,
    checkInLocation: json['check_in_location'],
    checkInAddress: json['check_in_address'],
    status: json['status'] ?? '',
    alasanIzin: json['alasan_izin'] ?? '',
  );
}
