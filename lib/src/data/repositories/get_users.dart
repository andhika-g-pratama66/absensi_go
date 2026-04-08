import 'dart:async';
import 'dart:convert';
import 'package:absensi_go/src/data/repositories/endpoint.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:absensi_go/src/data/models/auth_model.dart';
import 'package:http/http.dart' as http;

// ==========================================
// 1. Repository
// ==========================================
class GetUsersRepository {
  final Map<String, String> _jsonHeaders = {
    "Accept": "application/json",
    "Content-Type": "application/json",
  };

  // Added an optional 'params' map in case your POST request requires a payload (like pagination or filters).
  Future<UserModel> getUsers({Map<String, dynamic>? params}) async {
    try {
      final response = await http
          .post(
            Uri.parse(Endpoint.users),
            headers: _jsonHeaders,
            // Encode the payload to JSON. If no params are passed, send an empty JSON object.
            body: jsonEncode(params ?? {}),
          )
          .timeout(const Duration(seconds: 30));

      // Check for a successful response
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        // Assuming your UserModel has a standard fromJson factory constructor
        return UserModel.fromJson(decodedData);
      } else {
        // Throw an exception for non-200 responses so the UI can show an error state
        throw Exception(
          'Failed to load users. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Catch network errors, timeouts, or JSON parsing errors and rethrow them
      // so Riverpod's AsyncValue.guard can transition the state to AsyncError
      throw Exception('Error fetching users: $e');
    }
  }
}

// ==========================================
// 2. Repository Provider
// ==========================================
final getUsersRepositoryProvider = Provider<GetUsersRepository>((ref) {
  return GetUsersRepository();
});

// ==========================================
// 3. AsyncNotifier
// ==========================================
