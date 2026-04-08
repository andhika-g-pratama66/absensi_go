import 'dart:async';

import 'package:absensi_go/src/data/models/auth_model.dart';
import 'package:absensi_go/src/data/repositories/get_users.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsersNotifier extends AsyncNotifier<UserModel> {
  @override
  FutureOr<UserModel> build() async {
    return _fetchUser();
  }

  Future<UserModel> _fetchUser() async {
    final repository = ref.read(getUsersRepositoryProvider);
    // You can pass arguments to getUsers() here if your POST request requires a body
    return await repository.getUsers();
  }

  // Example method to manually refresh the data (e.g., Pull-to-refresh)
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchUser());
  }
}

// ==========================================
// 4. AsyncNotifier Provider
// ==========================================
final usersNotifierProvider = AsyncNotifierProvider<UsersNotifier, UserModel>(
  () {
    return UsersNotifier();
  },
);
