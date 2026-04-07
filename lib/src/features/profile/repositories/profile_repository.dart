import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:absensi_go/src/core/errors/api_execption.dart';
import 'package:absensi_go/src/data/models/auth_model.dart';
import 'package:absensi_go/src/data/repositories/endpoint.dart';
import 'package:absensi_go/src/data/repositories/local_storage.dart';
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final storage = ref.watch(localStorageProvider);
  return ProfileRepository(storage);
});

class ProfileRepository {
  final LocalStorageService storage;

  // Image processing constants
  static const int maxImageSize = 1024 * 1024; // 1MB
  static const int maxWidth = 800;
  static const int maxHeight = 800;
  static const int jpegQuality = 85;

  ProfileRepository(this.storage);

  // ── Shared helpers ──────────────────────────────────────────────

  Future<Map<String, String>> _getHeaders() async {
    final token = await storage.getToken();
    if (token == null || token.isEmpty) {
      throw ApiException('User tidak terautentikasi.');
    }
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  User _processResponse(http.Response response, String tag) {
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return _parseUser(decoded);
    }
    log('$tag Failed: ${response.statusCode} — ${response.body}');
    throw ApiException(decoded['message'] ?? 'Gagal memproses permintaan.');
  }

  User _parseUser(Map<String, dynamic> decoded) {
    final userJson = decoded['data'] is Map
        ? decoded['data'] as Map<String, dynamic>
        : decoded;
    return User.fromJson(userJson);
  }

  /// Compress and optimize image before upload
  Future<Uint8List> _processImage(Uint8List imageBytes) async {
    return await compute(_processImageInIsolate, imageBytes);
  }

  static Uint8List _processImageInIsolate(Uint8List imageBytes) {
    try {
      // Decode image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        throw ApiException('Format gambar tidak didukung.');
      }

      // Resize if too large
      if (image.width > maxWidth || image.height > maxHeight) {
        image = img.copyResize(
          image,
          width: image.width > image.height
              ? maxWidth
              : (image.width * maxHeight ~/ image.height),
          height: image.height > image.width
              ? maxHeight
              : (image.height * maxWidth ~/ image.width),
        );
      }

      // Compress to JPEG
      return Uint8List.fromList(img.encodeJpg(image, quality: jpegQuality));
    } catch (e) {
      throw ApiException('Gagal memproses gambar: $e');
    }
  }

  /// Retry mechanism for network requests
  Future<T> _retryRequest<T>(
    Future<T> Function() request,
    int maxRetries,
    Duration delay,
  ) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await request();
      } on SocketException catch (e) {
        attempts++;
        if (attempts >= maxRetries) rethrow;
        log(
          '[ProfileRepository] Network error, retrying... ($attempts/$maxRetries)',
        );
        await Future.delayed(delay * attempts);
      } on TimeoutException catch (e) {
        attempts++;
        if (attempts >= maxRetries) rethrow;
        log('[ProfileRepository] Timeout, retrying... ($attempts/$maxRetries)');
        await Future.delayed(delay * attempts);
      }
    }
    throw ApiException('Gagal setelah $maxRetries percobaan.');
  }

  // ── GET profile ─────────────────────────────────────────────────

  Future<User?> getUser() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(Endpoint.profile),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return _parseUser(json.decode(response.body) as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      log('[GetUser] Error: $e');
      return null;
    }
  }

  // ── PUT /profile  (name + email + optional photo URL) ─────────────────

  Future<User> editUser({
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    final headers = await _getHeaders();
    final body = {
      'name': name,
      'email': email,
      if (photoUrl != null) 'profile_photo_url': photoUrl,
    };
    final response = await http.put(
      Uri.parse(Endpoint.profile),
      headers: headers,
      body: json.encode(body),
    );
    return _processResponse(response, '[EditUser]');
  }

  // ── PUT /profile/photo  (base64 image, separate endpoint) ───────

  /// Uploads profile photo with compression, retry logic, and progress tracking
  /// Returns the photo URL from the server response
  Future<String> uploadProfilePhoto(
    Uint8List imageBytes, {
    void Function(double progress)? onProgress,
  }) async {
    // Validate input
    if (imageBytes.isEmpty) {
      throw ApiException('Data gambar kosong.');
    }

    if (imageBytes.length > maxImageSize * 2) {
      // Allow some buffer for processing
      throw ApiException(
        'Ukuran gambar terlalu besar. Maksimal ${maxImageSize ~/ (1024 * 1024)}MB.',
      );
    }

    onProgress?.call(0.1); // Start processing

    try {
      // Process image in background isolate
      final processedBytes = await _processImage(imageBytes);
      onProgress?.call(0.3); // Processing complete

      // Format for API - send pure base64-encoded string only
      final String formattedBody = base64Encode(processedBytes);

      onProgress?.call(0.5); // Ready to upload

      // Upload with retry logic
      final url = await _retryRequest(
        () => _performPhotoUpload(formattedBody, onProgress),
        3, // max retries
        const Duration(seconds: 2), // delay between retries
      );

      onProgress?.call(1.0); // Complete
      return url;
    } on ApiException {
      rethrow; // Re-throw API exceptions as-is
    } catch (e) {
      log('[UploadPhoto] Unexpected error: $e');
      throw ApiException('Terjadi kesalahan saat mengunggah foto.');
    }
  }

  /// Performs the actual HTTP upload
  Future<String> _performPhotoUpload(
    String formattedBody,
    void Function(double progress)? onProgress,
  ) async {
    log('[UploadPhoto] Starting upload, body length: ${formattedBody.length}');
    final headers = await _getHeaders();

    final response = await http
        .put(
          Uri.parse(Endpoint.profilePhoto),
          headers: headers,
          body: json.encode({'profile_photo': formattedBody}),
        )
        .timeout(const Duration(seconds: 30));

    log('[UploadPhoto] Response status: ${response.statusCode}');
    log('[UploadPhoto] Response body: ${response.body}');

    onProgress?.call(0.8); // Upload complete, processing response

    final Map<String, dynamic> decoded = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final userData = decoded['data'];
      String? url;

      if (userData is Map<String, dynamic>) {
        url =
            userData['profile_photo_url']?.toString() ??
            userData['profile_photo']?.toString();
      } else if (userData is String) {
        url = userData;
      }

      url ??=
          decoded['profile_photo_url']?.toString() ??
          decoded['profile_photo']?.toString();

      if (url != null && url.isNotEmpty) {
        return url;
      }

      log('[UploadPhoto] Successful upload without returned URL.');
      return '';
    } else {
      log('[UploadPhoto] Failed: ${response.statusCode} — ${response.body}');
      throw ApiException(decoded['message'] ?? 'Gagal mengunggah foto.');
    }
  }
}
