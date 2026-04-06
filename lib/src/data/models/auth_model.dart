// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String? message;
  Data? data;

  UserModel({this.message, this.data});

  UserModel copyWith({String? message, Data? data}) =>
      UserModel(message: message ?? this.message, data: data ?? this.data);

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class Data {
  String? token;
  User? user;

  Data({this.token, this.user});

  Data copyWith({String? token, User? user}) =>
      Data(token: token ?? this.token, user: user ?? this.user);

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    token: json["token"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {"token": token, "user": user?.toJson()};
}

class User {
  int? id;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  String? createdAt;
  String? updatedAt;
  String? batchId;
  String? trainingId;
  String? jenisKelamin;
  String? profilePhoto;
  String? onesignalPlayerId;
  Batch? batch;
  Training? training;

  User({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.batchId,
    this.trainingId,
    this.jenisKelamin,
    this.profilePhoto,
    this.onesignalPlayerId,
    this.batch,
    this.training,
  });

  User copyWith({
    int? id,
    String? name,
    String? email,
    dynamic emailVerifiedAt,
    String? createdAt,
    String? updatedAt,
    String? batchId,
    String? trainingId,
    String? jenisKelamin,
    String? profilePhoto,
    String? onesignalPlayerId,
    Batch? batch,
    Training? training,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    batchId: batchId ?? this.batchId,
    trainingId: trainingId ?? this.trainingId,
    jenisKelamin: jenisKelamin ?? this.jenisKelamin,
    profilePhoto: profilePhoto ?? this.profilePhoto,
    onesignalPlayerId: onesignalPlayerId ?? this.onesignalPlayerId,
    batch: batch ?? this.batch,
    training: training ?? this.training,
  );

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    emailVerifiedAt: json["email_verified_at"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    batchId: json["batch_id"],
    trainingId: json["training_id"],
    jenisKelamin: json["jenis_kelamin"],
    profilePhoto: json["profile_photo"],
    onesignalPlayerId: json["onesignal_player_id"],
    batch: json["batch"] == null ? null : Batch.fromJson(json["batch"]),
    training: json["training"] == null
        ? null
        : Training.fromJson(json["training"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "batch_id": batchId,
    "training_id": trainingId,
    "jenis_kelamin": jenisKelamin,
    "profile_photo": profilePhoto,
    "onesignal_player_id": onesignalPlayerId,
    "batch": batch?.toJson(),
    "training": training?.toJson(),
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
