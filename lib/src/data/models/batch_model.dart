// To parse this JSON data, do
//
//     final batchModel = batchModelFromJson(jsonString);

import 'dart:convert';

BatchModel batchModelFromJson(String str) =>
    BatchModel.fromJson(json.decode(str));

String batchModelToJson(BatchModel data) => json.encode(data.toJson());

class BatchModel {
  String? message;
  List<Datum>? data;

  BatchModel({this.message, this.data});

  BatchModel copyWith({String? message, List<Datum>? data}) =>
      BatchModel(message: message ?? this.message, data: data ?? this.data);

  factory BatchModel.fromJson(Map<String, dynamic> json) => BatchModel(
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
  String? batchKe;
  DateTime? startDate;
  DateTime? endDate;
  String? createdAt;
  String? updatedAt;
  List<Training>? trainings;

  Datum({
    this.id,
    this.batchKe,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    this.trainings,
  });

  Datum copyWith({
    int? id,
    String? batchKe,
    DateTime? startDate,
    DateTime? endDate,
    String? createdAt,
    String? updatedAt,
    List<Training>? trainings,
  }) => Datum(
    id: id ?? this.id,
    batchKe: batchKe ?? this.batchKe,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    trainings: trainings ?? this.trainings,
  );

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    batchKe: json["batch_ke"],
    startDate: json["start_date"] == null
        ? null
        : DateTime.parse(json["start_date"]),
    endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    trainings: json["trainings"] == null
        ? []
        : List<Training>.from(
            json["trainings"]!.map((x) => Training.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "batch_ke": batchKe,
    "start_date":
        "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
    "end_date":
        "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
    "created_at": createdAt,
    "updated_at": updatedAt,
    "trainings": trainings == null
        ? []
        : List<dynamic>.from(trainings!.map((x) => x.toJson())),
  };
}

class Training {
  int? id;
  String? title;
  Pivot? pivot;

  Training({this.id, this.title, this.pivot});

  Training copyWith({int? id, String? title, Pivot? pivot}) => Training(
    id: id ?? this.id,
    title: title ?? this.title,
    pivot: pivot ?? this.pivot,
  );

  factory Training.fromJson(Map<String, dynamic> json) => Training(
    id: json["id"],
    title: json["title"],
    pivot: json["pivot"] == null ? null : Pivot.fromJson(json["pivot"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "pivot": pivot?.toJson(),
  };
}

class Pivot {
  String? trainingBatchId;
  String? trainingId;

  Pivot({this.trainingBatchId, this.trainingId});

  Pivot copyWith({String? trainingBatchId, String? trainingId}) => Pivot(
    trainingBatchId: trainingBatchId ?? this.trainingBatchId,
    trainingId: trainingId ?? this.trainingId,
  );

  factory Pivot.fromJson(Map<String, dynamic> json) => Pivot(
    trainingBatchId: json["training_batch_id"],
    trainingId: json["training_id"],
  );

  Map<String, dynamic> toJson() => {
    "training_batch_id": trainingBatchId,
    "training_id": trainingId,
  };
}
