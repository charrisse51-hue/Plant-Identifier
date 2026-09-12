import 'dart:io';
import 'package:flutter/material.dart';
import '../../api/api_config.dart';
import '../../api/efficientnetb3_api.dart';
import '../information/information_page.dart';
import '../unknown/unknown_page.dart';

enum ScanStage {
  compressing,
  connecting,
  analyzing,
  success,
  error,
}

class ScanPageModel extends ChangeNotifier {
  late AnimationController controller;
  ScanStage stage = ScanStage.compressing;
  String? errorMessage;

  late BuildContext _context;
  late ImageProvider _image;
  bool _disposed = false;

  void init(ImageProvider image, BuildContext context, TickerProvider vsync) {
    _image = image;
    _context = context;

    controller = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 2),
    )..repeat();

    analyzeImage();
  }

  void retry(BuildContext context) {
    _context = context;
    stage = ScanStage.compressing;
    errorMessage = null;
    notifyListeners();
    controller.repeat();
    analyzeImage();
  }

  Future<void> analyzeImage() async {
    try {
      File? imageFile;
      if (_image is FileImage) {
        imageFile = (_image as FileImage).file;
      } else {
        throw Exception('ScanPage only supports FileImage');
      }

      final result = await EfficientNetB3Api.predictPlant(
        imageFile,
        onStage: (s) {
          if (_disposed) return;
          if (s == 'compressing') {
            stage = ScanStage.compressing;
          } else if (s == 'connecting') {
            stage = ScanStage.connecting;
          } else if (s == 'analyzing') {
            stage = ScanStage.analyzing;
          }
          notifyListeners();
        },
      );

      if (_disposed) return;

      if (result.containsKey('error') && !result.containsKey('common_name')) {
        stage = ScanStage.error;
        errorMessage = result['error']?.toString() ?? 'Failed to connect to prediction server.';
        controller.stop();
        notifyListeners();
        return;
      }

      final sampleImageUrl = result['sample_image'] ?? '';
      final predictedIndex = result['predicted_index'] ?? -1;
      final speciesId = result['species_id'] ?? 0;
      final commonName = result['common_name'] ?? 'Unknown';
      final scientificName = result['scientific_name'] ?? 'Unknown';
      final confidence = (result['confidence'] is num)
          ? (result['confidence'] as num).toDouble() * (result['confidence'] <= 1.0 ? 100.0 : 1.0)
          : 0.0;

      if (confidence < 40.0 || commonName.toLowerCase() == 'unknown') {
        stage = ScanStage.error;
        errorMessage = 'No plant could be identified with sufficient confidence.';
        controller.stop();
        notifyListeners();

        Future.delayed(const Duration(milliseconds: 1400), () {
          if (!_disposed && _context.mounted) {
            Navigator.of(_context).pushReplacement(
              MaterialPageRoute(builder: (_) => const UnknownPage()),
            );
          }
        });
        return;
      }

      stage = ScanStage.success;
      controller.stop();
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 700));
      if (_disposed || !_context.mounted) return;

      final resolvedUrl = sampleImageUrl.isNotEmpty
          ? (sampleImageUrl.startsWith('http') ? sampleImageUrl : '$apiBaseUrl$sampleImageUrl')
          : imageFile.path;

      Navigator.of(_context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => InformationPage(
            imageUrl: resolvedUrl,
            predictedIndex: predictedIndex,
            speciesId: speciesId,
            commonName: commonName,
            scientificName: scientificName,
            confidence: confidence,
          ),
        ),
        (Route<dynamic> route) => route.isFirst,
      );
    } catch (e) {
      if (_disposed) return;
      stage = ScanStage.error;
      errorMessage = e.toString().replaceAll('Exception:', '').trim();
      controller.stop();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    controller.dispose();
    super.dispose();
  }
}
