import 'dart:convert';

AttendanceStatsModel attendanceStatsModelFromJson(String str) =>
    AttendanceStatsModel.fromJson(json.decode(str));

String attendanceStatsModelToJson(AttendanceStatsModel data) =>
    json.encode(data.toJson());

class AttendanceStatsModel {
  final String? message;
  final StatsData? data;

  AttendanceStatsModel({this.message, this.data});

  factory AttendanceStatsModel.fromJson(Map<String, dynamic> json) =>
      AttendanceStatsModel(
        message: json["message"],
        data: json["data"] == null ? null : StatsData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class StatsData {
  final int totalAbsen;
  final int totalMasuk;
  final int totalIzin;
  final bool sudahAbsenHariIni;

  StatsData({
    this.totalAbsen = 0,
    this.totalMasuk = 0,
    this.totalIzin = 0,
    this.sudahAbsenHariIni = false,
  });

  factory StatsData.fromJson(Map<String, dynamic> json) => StatsData(
        totalAbsen: json["total_absen"] ?? 0,
        totalMasuk: json["total_masuk"] ?? 0,
        totalIzin: json["total_izin"] ?? 0,
        sudahAbsenHariIni: json["sudah_absen_hari_ini"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "total_absen": totalAbsen,
        "total_masuk": totalMasuk,
        "total_izin": totalIzin,
        "sudah_absen_hari_ini": sudahAbsenHariIni,
      };
}
