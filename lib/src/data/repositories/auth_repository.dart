import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:absensi_go/src/core/errors/api_execption.dart';
import 'package:absensi_go/src/core/errors/app_exception.dart';
import 'package:absensi_go/src/core/services/session_service.dart';
import 'package:absensi_go/src/data/models/auth_model.dart';
import 'package:absensi_go/src/data/models/register_model.dart';
import 'package:absensi_go/src/data/repositories/endpoint.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  final PreferenceHandler storage;

  AuthRepository(this.storage);

  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    throw AppException('Email atau password salah');
  }

  final Map<String, String> _jsonHeaders = {
    "Accept": "application/json",
    "Content-Type": "application/json",
  };
  Future<RegisterResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required int batchId,
    required int trainingId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(Endpoint.register),
            headers: _jsonHeaders,
            body: jsonEncode({
              "name": name,
              "email": email,
              "password": password,
              "jenisKelamin": jenisKelamin,
              "batchId": batchId,
              'trainingId': trainingId,
            }),
          )
          .timeout(const Duration(seconds: 30));

      log('[Register] status: ${response.statusCode}');
      log('[Register] body: ${response.body}');

      final decoded = json.decode(response.body) as Map<String, dynamic>;

      switch (response.statusCode) {
        case 200:
        case 201:
          return RegisterResponseModel.fromJson(decoded);

        case 400:
          throw ApiException(
            decoded['message'] ?? 'Request tidak valid.',
            statusCode: 400,
          );

        case 422:
          final errors = decoded['errors'] as Map<String, dynamic>?;
          final firstError = errors?.values.firstOrNull;
          final msg =
              (firstError is List ? firstError.first : null) ??
              decoded['message'] ??
              'Data tidak valid.';
          throw ApiException(msg, statusCode: 422);

        case 500:
          throw ApiException(
            'Server sedang bermasalah, coba beberapa saat lagi.',
            statusCode: 500,
          );

        default:
          throw ApiException(
            decoded['message'] ?? 'Terjadi kesalahan (${response.statusCode}).',
            statusCode: response.statusCode,
          );
      }
    } on SocketException {
      throw const ApiException('Tidak ada koneksi internet.');
    } on TimeoutException {
      throw const ApiException('Koneksi timeout, coba lagi.');
    } on FormatException {
      throw const ApiException('Response dari server tidak valid.');
    }
  }

  Future<void> logout() async {
    await PreferenceHandler.clearToken();
  }

  // Future<UserModel?> getCurrentUser() async {
  //   await PreferenceHandler.getToken();

  //   return null;
  // }
}
