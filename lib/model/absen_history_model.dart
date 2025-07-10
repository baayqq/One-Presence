class AbsenHistoryResponse {
  final String message;
  final List<AbsenHistoryItem> data;

  AbsenHistoryResponse({required this.message, required this.data});

  factory AbsenHistoryResponse.fromJson(Map<String, dynamic> json) {
    return AbsenHistoryResponse(
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => AbsenHistoryItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AbsenHistoryItem {
  final int id;
  final String attendanceDate;
  final String? checkInTime;
  final String? checkOutTime;
  final double? checkInLat;
  final double? checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;
  final String? checkInAddress;
  final String? checkOutAddress;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String status;
  final String? alasanIzin;

  AbsenHistoryItem({
    required this.id,
    required this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
    this.checkInAddress,
    this.checkOutAddress,
    this.checkInLocation,
    this.checkOutLocation,
    required this.status,
    this.alasanIzin,
  });

  factory AbsenHistoryItem.fromJson(Map<String, dynamic> json) {
    return AbsenHistoryItem(
      id: json['id'],
      attendanceDate: json['attendance_date'] ?? '',
      checkInTime: json['check_in_time'],
      checkOutTime: json['check_out_time'],
      checkInLat:
          json['check_in_lat'] != null
              ? (json['check_in_lat'] as num).toDouble()
              : null,
      checkInLng:
          json['check_in_lng'] != null
              ? (json['check_in_lng'] as num).toDouble()
              : null,
      checkOutLat:
          json['check_out_lat'] != null
              ? (json['check_out_lat'] as num).toDouble()
              : null,
      checkOutLng:
          json['check_out_lng'] != null
              ? (json['check_out_lng'] as num).toDouble()
              : null,
      checkInAddress: json['check_in_address'],
      checkOutAddress: json['check_out_address'],
      checkInLocation: json['check_in_location'],
      checkOutLocation: json['check_out_location'],
      status: json['status'] ?? '',
      alasanIzin: json['alasan_izin'],
    );
  }
}
