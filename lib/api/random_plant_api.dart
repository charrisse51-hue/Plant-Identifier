import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class Plant {
  final int index;
  final int speciesId;
  final String commonName;
  final String scientificName;
  final String sampleImage;

  Plant({
    required this.index,
    required this.speciesId,
    required this.commonName,
    required this.scientificName,
    required this.sampleImage,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      index: json['index'] ?? 0,
      speciesId: json['species_id'] ?? 0,
      commonName: json['common_name'] ?? 'Unknown',
      scientificName: json['scientific_name'] ?? 'Unknown',
      sampleImage: json['sample_image'] ?? 'Not available',
    );
  }
}

class RandomPlantApi {
  static String get baseUrl => apiBaseUrl;

  static Future<http.Response> _getWithFallback(String endpoint) async {
    for (final baseUrl in apiBaseUrls) {
      final url = Uri.parse('$baseUrl$endpoint');
      try {
        final response = await http.get(url).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          setWorkingBaseUrl(baseUrl);
          return response;
        }
      } catch (_) {
        // Try the next host if this one is unreachable.
      }
    }
    throw Exception('Unable to reach backend on any configured host.');
  }

  static Future<List<Plant>> fetchRandomPlants() async {
    final response = await _getWithFallback('/random-plants/');

    final data = json.decode(response.body);

    // Expecting structure: { "plants": [ {...}, {...} ] }
    final List<dynamic> plantsJson = data['plants'] ?? [];

    return plantsJson.map((plant) => Plant.fromJson(plant)).toList();
  }
}
