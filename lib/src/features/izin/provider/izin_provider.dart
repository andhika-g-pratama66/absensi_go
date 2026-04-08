import 'package:absensi_go/src/data/repositories/izin_repository.dart';
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';
import 'package:absensi_go/src/features/izin/models/izin_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Provider untuk IzinRepository
final izinRepositoryProvider = Provider<IzinRepository>((ref) {
  final authToken = ref.watch(
    authProvider.select((state) => state.value?.data?.token),
  );
  final repository = IzinRepositoryImpl();

  if (authToken != null) {
    repository.setAuthToken(authToken);
  }

  return repository;
});

// State class untuk manajemen state izin
class IzinState {
  final List<IzinModel> izinList;
  final IzinModel? selectedIzin;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  const IzinState({
    this.izinList = const [],
    this.selectedIzin,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  IzinState copyWith({
    List<IzinModel>? izinList,
    IzinModel? selectedIzin,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
  }) {
    return IzinState(
      izinList: izinList ?? this.izinList,
      selectedIzin: selectedIzin ?? this.selectedIzin,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

// Notifier class untuk manajemen logic izin
class IzinNotifier extends StateNotifier<IzinState> {
  final IzinRepository _repository;

  IzinNotifier(this._repository) : super(const IzinState());

  // Load list izin
  Future<void> loadIzinList({DateTime? startDate, DateTime? endDate}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final list = await _repository.getIzinList(
        startDate: startDate,
        endDate: endDate,
      );
      state = state.copyWith(izinList: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // Get detail izin
  Future<void> getIzinDetail(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final izin = await _repository.getIzinDetail(id);
      state = state.copyWith(selectedIzin: izin, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // Create izin (submit)
  Future<void> submitIzin(IzinModel izinModel) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final result = await _repository.createIzin(izinModel);
      state = state.copyWith(
        izinList: [...state.izinList, result],
        isSubmitting: false,
        successMessage: 'Izin berhasil diajukan',
      );
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
    }
  }

  // Update izin
  Future<void> updateIzin(int id, IzinModel izinModel) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final result = await _repository.updateIzin(id, izinModel);
      final updatedList = state.izinList
          .map((e) => e.id == id ? result : e)
          .toList();
      state = state.copyWith(
        izinList: updatedList,
        selectedIzin: result,
        isSubmitting: false,
        successMessage: 'Izin berhasil diperbarui',
      );
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
    }
  }

  // Delete izin
  Future<void> deleteIzin(int id) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      await _repository.deleteIzin(id);
      final updatedList = state.izinList.where((e) => e.id != id).toList();
      state = state.copyWith(
        izinList: updatedList,
        isSubmitting: false,
        successMessage: 'Izin berhasil dihapus',
      );
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
    }
  }

  // Cancel izin
  Future<void> cancelIzin(int id, String reason) async {
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      await _repository.cancelIzin(id, reason);
      final updatedList = state.izinList.map((e) {
        if (e.id == id) {
          return e.copyWith(status: 'canceled');
        }
        return e;
      }).toList();
      state = state.copyWith(
        izinList: updatedList,
        isSubmitting: false,
        successMessage: 'Izin berhasil dibatalkan',
      );
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
    }
  }

  // Clear messages
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }

  // Set selected izin
  void setSelectedIzin(IzinModel izin) {
    state = state.copyWith(selectedIzin: izin);
  }
}

// Provider untuk IzinNotifier
final izinProvider = StateNotifierProvider<IzinNotifier, IzinState>((ref) {
  final repository = ref.watch(izinRepositoryProvider);
  return IzinNotifier(repository);
});
