import 'package:absensi_go/src/data/models/training_model.dart';
import 'package:absensi_go/src/data/repositories/endpoint.dart';
import 'package:http/http.dart' as http;
// TODO: Sesuaikan import dengan lokasi file model kamu

class TrainingRepository {
  final String baseUrl = Endpoint.trainings;

  Future<List<Datum>> getTraining() async {
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
        final trainingModel = trainingModelFromJson(response.body);

        // Return list of Datum (atau list kosong jika null)
        return trainingModel.data ?? [];
      } else {
        throw Exception('Failed to load training: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching training: $e');
    }
  }
}
