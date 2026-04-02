import 'package:absensi_go/src/core/services/session_service.dart';
import 'package:absensi_go/src/data/models/auth_model.dart';
import 'package:absensi_go/src/data/models/register_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../data/repositories/auth_repository.dart';

final localStorageProvider = Provider((ref) => PreferenceHandler());

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(ref.watch(localStorageProvider)),
);

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
      return AuthNotifier(ref.watch(authRepositoryProvider));
    });

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository repository;

  AuthNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await repository.login(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<RegisterResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required int batchId,
    required int trainingId,
  }) async {
    try {
      final result = await repository.register(
        name: name,
        email: email,
        password: password,
        jenisKelamin: jenisKelamin,
        batchId: batchId,
        trainingId: trainingId,
      );

      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await repository.logout();
    state = const AsyncValue.data(null);
  }
}
