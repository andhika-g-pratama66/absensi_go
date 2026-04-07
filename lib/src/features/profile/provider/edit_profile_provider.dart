// --- State ---
import 'dart:convert';
import 'dart:developer';

import 'package:absensi_go/src/core/errors/api_execption.dart';
import 'package:absensi_go/src/data/models/auth_model.dart';
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';
import 'package:absensi_go/src/features/profile/repositories/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileState {
  final bool isLoading;
  final bool isUploadingPhoto;
  final double uploadProgress; // 0.0 to 1.0
  final String? errorMessage;
  final bool isSuccess;
  final String? base64Image; // local preview only
  final String? photoUrl; // returned from photo API, sent to profile API
  final int? imageSize; // size in bytes for validation

  const EditProfileState({
    this.isLoading = false,
    this.isUploadingPhoto = false,
    this.uploadProgress = 0.0,
    this.errorMessage,
    this.isSuccess = false,
    this.base64Image,
    this.photoUrl,
    this.imageSize,
  });

  EditProfileState copyWith({
    bool? isLoading,
    bool? isUploadingPhoto,
    double? uploadProgress,
    String? errorMessage,
    bool? isSuccess,
    String? base64Image,
    String? photoUrl,
    int? imageSize,
  }) {
    return EditProfileState(
      isLoading: isLoading ?? this.isLoading,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: errorMessage, // null clears it
      isSuccess: isSuccess ?? this.isSuccess,
      base64Image: base64Image ?? this.base64Image,
      photoUrl: photoUrl ?? this.photoUrl,
      imageSize: imageSize ?? this.imageSize,
    );
  }

  bool get hasValidImage => base64Image != null && base64Image!.isNotEmpty;
  bool get isUploadInProgress =>
      isUploadingPhoto && uploadProgress > 0 && uploadProgress < 1;
}

// --- Notifier ---
class EditProfileNotifier extends Notifier<EditProfileState> {
  @override
  EditProfileState build() => const EditProfileState();

  ProfileRepository get _profileRepo => ref.read(profileRepositoryProvider);

  final ImagePicker _picker = ImagePicker();

  /// Step 1 — pick from gallery, compress, and store base64 for preview
  Future<void> pickImage() async {
    try {
      state = state.copyWith(errorMessage: null);

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Higher quality for initial processing
        maxWidth: 1200, // Allow larger size initially, will be compressed later
        maxHeight: 1200,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();
      if (bytes.isEmpty) {
        throw Exception('Gambar kosong atau rusak.');
      }

      // Basic validation
      if (bytes.length > 5 * 1024 * 1024) {
        // 5MB limit
        throw Exception('Ukuran gambar terlalu besar. Maksimal 5MB.');
      }

      // Store original size for validation display
      state = state.copyWith(
        base64Image: base64Encode(bytes),
        imageSize: bytes.length,
      );
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    } catch (e) {
      log('[EditProfile] pickImage error: $e');
      state = state.copyWith(
        errorMessage: 'Gagal mengambil gambar: ${e.toString()}',
      );
    }
  }

  /// Step 2 — upload the picked image to its own API endpoint
  /// Call this when the user confirms/saves, before editProfile()
  Future<void> uploadPhoto() async {
    if (!state.hasValidImage) {
      state = state.copyWith(errorMessage: 'Tidak ada gambar yang dipilih.');
      return;
    }

    // Reset state for new upload
    state = state.copyWith(
      isUploadingPhoto: true,
      uploadProgress: 0.0,
      errorMessage: null,
      photoUrl: null, // Clear previous URL
    );

    try {
      // Strip the "data:image/jpeg;base64," prefix if present
      final cleanBase64 = state.base64Image!.contains(',')
          ? state.base64Image!.split(',').last
          : state.base64Image!;

      log(
        '[EditProfile] Uploading image, base64 length: ${cleanBase64.length}',
      );
      final imageBytes = base64Decode(cleanBase64);

      final String url = await _profileRepo.uploadProfilePhoto(
        imageBytes,
        onProgress: (progress) {
          state = state.copyWith(uploadProgress: progress);
        },
      );

      // Success - update state
      state = state.copyWith(
        isUploadingPhoto: false,
        uploadProgress: 1.0,
        photoUrl: url.isNotEmpty ? url : null,
        base64Image: null, // Clear local cache after successful upload
        imageSize: null,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isUploadingPhoto: false,
        uploadProgress: 0.0,
        errorMessage: e.message,
      );
    } catch (e) {
      log('[EditProfile] uploadPhoto error: $e');
      state = state.copyWith(
        isUploadingPhoto: false,
        uploadProgress: 0.0,
        errorMessage: 'Terjadi kesalahan sistem saat mengunggah foto.',
      );
    }
  }

  /// Step 3 — update name/email, passing the photo URL if one was uploaded
  Future<void> editProfile({
    required String name,
    required String email,
  }) async {
    state = state.copyWith(isLoading: true, isSuccess: false);
    try {
      final User updatedUser = await _profileRepo.editUser(
        name: name,
        email: email,
        photoUrl: state.photoUrl,
      );

      await ref.read(authProvider.notifier).updateUser(updatedUser);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      log('[EditProfile] editProfile error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan tak terduga.',
      );
    }
  }

  void clearError() => state = state.copyWith(errorMessage: null);
  void resetSuccess() => state = state.copyWith(isSuccess: false);

  /// Cancel ongoing upload
  void cancelUpload() {
    if (state.isUploadingPhoto) {
      state = state.copyWith(
        isUploadingPhoto: false,
        uploadProgress: 0.0,
        errorMessage: 'Upload dibatalkan.',
      );
    }
  }

  /// Clear selected image

  /// Get formatted file size for display
  String? get formattedImageSize {
    if (state.imageSize == null) return null;
    final size = state.imageSize!;
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).round()}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

final editProfileProvider =
    NotifierProvider<EditProfileNotifier, EditProfileState>(
      () => EditProfileNotifier(),
    );
