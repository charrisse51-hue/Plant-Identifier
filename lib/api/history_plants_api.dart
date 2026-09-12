import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class HistoryPlantsApi {
  static String get baseUrl => apiBaseUrl;

  /// Fetch plant history for the logged-in user
  static Future<List<dynamic>> fetchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }

    for (final host in apiBaseUrls) {
      try {
        final response = await http
            .get(Uri.parse('$host/plant-history/?user_id=$userId'))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          setWorkingBaseUrl(host);
          return jsonDecode(response.body);
        } else if (response.statusCode < 500) {
          setWorkingBaseUrl(host);
          debugPrint('Failed to fetch history: ${response.body}');
          throw Exception('Failed to fetch plant history (${response.statusCode})');
        }
      } catch (e) {
        if (e.toString().contains('Failed to fetch plant history')) {
          rethrow;
        }
      }
    }
    throw Exception('Unable to reach server to fetch plant history.');
  }

  /// Save a newly identified plant to the user's history
  static Future<Map<String, dynamic>> saveHistory({
    required int speciesId,
    required String commonName,
    required String scientificName,
    double? confidence,
    String? imageUrl,
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
      'image_url': imageUrl ?? '',
    });

    for (final host in apiBaseUrls) {
      try {
        final response = await http
            .post(Uri.parse('$host/plant-history/'), headers: headers, body: body)
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 201) {
          setWorkingBaseUrl(host);
          return jsonDecode(response.body);
        } else if (response.statusCode < 500) {
          setWorkingBaseUrl(host);
          debugPrint('Failed to save history: ${response.body}');
          throw Exception('Failed to save plant history (${response.statusCode})');
        }
      } catch (e) {
        if (e.toString().contains('Failed to save plant history')) {
          rethrow;
        }
      }
    }
    throw Exception('Unable to reach server to save plant history.');
  }

  /// Delete a specific plant from history (optional if you add delete endpoint)
  static Future<void> deleteHistory(int historyId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }

    for (final host in apiBaseUrls) {
      try {
        final response = await http
            .delete(Uri.parse('$host/plant-history/$historyId/?user_id=$userId'))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 204) {
          setWorkingBaseUrl(host);
          return;
        } else if (response.statusCode < 500) {
          setWorkingBaseUrl(host);
          debugPrint('Failed to delete history: ${response.body}');
          throw Exception('Failed to delete plant history (${response.statusCode})');
        }
      } catch (e) {
        if (e.toString().contains('Failed to delete plant history')) {
          rethrow;
        }
      }
    }
    throw Exception('Unable to reach server to delete plant history.');
  }

  /// Delete all plant history for the current user
  static Future<void> deleteAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }

    for (final host in apiBaseUrls) {
      try {
        final response = await http
            .delete(Uri.parse('$host/plant-history/?user_id=$userId'))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 204) {
          setWorkingBaseUrl(host);
          return;
        } else if (response.statusCode < 500) {
          setWorkingBaseUrl(host);
          debugPrint('Failed to delete all history: ${response.body}');
          throw Exception('Failed to clear plant history (${response.statusCode})');
        }
      } catch (e) {
        if (e.toString().contains('Failed to clear plant history')) {
          rethrow;
        }
      }
    }
    throw Exception('Unable to reach server to clear plant history.');
  }

  /// Delete a selected list of history records by their IDs
  static Future<void> deleteSelectedHistory(List<int> ids) async {
    if (ids.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'user_id': userId,
      'ids': ids,
    });

    for (final host in apiBaseUrls) {
      try {
        final response = await http
            .delete(
              Uri.parse('$host/plant-history/'),
              headers: headers,
              body: body,
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 204) {
          setWorkingBaseUrl(host);
          return;
        } else if (response.statusCode < 500) {
          setWorkingBaseUrl(host);
          debugPrint('Failed to delete selected history: ${response.body}');
          throw Exception('Failed to delete selected plant history (${response.statusCode})');
        }
      } catch (e) {
        if (e.toString().contains('Failed to delete selected plant history')) {
          rethrow;
        }
      }
    }
    throw Exception('Unable to reach server to delete selected plant history.');
  }
}
