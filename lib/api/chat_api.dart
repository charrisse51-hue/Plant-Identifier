import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class ChatApi {
  /// Compresses the image before sending to ensure lightning-fast upload
  static Future<List<int>> _compressImage(File file) async {
    final pathLower = file.path.toLowerCase();
    final isJpeg = pathLower.endsWith('.jpg') || pathLower.endsWith('.jpeg');

    try {
      final result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: 800,
        minHeight: 800,
        quality: 85,
        format: isJpeg ? CompressFormat.jpeg : CompressFormat.png,
        keepExif: false,
      );
      if (result != null && result.isNotEmpty) {
        return result;
      }
    } catch (e) {
      debugPrint('[ChatApi] Image compression skipped: $e');
    }
    return await file.readAsBytes();
  }

  /// Sends a message (text-only, image-only, or image + text) to the Botanical AI Vision chat service.
  Future<String> sendMessage({
    required String message,
    File? imageFile,
    String? plantName,
    String? scientificName,
  }) async {
    Object? lastError;
    final hosts = apiBaseUrls;

    for (final baseUrl in hosts) {
      try {
        final uri = Uri.parse('$baseUrl/chat/');
        http.Response response;

        if (imageFile != null && await imageFile.exists()) {
          // Multipart upload with image
          final compressedBytes = await _compressImage(imageFile);
          final request = http.MultipartRequest('POST', uri);

          request.fields['message'] = message.isNotEmpty
              ? message
              : 'Please identify this plant, diagnose any visible issues, and give care tips.';
          if (plantName != null && plantName.isNotEmpty) {
            request.fields['plantName'] = plantName;
          }
          if (scientificName != null && scientificName.isNotEmpty) {
            request.fields['scientificName'] = scientificName;
          }

          final filename = imageFile.uri.pathSegments.isNotEmpty
              ? imageFile.uri.pathSegments.last
              : 'plant.jpg';

          request.files.add(
            http.MultipartFile.fromBytes(
              'image',
              compressedBytes,
              filename: filename,
            ),
          );

          final streamedResponse =
              await request.send().timeout(const Duration(seconds: 25));
          response = await http.Response.fromStream(streamedResponse);
        } else {
          // Text-only JSON request
          response = await http
              .post(
                uri,
                headers: const {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'message': message,
                  if (plantName != null) 'plantName': plantName,
                  if (scientificName != null) 'scientificName': scientificName,
                }),
              )
              .timeout(const Duration(seconds: 15));
        }

        final data = jsonDecode(response.body);
        if (response.statusCode >= 200 &&
            response.statusCode < 300 &&
            data is Map) {
          setWorkingBaseUrl(baseUrl);
          final reply = data['reply']?.toString().trim() ?? '';
          if (reply.isNotEmpty) return reply;
        }

        throw Exception(
          data is Map
              ? data['error'] ?? 'Chat request failed.'
              : 'Chat request failed.',
        );
      } catch (error) {
        lastError = error;
        debugPrint('[ChatApi] Host $baseUrl failed: $error');
      }
    }

    throw Exception(
      'Unable to contact the botanical AI service. Please check your network and server connection. (${lastError ?? ''})'
          .trim(),
    );
  }
}
