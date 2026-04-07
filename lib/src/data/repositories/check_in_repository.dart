import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';
import 'package:absensi_go/src/features/check_in/models/check_in_model.dart';
import 'package:absensi_go/src/data/repositories/endpoint.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class CheckInRepository {
  Future<CheckInModel> submitCheckIn(CheckInModel checkInModel);
  Future<CheckInModel?> getTodayCheckIn();
}

class CheckInRepositoryImpl implements CheckInRepository {
  final Dio _dio;

  CheckInRepositoryImpl({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: Endpoint.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  /// Set token Authorization (dipanggil setelah login)
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  @override
  Future<CheckInModel> submitCheckIn(CheckInModel checkInModel) async {
    try {
      final response = await _dio.post(
        '/absen/check-in',
        data: checkInModel.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CheckInModel.fromJson(response.data['data'] ?? response.data);
      }

      throw CheckInException(
        message: response.data['message'] ?? 'Gagal melakukan check in',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is CheckInException) rethrow;
      throw CheckInException(message: 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  @override
  Future<CheckInModel?> getTodayCheckIn() async {
    try {
      final now = DateTime.now();
      final response = await _dio.get(
        '/absen/today',
        queryParameters: {
          'attendance_date':
              '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        },
      );

      if (response.statusCode == 200) {
        final rawData = response.data;
        final data = rawData is Map<String, dynamic>
            ? rawData['data'] ?? rawData
            : rawData;
        if (data == null) return null;
        return CheckInModel.fromJson(data);
      }

      throw CheckInException(
        message: response.data['message'] ?? 'Gagal mengambil data check in',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is CheckInException) rethrow;
      throw CheckInException(message: 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  CheckInException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return CheckInException(
          message: 'Koneksi timeout, periksa jaringan Anda',
        );
      case DioExceptionType.connectionError:
        return CheckInException(message: 'Tidak dapat terhubung ke server');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'];

        if (statusCode == 401) {
          return CheckInException(
            message: 'Sesi habis, silakan login kembali',
            statusCode: statusCode,
          );
        }
        if (statusCode == 422) {
          return CheckInException(
            message: message ?? 'Data tidak valid',
            statusCode: statusCode,
          );
        }
        if (statusCode == 409) {
          return CheckInException(
            message: message ?? 'Anda sudah melakukan check in hari ini',
            statusCode: statusCode,
          );
        }
        return CheckInException(
          message: message ?? 'Terjadi kesalahan server',
          statusCode: statusCode,
        );
      default:
        return CheckInException(message: e.message ?? 'Terjadi kesalahan');
    }
  }
}

// ── Exception ────────────────────────────────────────────

class CheckInException implements Exception {
  final String message;
  final int? statusCode;

  CheckInException({required this.message, this.statusCode});

  @override
  String toString() => 'CheckInException: $message (status: $statusCode)';
}

final checkInRepositoryProvider = Provider<CheckInRepository>((ref) {
  final repo = CheckInRepositoryImpl();

  ref.watch(tokenProvider).whenData((token) {
    if (token != null) {
      repo.setAuthToken(token);
    }
  });

  return repo;
});
