class AbsenCheckOutResponse {
  final String message;
  final AbsenCheckOutData data;

  AbsenCheckOutResponse({required this.message, required this.data});

  factory AbsenCheckOutResponse.fromJson(Map<String, dynamic> json) {
    return AbsenCheckOutResponse(
      message: json['message'],
      data: AbsenCheckOutData.fromJson(json['data']),
    );
  }
}

class AbsenCheckOutData {
  final int id;
  final String attendanceDate;
  final String checkInTime;
  final String checkOutTime;
  final String checkInAddress;
  final String checkOutAddress;
  final String checkInLocation;
  final String checkOutLocation;
  final String status;
  final String? alasanIzin;

  AbsenCheckOutData({
    required this.id,
    required this.attendanceDate,
    required this.checkInTime,
    required this.checkOutTime,
    required this.checkInAddress,
    required this.checkOutAddress,
    required this.checkInLocation,
    required this.checkOutLocation,
    required this.status,
    this.alasanIzin,
  });

  factory AbsenCheckOutData.fromJson(Map<String, dynamic> json) {
    return AbsenCheckOutData(
      id: json['id'],
      attendanceDate: json['attendance_date'],
      checkInTime: json['check_in_time'],
      checkOutTime: json['check_out_time'],
      checkInAddress: json['check_in_address'],
      checkOutAddress: json['check_out_address'],
      checkInLocation: json['check_in_location'],
      checkOutLocation: json['check_out_location'],
      status: json['status'],
      alasanIzin: json['alasan_izin'],
    );
  }
}
