import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class EfficientNetB3Api {
  // ─── Image compression ───────────────────────────────────────────────────
  /// Compress the image to max 800px and JPEG 85% quality before upload.
  /// This turns a ~2 MB camera file into ~100-200 KB, cutting upload time
  /// dramatically over Wi-Fi.
  static Future<Uint8List> _compressImage(File file) async {
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
        debugPrint(
          '[EfficientNetB3Api] Compressed: ${file.lengthSync()} B → ${result.length} B '
          '(${((1 - result.length / file.lengthSync()) * 100).toStringAsFixed(0)}% smaller)',
        );
        return result;
      }
    } catch (e) {
      debugPrint('[EfficientNetB3Api] Compression failed, using original: $e');
    }
    // Fallback — send raw bytes
    return await file.readAsBytes();
  }

  // ─── Single-host attempt ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> _tryHost(
    String host,
    Uint8List imageBytes,
    String filename,
  ) async {
    try {
      final uri = Uri.parse('$host/predict/');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: filename,
          ),
        );

      final streamed = await request.send().timeout(const Duration(seconds: 12));
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        setWorkingBaseUrl(host);
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode < 500) {
        // Client-side error — server is reachable, record it
        setWorkingBaseUrl(host);
        return {
          'error': 'Server responded with ${response.statusCode}: ${response.body}',
        };
      }
      return null; // 5xx — try next host
    } catch (_) {
      return null; // timeout / unreachable — try next host
    }
  }

  // ─── Parallel probe ───────────────────────────────────────────────────────
  /// Probes all known hosts in parallel and returns the result of whichever
  /// responds first. This avoids waiting up to 20 s × N hosts sequentially.
  static Future<Map<String, dynamic>> predictPlant(
    File imageFile, {
    void Function(String stage)? onStage,
  }) async {
    onStage?.call('compressing');
    final imageBytes = await _compressImage(imageFile);
    final filename = imageFile.uri.pathSegments.last;

    onStage?.call('connecting');
    final hosts = apiBaseUrls;

    // Kick off all hosts simultaneously, collect the first success
    final completer = Completer<Map<String, dynamic>>();
    int pending = hosts.length;

    for (final host in hosts) {
      _tryHost(host, imageBytes, filename).then((result) {
        if (result != null && !completer.isCompleted) {
          completer.complete(result);
        } else {
          pending--;
          if (pending == 0 && !completer.isCompleted) {
            completer.complete({'error': 'Unable to reach any prediction server.'});
          }
        }
      });
    }

    onStage?.call('analyzing');
    return completer.future;
  }
}
