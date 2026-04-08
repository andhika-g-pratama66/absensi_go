import 'dart:developer';

import 'package:absensi_go/src/data/models/auth_model.dart';
import 'package:absensi_go/src/data/repositories/local_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:absensi_go/src/features/profile/repositories/profile_repository.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../data/repositories/auth_repository.dart';

final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(ref.watch(localStorageProvider)),
);

// ✅ Changed to AsyncNotifierProvider
final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(() {
  return AuthNotifier();
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref
      .watch(authProvider)
      .maybeWhen(
        data: (user) => user, // ✅ Add this line!
        orElse: () => null,
      );
});

final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);

  return authState.maybeWhen(
    data: (user) => user != null,
    // ✅ Keep this! It protects the router during the build() loading phase
    loading: () => true,
    orElse: () => false,
  );
});
// Create this in a global auth_provider.dart file
final authTokenProvider = StateProvider<String?>((ref) => null);

// You can also create a provider to check if the user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authTokenProvider) != null;
});
final tokenProvider = FutureProvider<String?>((ref) async {
  return await ref.read(localStorageProvider).getToken();
});

// --- LoginState (unchanged) ---
class LoginState {
  final bool isObscured;
  final bool isLoading;

  LoginState({this.isObscured = true, this.isLoading = false});

  LoginState copyWith({bool? isObscured, bool? isLoading}) {
    return LoginState(
      isObscured: isObscured ?? this.isObscured,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ✅ Extends AsyncNotifier. Notice we drop AsyncValue from the generic type!
class AuthNotifier extends AsyncNotifier<UserModel?> {
  // Helper getter to easily access the repository
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  Future<UserModel?> build() async {
    log('[AuthNotifier] App restarted! Checking local storage...');

    final token = await _repository.storage.getToken(checkExpiry: false);
    log('[AuthNotifier] Token found: $token');

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      // ✅ Fetch user dari API menggunakan token yang ada
      final repo = ref.read(profileRepositoryProvider);
      final user = await repo.getUser();
      log('[AuthNotifier] User fetched from API: ${user?.name}');

      if (user == null) return null;

      // ✅ Wrap User ke dalam UserModel agar type konsisten
      return UserModel(
        message: 'success',
        data: Data(token: token, user: user),
      );
    } catch (e) {
      log('[AuthNotifier] ERROR fetching user from API: $e');
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      // ✅ Repository sudah handle saveToken di dalamnya
      final result = await _repository.login(email, password);
      return result; // langsung return UserModel
    });
  }

  Future<void> updateUser(User updatedUser) async {
    final current = await future;

    if (current == null) {
      log('[AuthNotifier] Cannot update user: Current state is null!');
      return;
    }

    // 1. Grab the old user data before we overwrite it
    final oldUser = current.data?.user;

    // 2. ✅ THE FIX: Create a safely merged user.
    // If the API didn't return a batch or training, keep the old ones!
    final safeUpdatedUser = updatedUser.copyWith(
      batch: updatedUser.batch ?? oldUser?.batch,
      training: updatedUser.training ?? oldUser?.training,
      // If profilePhoto also disappears, add it here too:
      profilePhoto: updatedUser.profilePhoto ?? oldUser?.profilePhoto,
    );

    // 3. Inject our safely merged user into the main state
    final merged = current.copyWith(
      data: current.data?.copyWith(user: safeUpdatedUser),
    );

    log('[AuthNotifier] Saving updated user to LocalStorage...');
    await _repository.storage.saveUser(merged);

    state = AsyncData(merged);
    log('[AuthNotifier] Successfully updated state!');
  }

  Future<void> refreshUser() async {
    try {
      final repo = ref.read(profileRepositoryProvider);
      final user = await repo.getUser();
      if (user != null) {
        await updateUser(user);
      }
    } catch (e) {
      log('[AuthNotifier] refreshUser error: $e');
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    await _repository.logout();
    state = const AsyncData(null);
  }
}
