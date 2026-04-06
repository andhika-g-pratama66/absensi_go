// To parse this JSON data, do
//
//     final trainingModel = trainingModelFromJson(jsonString);

import 'dart:convert';

TrainingModel trainingModelFromJson(String str) =>
    TrainingModel.fromJson(json.decode(str));

String trainingModelToJson(TrainingModel data) => json.encode(data.toJson());

class TrainingModel {
  String? message;
  List<Datum>? data;

  TrainingModel({this.message, this.data});

  TrainingModel copyWith({String? message, List<Datum>? data}) =>
      TrainingModel(message: message ?? this.message, data: data ?? this.data);

  factory TrainingModel.fromJson(Map<String, dynamic> json) => TrainingModel(
    message: json["message"],
    data: json["data"] == null
        ? []
        : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  int? id;
  String? title;

  Datum({this.id, this.title});

  Datum copyWith({int? id, String? title}) =>
      Datum(id: id ?? this.id, title: title ?? this.title);

  factory Datum.fromJson(Map<String, dynamic> json) =>
      Datum(id: json["id"], title: json["title"]);

  Map<String, dynamic> toJson() => {"id": id, "title": title};
}
