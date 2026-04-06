// To parse this JSON data, do
//
//     final checkInModel = checkInModelFromJson(jsonString);

import 'dart:convert';

CheckInModel checkInModelFromJson(String str) =>
    CheckInModel.fromJson(json.decode(str));

String checkInModelToJson(CheckInModel data) => json.encode(data.toJson());

class CheckInModel {
  DateTime? attendanceDate;
  String? checkIn;
  double? checkInLat;
  double? checkInLng;
  String? checkInAddress;
  String? status;
  String? alasanIzin;

  CheckInModel({
    this.attendanceDate,
    this.checkIn,
    this.checkInLat,
    this.checkInLng,
    this.checkInAddress,
    this.status,
    this.alasanIzin,
  });

  CheckInModel copyWith({
    DateTime? attendanceDate,
    String? checkIn,
    double? checkInLat,
    double? checkInLng,
    String? checkInAddress,
    String? status,
    String? alasanIzin,
  }) => CheckInModel(
    attendanceDate: attendanceDate ?? this.attendanceDate,
    checkIn: checkIn ?? this.checkIn,
    checkInLat: checkInLat ?? this.checkInLat,
    checkInLng: checkInLng ?? this.checkInLng,
    checkInAddress: checkInAddress ?? this.checkInAddress,
    status: status ?? this.status,
    alasanIzin: alasanIzin ?? this.alasanIzin,
  );

  factory CheckInModel.fromJson(Map<String, dynamic> json) => CheckInModel(
    attendanceDate: json["attendance_date"] == null
        ? null
        : DateTime.parse(json["attendance_date"]),
    checkIn: json["check_in"],
    checkInLat: json["check_in_lat"]?.toDouble(),
    checkInLng: json["check_in_lng"]?.toDouble(),
    checkInAddress: json["check_in_address"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
  );

  Map<String, dynamic> toJson() => {
    "attendance_date":
        "${attendanceDate!.year.toString().padLeft(4, '0')}-${attendanceDate!.month.toString().padLeft(2, '0')}-${attendanceDate!.day.toString().padLeft(2, '0')}",
    "check_in": checkIn,
    "check_in_lat": checkInLat,
    "check_in_lng": checkInLng,
    "check_in_address": checkInAddress,
    "status": status,
    "alasan_izin": alasanIzin,
  };
}
