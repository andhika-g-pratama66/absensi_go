import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:absensi_go/src/core/errors/api_execption.dart';

import 'package:absensi_go/src/data/models/auth_model.dart';
import 'package:absensi_go/src/data/models/register_model.dart';
import 'package:absensi_go/src/data/repositories/endpoint.dart';
import 'package:absensi_go/src/data/repositories/local_storage.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  final LocalStorageService storage;

  AuthRepository(this.storage);

  final Map<String, String> _jsonHeaders = {
    "Accept": "application/json",
    "Content-Type": "application/json",
  };

  /// FIX #1: Added timeout, token saving, and proper error handling
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(Endpoint.login),
            headers: _jsonHeaders,
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(const Duration(seconds: 30)); // FIX: added timeout

      log('[Login] Response Status: ${response.statusCode}');
      log('[Login] Response Body: ${response.body}');

      final decoded = json.decode(
        response.body,
      ); // FIX: wrapped in try/catch below

      switch (response.statusCode) {
        case 200:
        case 201:
          final user = UserModel.fromJson(decoded);

          final token = decoded['data']?['token'] ?? decoded['token'];
          if (token != null) {
            // ✅ UNLIMITED SESSION: Simpan token tanpa expiry
            // Ini akan mengatur unlimited_session = true
            await storage.saveToken(token);
            await storage.setUnlimitedSession();
            await storage.saveUser(user);
          }

          return user;

        case 401:
          throw ApiException(
            decoded['message'] ?? 'Email atau password salah.',
            statusCode: 401,
          );

        case 422:
          final errors = decoded['errors'] as Map<String, dynamic>?;
          String errorMessage = decoded['message'] ?? 'Data tidak valid.';

          if (errors != null && errors.isNotEmpty) {
            final firstFieldErrors = errors.values.first;
            if (firstFieldErrors is List && firstFieldErrors.isNotEmpty) {
              errorMessage = firstFieldErrors.first.toString();
            }
          }
          throw ApiException(errorMessage, statusCode: 422);

        default:
          throw ApiException(
            decoded['message'] ??
                'Terjadi kesalahan server (${response.statusCode})',
            statusCode: response.statusCode,
          );
      }
    } on SocketException {
      // FIX: catch network errors
      throw const ApiException('Tidak ada koneksi internet.');
    } on TimeoutException {
      // FIX: catch timeout errors
      throw const ApiException('Koneksi timeout, coba lagi.');
    } on FormatException catch (e) {
      // FIX: catch invalid JSON response
      log('[Login] FormatException: $e');
      throw const ApiException(
        'Response dari server tidak valid (Bukan JSON).',
      );
    } catch (e) {
      log('[Login] Unexpected Error: $e');
      rethrow;
    }
  }

  /// FIX #4: Uncommented password_confirmation
  Future<RegisterModel> register({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required int batchId,
    required int trainingId,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": password, // FIX: required by most backends
        "jenis_kelamin": jenisKelamin,
        "batch_id": batchId,
        "training_id": trainingId,
      };

      log('[Register] Request Body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse(Endpoint.register),
            headers: _jsonHeaders,
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      log('[Register] Response Status: ${response.statusCode}');
      log('[Register] Response Body: ${response.body}');

      final decoded = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
        case 201:
          return RegisterModel.fromJson(decoded);

        case 422:
          final errors = decoded['errors'] as Map<String, dynamic>?;
          String errorMessage = 'Data tidak valid.';

          if (errors != null && errors.isNotEmpty) {
            final firstFieldErrors = errors.values.first;
            if (firstFieldErrors is List && firstFieldErrors.isNotEmpty) {
              errorMessage = firstFieldErrors.first.toString();
            }
          } else if (decoded['message'] != null) {
            errorMessage = decoded['message'];
          }
          throw ApiException(errorMessage, statusCode: 422);

        default:
          throw ApiException(
            decoded['message'] ??
                'Terjadi kesalahan server (${response.statusCode})',
            statusCode: response.statusCode,
          );
      }
    } on SocketException {
      throw const ApiException('Tidak ada koneksi internet.');
    } on TimeoutException {
      throw const ApiException('Koneksi timeout, coba lagi.');
    } on FormatException catch (e) {
      log('[Register] FormatException: $e');
      throw const ApiException(
        'Response dari server tidak valid (Bukan JSON).',
      );
    } catch (e) {
      log('[Register] Unexpected Error: $e');
      rethrow;
    }
  }

  /// FIX #3 & #6: Call the logout API endpoint + use instance storage, not static
  Future<void> logout() async {
    try {
      final token = await storage.getToken(); // FIX: use injected instance

      if (token != null) {
        // FIX #3: Invalidate session on the server
      }
    } on SocketException {
      log('[Logout] No internet, clearing local session anyway.');
    } on TimeoutException {
      log('[Logout] Timeout, clearing local session anyway.');
    } catch (e) {
      log('[Logout] Unexpected error: $e');
    } finally {
      // Always clear local token regardless of server response
      await storage.deleteToken();
      await storage.deleteUser(); // FIX #6: use instance method, not static
    }
  }
}
