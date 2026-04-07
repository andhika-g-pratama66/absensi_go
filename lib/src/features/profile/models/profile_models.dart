// To parse this JSON data, do
//
//     final profileModel = profileModelFromJson(jsonString);

import 'dart:convert';

ProfileModel profileModelFromJson(String str) =>
    ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
  String? message;
  Data? data;

  ProfileModel({this.message, this.data});

  ProfileModel copyWith({String? message, Data? data}) =>
      ProfileModel(message: message ?? this.message, data: data ?? this.data);

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class Data {
  int? id;
  String? name;
  String? email;
  String? batchKe;
  String? trainingTitle;
  Batch? batch;
  Training? training;
  String? jenisKelamin;
  dynamic profilePhoto;
  dynamic profilePhotoUrl;

  Data({
    this.id,
    this.name,
    this.email,
    this.batchKe,
    this.trainingTitle,
    this.batch,
    this.training,
    this.jenisKelamin,
    this.profilePhoto,
    this.profilePhotoUrl,
  });

  Data copyWith({
    int? id,
    String? name,
    String? email,
    String? batchKe,
    String? trainingTitle,
    Batch? batch,
    Training? training,
    String? jenisKelamin,
    dynamic profilePhoto,
    dynamic profilePhotoUrl,
  }) => Data(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    batchKe: batchKe ?? this.batchKe,
    trainingTitle: trainingTitle ?? this.trainingTitle,
    batch: batch ?? this.batch,
    training: training ?? this.training,
    jenisKelamin: jenisKelamin ?? this.jenisKelamin,
    profilePhoto: profilePhoto ?? this.profilePhoto,
    profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    batchKe: json["batch_ke"],
    trainingTitle: json["training_title"],
    batch: json["batch"] == null ? null : Batch.fromJson(json["batch"]),
    training: json["training"] == null
        ? null
        : Training.fromJson(json["training"]),
    jenisKelamin: json["jenis_kelamin"],
    profilePhoto: json["profile_photo"],
    profilePhotoUrl: json["profile_photo_url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "batch_ke": batchKe,
    "training_title": trainingTitle,
    "batch": batch?.toJson(),
    "training": training?.toJson(),
    "jenis_kelamin": jenisKelamin,
    "profile_photo": profilePhoto,
    "profile_photo_url": profilePhotoUrl,
  };
}

class Batch {
  int? id;
  String? batchKe;
  DateTime? startDate;
  DateTime? endDate;
  String? createdAt;
  String? updatedAt;

  Batch({
    this.id,
    this.batchKe,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  Batch copyWith({
    int? id,
    String? batchKe,
    DateTime? startDate,
    DateTime? endDate,
    String? createdAt,
    String? updatedAt,
  }) => Batch(
    id: id ?? this.id,
    batchKe: batchKe ?? this.batchKe,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory Batch.fromJson(Map<String, dynamic> json) => Batch(
    id: json["id"],
    batchKe: json["batch_ke"],
    startDate: json["start_date"] == null
        ? null
        : DateTime.parse(json["start_date"]),
    endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
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
  };
}

class Training {
  int? id;
  String? title;
  dynamic description;
  dynamic participantCount;
  dynamic standard;
  dynamic duration;
  String? createdAt;
  String? updatedAt;

  Training({
    this.id,
    this.title,
    this.description,
    this.participantCount,
    this.standard,
    this.duration,
    this.createdAt,
    this.updatedAt,
  });

  Training copyWith({
    int? id,
    String? title,
    dynamic description,
    dynamic participantCount,
    dynamic standard,
    dynamic duration,
    String? createdAt,
    String? updatedAt,
  }) => Training(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    participantCount: participantCount ?? this.participantCount,
    standard: standard ?? this.standard,
    duration: duration ?? this.duration,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory Training.fromJson(Map<String, dynamic> json) => Training(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    participantCount: json["participant_count"],
    standard: json["standard"],
    duration: json["duration"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "participant_count": participantCount,
    "standard": standard,
    "duration": duration,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
