import 'package:absensi_go/src/data/models/check_out_model.dart';
import 'package:absensi_go/src/data/repositories/endpoint.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';

abstract class CheckOutRepository {
  Future<CheckOutModel> submitCheckOut(CheckOutModel checkOutModel);
  Future<CheckOutModel?> getTodayCheckOut();
}

class CheckOutRepositoryImpl implements CheckOutRepository {
  final Dio _dio;

  CheckOutRepositoryImpl({Dio? dio}) : _dio = dio ?? Dio() {
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

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  @override
  Future<CheckOutModel> submitCheckOut(CheckOutModel checkOutModel) async {
    try {
      final response = await _dio.post(
        '/absen/check-out',
        data: checkOutModel.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CheckOutModel.fromJson(response.data['data'] ?? response.data);
      }

      throw CheckOutException(
        message: response.data['message'] ?? 'Gagal melakukan check out',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is CheckOutException) rethrow;
      throw CheckOutException(message: 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  @override
  Future<CheckOutModel?> getTodayCheckOut() async {
    try {
      final now = DateTime.now();
      final response = await _dio.get(
        '/absen/today', // Assuming same endpoint for today's status which includes checkout
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
        
        // Check if check_out data exists in the response
        if (data['check_out'] == null && data['check_out_time'] == null) {
          return null;
        }
        
        return CheckOutModel.fromJson(data);
      }

      return null;
    } on DioException {
      // For getting today's status, we might want to be more silent on errors
      return null;
    } catch (_) {
      return null;
    }
  }

  CheckOutException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return CheckOutException(
          message: 'Koneksi timeout, periksa jaringan Anda',
        );
      case DioExceptionType.connectionError:
        return CheckOutException(message: 'Tidak dapat terhubung ke server');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'];

        if (statusCode == 401) {
          return CheckOutException(
            message: 'Sesi habis, silakan login kembali',
            statusCode: statusCode,
          );
        }
        return CheckOutException(
          message: message ?? 'Terjadi kesalahan server',
          statusCode: statusCode,
        );
      default:
        return CheckOutException(message: e.message ?? 'Terjadi kesalahan');
    }
  }
}

class CheckOutException implements Exception {
  final String message;
  final int? statusCode;

  CheckOutException({required this.message, this.statusCode});

  @override
  String toString() => 'CheckOutException: $message (status: $statusCode)';
}

final checkOutRepositoryProvider = Provider<CheckOutRepository>((ref) {
  final repo = CheckOutRepositoryImpl();
  ref.watch(tokenProvider).whenData((token) {
    if (token != null) {
      repo.setAuthToken(token);
    }
  });
  return repo;
});
