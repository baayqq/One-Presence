class AbsenHistoryResponse {
  final String message;
  final List<AbsenHistoryData> data;

  AbsenHistoryResponse({required this.message, required this.data});

  factory AbsenHistoryResponse.fromJson(Map<String, dynamic> json) =>
      AbsenHistoryResponse(
        message: json['message'] ?? '',
        data:
            json['data'] != null
                ? List<AbsenHistoryData>.from(
                  (json['data'] as List).map(
                    (x) => AbsenHistoryData.fromJson(x),
                  ),
                )
                : [],
      );
}

class AbsenHistoryData {
  final int id;
  final int userId;
  final String checkIn;
  final String checkInLocation;
  final String checkInAddress;
  final String? checkOut;
  final String? checkOutLocation;
  final String? checkOutAddress;
  final String status;
  final String? alasanIzin;
  final String createdAt;
  final String updatedAt;

  AbsenHistoryData({
    required this.id,
    required this.userId,
    required this.checkIn,
    required this.checkInLocation,
    required this.checkInAddress,
    this.checkOut,
    this.checkOutLocation,
    this.checkOutAddress,
    required this.status,
    this.alasanIzin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AbsenHistoryData.fromJson(Map<String, dynamic> json) =>
      AbsenHistoryData(
        id: json['id'],
        userId:
            json['user_id'] is int
                ? json['user_id']
                : int.tryParse(json['user_id'].toString()) ?? 0,
        checkIn: json['check_in'] ?? '',
        checkInLocation: json['check_in_location'] ?? '',
        checkInAddress: json['check_in_address'] ?? '',
        checkOut: json['check_out'],
        checkOutLocation: json['check_out_location'],
        checkOutAddress: json['check_out_address'],
        status: json['status'] ?? '',
        alasanIzin: json['alasan_izin'],
        createdAt: json['created_at'] ?? '',
        updatedAt: json['updated_at'] ?? '',
      );
}
