import 'dart:developer';
import 'package:absensi_go/src/data/models/training_model.dart';
import 'package:absensi_go/src/features/training/repository/training_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final trainingRepositoryProvider = Provider<TrainingRepository>((ref) {
  return TrainingRepository();
});
final selectedTrainingProvider = StateProvider.autoDispose<int?>((ref) => null);
final trainingListProvider = FutureProvider.autoDispose<List<Datum>>((
  ref,
) async {
  try {
    final repository = ref.watch(trainingRepositoryProvider);

    // Memanggil API dan mengembalikan List<Datum>
    final training = await repository.getTraining();

    return training;
  } catch (e) {
    log('=== API ERROR ===');
    log(e.toString()); // Look at your debug console!
    throw Exception('Error fetching training: $e');
  }
});
