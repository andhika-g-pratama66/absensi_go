class UserModel {
  final String name;
  final String email;
  final String password;
  final String jenisKelamin;
  final int batchId;
  final int trainingId;

  UserModel({
    required this.name,
    required this.email,
    required this.password,
    required this.jenisKelamin,
    required this.batchId,
    required this.trainingId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      jenisKelamin: json['jenis_kelamin'] ?? '',
      batchId: json['batch_id'] ?? 0,
      trainingId: json['training_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'jenis_kelamin': jenisKelamin,
      'batch_id': batchId,
      'training_id': trainingId,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? password,
    String? jenisKelamin,
    int? batchId,
    int? trainingId,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      batchId: batchId ?? this.batchId,
      trainingId: trainingId ?? this.trainingId,
    );
  }
}
