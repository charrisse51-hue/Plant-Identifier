import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class OllamaApi {
  static final List<String> _baseUrls = ollamaBaseUrls;
  final String baseUrl;

  OllamaApi({String? baseUrl}) : baseUrl = (baseUrl == null || baseUrl.isEmpty) ? ollamaBaseUrl : baseUrl;

  factory OllamaApi.withDefaultUrl() {
    return OllamaApi(baseUrl: ollamaBaseUrl);
  }

  Future<http.Response> _postWithFallback(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    for (final base in _baseUrls) {
      final url = Uri.parse('$base$endpoint');
      try {
        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 10));
        return response;
      } catch (_) {
        // Try next host.
      }
    }
    throw Exception('Unable to reach Ollama on any configured host.');
  }

  Future<String> sendPrompt({
    required String model,
    required String prompt,
  }) async {
    final response = await _postWithFallback(
      '/api/generate',
      {
        'model': model,
        'prompt': prompt,
        'stream': false,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['response'] ?? '').toString().trim();
    } else {
      throw Exception(
        'Ollama API error: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Stream<String> streamPrompt({
    required String model,
    required String prompt,
  }) async* {
    for (final base in _baseUrls) {
      final url = Uri.parse('$base/api/generate');
      final request = http.Request('POST', url)
        ..headers.addAll({'Content-Type': 'application/json'})
        ..body = jsonEncode({
          'model': model,
          'prompt': prompt,
          'stream': true,
        });

      final client = http.Client();
      try {
        final streamedResponse = await client.send(request);
        if (streamedResponse.statusCode != 200) {
          continue;
        }

        await for (var chunk in streamedResponse.stream.transform(utf8.decoder)) {
          for (var line in chunk.split('\n')) {
            if (line.trim().isEmpty) continue;
            try {
              final data = jsonDecode(line);
              if (data['response'] != null) {
                yield data['response'].toString();
              }
            } catch (_) {
              // Ignore malformed chunks.
            }
          }
        }
        return;
      } catch (_) {
        continue;
      } finally {
        client.close();
      }
    }

    throw Exception('Unable to reach Ollama on any configured host.');
  }
}
