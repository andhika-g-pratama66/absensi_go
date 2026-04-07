import 'dart:io';

import 'package:absensi_go/src/features/izin/models/izin_model.dart';
import 'package:absensi_go/src/data/repositories/endpoint.dart';
import 'package:dio/dio.dart';

abstract class IzinRepository {
  Future<List<IzinModel>> getIzinList({DateTime? startDate, DateTime? endDate});
  Future<IzinModel> getIzinDetail(int id);
  Future<IzinModel> createIzin(IzinModel izinModel);
  Future<IzinModel> updateIzin(int id, IzinModel izinModel);
  Future<void> deleteIzin(int id);
  Future<void> cancelIzin(int id, String reason);
}

class IzinRepositoryImpl implements IzinRepository {
  final Dio _dio;

  IzinRepositoryImpl({Dio? dio}) : _dio = dio ?? Dio() {
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
  Future<List<IzinModel>> getIzinList({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (startDate != null) {
        queryParams['start_date'] =
            '${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      }

      if (endDate != null) {
        queryParams['end_date'] =
            '${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      }

      final response = await _dio.get(
        '/izin',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final list = response.data['data'] as List?;
        if (list != null) {
          return List<IzinModel>.from(
            list.map((x) => IzinModel.fromJson(x as Map<String, dynamic>)),
          );
        }
        return [];
      }

      throw IzinException(
        message: response.data['message'] ?? 'Gagal mengambil data izin',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is IzinException) rethrow;
      throw IzinException(message: 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  @override
  Future<IzinModel> getIzinDetail(int id) async {
    try {
      final response = await _dio.get('/izin/$id');

      if (response.statusCode == 200) {
        return IzinModel.fromJson(response.data['data'] ?? response.data);
      }

      throw IzinException(
        message: response.data['message'] ?? 'Gagal mengambil detail izin',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is IzinException) rethrow;
      throw IzinException(message: 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  @override
  Future<IzinModel> createIzin(IzinModel izinModel) async {
    try {
      final response = await _dio.post('/izin', data: izinModel.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        return IzinModel.fromJson(response.data['data'] ?? response.data);
      }

      throw IzinException(
        message: response.data['message'] ?? 'Gagal membuat izin',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is IzinException) rethrow;
      throw IzinException(message: 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  @override
  Future<IzinModel> updateIzin(int id, IzinModel izinModel) async {
    try {
      final response = await _dio.put('/izin/$id', data: izinModel.toJson());

      if (response.statusCode == 200) {
        return IzinModel.fromJson(response.data['data'] ?? response.data);
      }

      throw IzinException(
        message: response.data['message'] ?? 'Gagal mengubah izin',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is IzinException) rethrow;
      throw IzinException(message: 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteIzin(int id) async {
    try {
      final response = await _dio.delete('/izin/$id');

      if (response.statusCode != 200) {
        throw IzinException(
          message: response.data['message'] ?? 'Gagal menghapus izin',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is IzinException) rethrow;
      throw IzinException(message: 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelIzin(int id, String reason) async {
    try {
      final response = await _dio.post(
        '/izin/$id/cancel',
        data: {'reason': reason},
      );

      if (response.statusCode != 200) {
        throw IzinException(
          message: response.data['message'] ?? 'Gagal membatalkan izin',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is IzinException) rethrow;
      throw IzinException(message: 'Terjadi kesalahan: ${e.toString()}');
    }
  }

  IzinException _handleDioError(DioException e) {
    if (e.response?.statusCode == 401) {
      return IzinException(
        message: 'Unauthorized. Silakan login kembali.',
        statusCode: 401,
      );
    } else if (e.response?.statusCode == 403) {
      return IzinException(
        message: 'Anda tidak memiliki izin untuk mengakses resource ini.',
        statusCode: 403,
      );
    } else if (e.response?.statusCode == 422) {
      final errors = e.response?.data['errors'] as Map<String, dynamic>?;
      final message = errors?.entries.first.value is List
          ? (errors?.entries.first.value as List).first
          : (errors?.entries.first.value ?? 'Validasi gagal');
      return IzinException(message: message.toString(), statusCode: 422);
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return IzinException(message: 'Koneksi timeout. Coba lagi.');
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return IzinException(message: 'Timeout menerima data. Coba lagi.');
    } else if (e.type == DioExceptionType.unknown) {
      if (e.error is SocketException) {
        return IzinException(message: 'Periksa koneksi internet Anda.');
      }
    }

    return IzinException(
      message: e.response?.data['message'] ?? 'Terjadi kesalahan jaringan',
      statusCode: e.response?.statusCode,
    );
  }
}

class IzinException implements Exception {
  final String message;
  final int? statusCode;

  IzinException({required this.message, this.statusCode});

  @override
  String toString() => message;
}
