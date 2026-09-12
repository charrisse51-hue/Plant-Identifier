import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class PlantDetailsApi {
  static const sectionTitles = [
    'Medical Use',
    'Culinary Use',
    'Cultural Significance',
    'Safety & Toxicity',
    'Ecological Role',
    'Cultivation Tips',
  ];

  /// Fetches plant details from the backend instantly.
  Future<Map<String, List<String>>> getDetails({
    required String commonName,
    required String scientificName,
  }) async {
    final payload = jsonEncode({
      'commonName': commonName,
      'scientificName': scientificName,
    });

    final primaryUrl = apiBaseUrl;
    // 1. Fast attempt with active working URL
    try {
      final res = await _postDetails(primaryUrl, payload)
          .timeout(const Duration(seconds: 4));
      if (res != null) return res;
    } catch (_) {
      // Fall through to probe all hosts
    }

    // 2. Parallel probe all hosts for maximum speed
    final hosts = apiBaseUrls;
    final completer = Completer<Map<String, List<String>>>();
    int pending = hosts.length;

    for (final host in hosts) {
      _postDetails(host, payload).then((res) {
        if (res != null && !completer.isCompleted) {
          setWorkingBaseUrl(host);
          completer.complete(res);
        } else {
          pending--;
          if (pending == 0 && !completer.isCompleted) {
            completer.completeError(
              Exception('Unable to load plant details from server.'),
            );
          }
        }
      }).catchError((_) {
        pending--;
        if (pending == 0 && !completer.isCompleted) {
          completer.completeError(
            Exception('Unable to load plant details from server.'),
          );
        }
      });
    }

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Connection timed out while loading details.'),
    );
  }

  Future<Map<String, List<String>>?> _postDetails(
    String host,
    String payload,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$host/explain-llm/'),
            headers: const {'Content-Type': 'application/json'},
            body: payload,
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setWorkingBaseUrl(host);
        final body = _decode(response.body);
        final explanation = body is Map<String, dynamic>
            ? body['explanation']?.toString() ?? ''
            : '';
        final details = _parseSections(explanation);
        if (details.values.any((items) => items.isNotEmpty)) {
          return details;
        }
      }
      return null;
    } catch (e) {
      debugPrint('[PlantDetailsApi] Failed on $host: $e');
      return null;
    }
  }

  dynamic _decode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  Map<String, List<String>> _parseSections(String explanation) {
    final details = {for (final title in sectionTitles) title: <String>[]};
    String? currentTitle;
    for (final rawLine in explanation.split('\n')) {
      final line = rawLine.trim();
      final heading = line
          .replaceAll('*', '')
          .replaceAll(':', '')
          .trim()
          .toLowerCase();
      currentTitle = _headingToTitle(heading) ?? currentTitle;
      if (currentTitle != null && RegExp(r'^[-*•]\s+').hasMatch(line)) {
        final item = line.replaceFirst(RegExp(r'^[-*•]\s+'), '').trim();
        if (item.isNotEmpty) details[currentTitle]!.add(item);
      }
    }
    return details;
  }

  String? _headingToTitle(String heading) {
    switch (heading) {
      case 'medicinal uses':
      case 'medicinal use':
      case 'medical uses':
      case 'medical use':
        return 'Medical Use';
      case 'culinary uses':
      case 'culinary use':
        return 'Culinary Use';
      case 'cultural significance':
        return 'Cultural Significance';
      case 'toxicity risks':
      case 'toxicity risk':
      case 'safety & toxicity':
      case 'safety and toxicity':
        return 'Safety & Toxicity';
      case 'ecological role':
        return 'Ecological Role';
      case 'cultivation tips':
      case 'cultivation tip':
        return 'Cultivation Tips';
      default:
        return null;
    }
  }
}
