import 'package:absensi_go/src/data/models/auth_model.dart';
import 'package:absensi_go/src/data/repositories/local_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../data/repositories/auth_repository.dart';

final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(ref.watch(localStorageProvider)),
);

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
      return AuthNotifier(ref.watch(authRepositoryProvider));
    });

// Provider untuk get current user dari state
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).asData?.value;
});

// Provider untuk cek apakah user sudah login
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// Provider untuk get token dari SharedPreferences
final tokenProvider = FutureProvider<String?>((ref) async {
  return await ref.read(localStorageProvider).getToken();
});

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

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository repository;

  AuthNotifier(this.repository) : super(const AsyncValue.data(null)) {
    _init(); // auto load user saat app start
  }

  // Load user dari token yang tersimpan
  Future<void> _init() async {
    try {
      final token = await repository.storage.getToken();

      if (token == null || token.isEmpty) {
        state = const AsyncValue.data(null);
        return;
      }

      // Load user dari SharedPreferences, tidak perlu hit API
      final user = await repository.storage.getUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await repository.login(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await repository.logout();
    state = const AsyncValue.data(null);
  }
}
