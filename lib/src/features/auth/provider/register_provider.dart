import 'dart:async';

import 'package:absensi_go/src/data/models/register_model.dart';
import 'package:absensi_go/src/data/repositories/auth_repository.dart';
import 'package:absensi_go/src/data/repositories/local_storage.dart';

import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:absensi_go/src/core/errors/api_execption.dart';

import 'package:flutter_riverpod/legacy.dart';

// Assuming you have your PreferenceHandler setup somewhere to inject
// final storageProvider = Provider<PreferenceHandler>((ref) => ...);
final obscuredPasswordProvider = StateProvider.autoDispose<bool>((ref) => true);
final obscuredConfirmPasswordProvider = StateProvider.autoDispose<bool>(
  (ref) => true,
);
final registerLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);
final genderProvider = StateProvider.autoDispose<String?>((ref) => "");

// Change the name here from registerRepositoryProvider to authRepositoryProvider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(localStorageProvider);
  return AuthRepository(storage);
});

final registerProvider =
    AsyncNotifierProvider.autoDispose<RegisterNotifier, RegisterModel?>(() {
      return RegisterNotifier();
    });

class RegisterNotifier extends AsyncNotifier<RegisterModel?> {
  @override
  FutureOr<RegisterModel?> build() {
    // Initial state is null.
    return null;
  }

  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required int batchId,
    required int trainingId,
  }) async {
    state =
        const AsyncLoading(); // Set loading state manually before the async gap

    // Access providers directly using ref.read inside Notifiers
    final repository = ref.read(authRepositoryProvider);
    final storage = ref.read(localStorageProvider);

    try {
      final result = await repository.register(
        name: name,
        email: email,
        password: password,
        jenisKelamin: jenisKelamin,
        batchId: batchId,
        trainingId: trainingId,
      );

      if (result.data?.token != null) {
        await storage.saveToken(result.data!.token!);
      }

      state = AsyncData(result);
    } on ApiException catch (e, st) {
      state = AsyncError(e.message, st);
    } catch (e, st) {
      state = AsyncError('An unexpected error occurred: $e', st);
    }
  }
}
