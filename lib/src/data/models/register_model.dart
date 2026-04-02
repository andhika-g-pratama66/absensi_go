import 'package:absensi_go/src/data/models/auth_model.dart';

class RegisterResponseModel {
  final String message;
  final UserModel data;

  RegisterResponseModel({required this.message, required this.data});

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      message: json['message'] ?? '',
      data: UserModel.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'data': data.toJson()};
  }

  RegisterResponseModel copyWith({String? message, UserModel? data}) {
    return RegisterResponseModel(
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}
