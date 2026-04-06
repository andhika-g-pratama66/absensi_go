import 'package:absensi_go/src/data/models/batch_model.dart';
import 'package:absensi_go/src/data/repositories/endpoint.dart';
import 'package:http/http.dart' as http;
// TODO: Sesuaikan import dengan lokasi file model kamu

class BatchRepository {
  final String baseUrl = Endpoint.batches;

  Future<List<Datum>> getTrainingBatches() async {
    final url = Uri.parse(baseUrl); // Ganti dengan endpoint aslimu

    try {
      final response = await http.get(
        url,
        // headers: {
        //   'Content-Type': 'application/json',
        //   'Accept': 'application/json',
        // },
      );

      if (response.statusCode == 200) {
        // Menggunakan fungsi helper dari model kamu
        final batchModel = batchModelFromJson(response.body);

        // Return list of Datum (atau list kosong jika null)
        return batchModel.data ?? [];
      } else {
        throw Exception('Failed to load batches: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching batches: $e');
    }
  }
}
