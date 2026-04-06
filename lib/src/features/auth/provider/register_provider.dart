import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:absensi_go/src/core/errors/api_execption.dart';
import 'package:absensi_go/src/data/models/register_model.dart';
import 'package:absensi_go/src/data/repositories/auth_repository.dart';
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
    StateNotifierProvider.autoDispose<
      RegisterNotifier,
      AsyncValue<RegisterModel?>
    >((ref) {
      // Now this line will work perfectly!
      final repository = ref.watch(authRepositoryProvider);
      return RegisterNotifier(repository);
    });

class RegisterNotifier extends StateNotifier<AsyncValue<RegisterModel?>> {
  final AuthRepository repository;

  RegisterNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    // Removed passwordConfirmation to match your repository
    required String jenisKelamin,
    required int batchId,
    required int trainingId,
  }) async {
    state = const AsyncValue.loading();

    try {
      final RegisterModel result = await repository.register(
        name: name,
        email: email,
        password: password,
        jenisKelamin: jenisKelamin,
        batchId: batchId,
        trainingId: trainingId,
      );

      state = AsyncValue.data(result);
    } on ApiException catch (e, st) {
      // Your repository throws ApiException nicely, so we catch it here
      state = AsyncValue.error(e.message, st);
    } catch (e, st) {
      state = AsyncValue.error('An unexpected error occurred: $e', st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
