import 'package:flutter_riverpod/legacy.dart';

// App state providers
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
);

class AppState {
  final bool isLoading;
  final String? error;

  AppState({this.isLoading = false, this.error});

  AppState copyWith({bool? isLoading, String? error}) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState());

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void clear() {
    state = AppState();
  }
}
