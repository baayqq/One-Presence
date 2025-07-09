class AbsenCheckoutResponse {
  final String message;
  final AbsenCheckoutData data;

  AbsenCheckoutResponse({required this.message, required this.data});

  factory AbsenCheckoutResponse.fromJson(Map<String, dynamic> json) =>
      AbsenCheckoutResponse(
        message: json['message'] ?? '',
        data: AbsenCheckoutData.fromJson(json['data']),
      );
}

class AbsenCheckoutData {
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
  final double checkInLat;
  final double checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;

  AbsenCheckoutData({
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
    required this.checkInLat,
    required this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
  });

  factory AbsenCheckoutData.fromJson(Map<String, dynamic> json) =>
      AbsenCheckoutData(
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
        checkInLat: (json['check_in_lat'] as num).toDouble(),
        checkInLng: (json['check_in_lng'] as num).toDouble(),
        checkOutLat:
            json['check_out_lat'] != null
                ? (json['check_out_lat'] as num).toDouble()
                : null,
        checkOutLng:
            json['check_out_lng'] != null
                ? (json['check_out_lng'] as num).toDouble()
                : null,
      );
}
