import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class SavedPlantsApi {
  static String get baseUrl => apiBaseUrl;

  // Save a plant for the logged-in user
  static Future<Map<String, dynamic>> savePlant({
    required int speciesId,
    required String commonName,
    required String scientificName,
    double? confidence,
    required String imageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'user_id': userId,
      'species_id': speciesId,
      'common_name': commonName,
      'scientific_name': scientificName,
      'confidence': confidence,
      'image_url': imageUrl,
    });

    for (final host in apiBaseUrls) {
      try {
        final response = await http
            .post(Uri.parse('$host/saved-plants/'), headers: headers, body: body)
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 201) {
          setWorkingBaseUrl(host);
          return jsonDecode(response.body);
        } else if (response.statusCode == 409) {
          setWorkingBaseUrl(host);
          throw Exception('Plant already saved');
        } else if (response.statusCode < 500) {
          setWorkingBaseUrl(host);
          debugPrint('Failed to save plant: ${response.body}');
          throw Exception('Failed to save plant: ${response.statusCode}');
        }
      } catch (e) {
        if (e.toString().contains('Failed to save plant') ||
            e.toString().contains('already saved')) {
          rethrow;
        }
      }
    }
    throw Exception('Unable to reach server to save plant.');
  }

  // Fetch all saved plants for the logged-in user
  static Future<List<dynamic>> fetchSavedPlants() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }

    for (final host in apiBaseUrls) {
      try {
        final response = await http
            .get(Uri.parse('$host/saved-plants/?user_id=$userId'))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          setWorkingBaseUrl(host);
          return jsonDecode(response.body);
        } else if (response.statusCode < 500) {
          setWorkingBaseUrl(host);
          debugPrint('Failed to fetch saved plants: ${response.body}');
          throw Exception('Failed to fetch saved plants: ${response.statusCode}');
        }
      } catch (e) {
        if (e.toString().contains('Failed to fetch saved plants')) {
          rethrow;
        }
      }
    }
    throw Exception('Unable to reach server to fetch saved plants.');
  }

  // Delete a saved plant
  static Future<void> deleteSavedPlant(int plantId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }

    for (final host in apiBaseUrls) {
      try {
        final response = await http
            .delete(Uri.parse('$host/saved-plants/$plantId/?user_id=$userId'))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 204) {
          setWorkingBaseUrl(host);
          return;
        } else if (response.statusCode < 500) {
          setWorkingBaseUrl(host);
          debugPrint('Failed to delete saved plant: ${response.body}');
          throw Exception('Failed to delete saved plant: ${response.statusCode}');
        }
      } catch (e) {
        if (e.toString().contains('Failed to delete saved plant')) {
          rethrow;
        }
      }
    }
    throw Exception('Unable to reach server to delete saved plant.');
  }
}
