import 'dart:convert';

CheckOutModel checkOutModelFromJson(String str) =>
    CheckOutModel.fromJson(json.decode(str));

String checkOutModelToJson(CheckOutModel data) => json.encode(data.toJson());

class CheckOutModel {
  DateTime? attendanceDate;
  String? checkOut;
  String? checkOutTime;
  String? checkOutLocation;
  double? checkOutLat;
  double? checkOutLng;
  String? checkOutAddress;
  String? status;

  CheckOutModel({
    this.attendanceDate,
    this.checkOut,
    this.checkOutTime,
    this.checkOutLocation,
    this.checkOutLat,
    this.checkOutLng,
    this.checkOutAddress,
    this.status,
  });

  CheckOutModel copyWith({
    DateTime? attendanceDate,
    String? checkOut,
    String? checkOutTime,
    String? checkOutLocation,
    double? checkOutLat,
    double? checkOutLng,
    String? checkOutAddress,
    String? status,
  }) => CheckOutModel(
    attendanceDate: attendanceDate ?? this.attendanceDate,
    checkOut: checkOut ?? this.checkOut,
    checkOutTime: checkOutTime ?? this.checkOutTime,
    checkOutLocation: checkOutLocation ?? this.checkOutLocation,
    checkOutLat: checkOutLat ?? this.checkOutLat,
    checkOutLng: checkOutLng ?? this.checkOutLng,
    checkOutAddress: checkOutAddress ?? this.checkOutAddress,
    status: status ?? this.status,
  );

  factory CheckOutModel.fromJson(Map<String, dynamic> json) => CheckOutModel(
    attendanceDate: json["attendance_date"] == null
        ? null
        : DateTime.parse(json["attendance_date"]),
    checkOut: json["check_out"] ?? json["check_out_time"],
    checkOutTime: json["check_out_time"] ?? json["check_out"],
    checkOutLocation:
        json["check_out_location"] ??
        ((json["check_out_lat"] != null && json["check_out_lng"] != null)
            ? "${json["check_out_lat"]},${json["check_out_lng"]}"
            : null),
    checkOutLat: json["check_out_lat"]?.toDouble(),
    checkOutLng: json["check_out_lng"]?.toDouble(),
    checkOutAddress: json["check_out_address"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "attendance_date": attendanceDate == null
        ? null
        : "${attendanceDate!.year.toString().padLeft(4, '0')}-${attendanceDate!.month.toString().padLeft(2, '0')}-${attendanceDate!.day.toString().padLeft(2, '0')}",
    "check_out": checkOutTime ?? checkOut,
    "check_out_time": checkOutTime ?? checkOut,
    "check_out_location":
        checkOutLocation ??
        ((checkOutLat != null && checkOutLng != null)
            ? "$checkOutLat,$checkOutLng"
            : null),
    "check_out_lat": checkOutLat,
    "check_out_lng": checkOutLng,
    "check_out_address": checkOutAddress,
    "status": status,
  };
}
