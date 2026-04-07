// To parse this JSON data, do
//
//     final izinModel = izinModelFromJson(jsonString);

import 'dart:convert';

IzinModel izinModelFromJson(String str) => IzinModel.fromJson(json.decode(str));

String izinModelToJson(IzinModel data) => json.encode(data.toJson());

List<IzinModel> izinListFromJson(String str) =>
    List<IzinModel>.from(json.decode(str).map((x) => IzinModel.fromJson(x)));

String izinListToJson(List<IzinModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class IzinModel {
  int? id;
  DateTime? attendanceDate;
  String? checkInTime;
  double? checkInLat;
  double? checkInLng;
  String? checkInLocation;
  String? checkInAddress;
  String? status;
  String? alasanIzin;
  DateTime? createdAt;
  DateTime? updatedAt;

  IzinModel({
    this.id,
    this.attendanceDate,
    this.checkInTime,
    this.checkInLat,
    this.checkInLng,
    this.checkInLocation,
    this.checkInAddress,
    this.status,
    this.alasanIzin,
    this.createdAt,
    this.updatedAt,
  });

  IzinModel copyWith({
    int? id,
    DateTime? attendanceDate,
    String? checkInTime,
    double? checkInLat,
    double? checkInLng,
    String? checkInLocation,
    String? checkInAddress,
    String? status,
    String? alasanIzin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => IzinModel(
    id: id ?? this.id,
    attendanceDate: attendanceDate ?? this.attendanceDate,
    checkInTime: checkInTime ?? this.checkInTime,
    checkInLat: checkInLat ?? this.checkInLat,
    checkInLng: checkInLng ?? this.checkInLng,
    checkInLocation: checkInLocation ?? this.checkInLocation,
    checkInAddress: checkInAddress ?? this.checkInAddress,
    status: status ?? this.status,
    alasanIzin: alasanIzin ?? this.alasanIzin,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory IzinModel.fromJson(Map<String, dynamic> json) => IzinModel(
    id: json["id"],
    attendanceDate: json["attendance_date"] == null
        ? null
        : DateTime.parse(json["attendance_date"]),
    checkInTime: json["check_in_time"],
    checkInLat: json["check_in_lat"]?.toDouble(),
    checkInLng: json["check_in_lng"]?.toDouble(),
    checkInLocation: json["check_in_location"],
    checkInAddress: json["check_in_address"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "attendance_date": attendanceDate == null
        ? null
        : "${attendanceDate!.year.toString().padLeft(4, '0')}-${attendanceDate!.month.toString().padLeft(2, '0')}-${attendanceDate!.day.toString().padLeft(2, '0')}",
    "check_in_time": checkInTime,
    "check_in_lat": checkInLat,
    "check_in_lng": checkInLng,
    "check_in_location": checkInLocation,
    "check_in_address": checkInAddress,
    "status": status,
    "alasan_izin": alasanIzin,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };

  bool get isIzin => status == 'izin';
}
