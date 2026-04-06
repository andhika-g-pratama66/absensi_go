import 'package:absensi_go/src/data/models/batch_model.dart';
import 'package:absensi_go/src/data/repositories/batch_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// TODO: Sesuaikan import dengan lokasi file model & repository kamu

// 1. Provider untuk Repository
final batchRepositoryProvider = Provider<BatchRepository>((ref) {
  return BatchRepository();
});

// 2. Provider untuk batch yang dipilih (menyimpan ID batch)
final selectedBatchProvider = StateProvider.autoDispose<int?>((ref) => null);

// 3. Provider untuk mengambil list batch (Mengembalikan List<Datum>)
final batchListProvider = FutureProvider.autoDispose<List<Datum>>((ref) async {
  try {
    final repository = ref.watch(batchRepositoryProvider);

    // Memanggil API dan mengembalikan List<Datum>
    final batches = await repository.getTrainingBatches();

    return batches;
  } catch (e) {
    print('=== API ERROR ===');
    print(e.toString()); // Look at your debug console!
    throw Exception('Error fetching batches: $e');
  }
});
