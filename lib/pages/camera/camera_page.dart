import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/color/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../scan/scan_page.dart';
import '../snaptips/snaptips_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  bool _isInitialized = false;

  bool _isFlashOn = false;
  bool _isChangingFlash = false;

  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;

  final ImagePicker _picker = ImagePicker();

  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera([int cameraIndex = 0]) async {
    _cameras ??= await availableCameras();
    _selectedCameraIndex = cameraIndex;

    _controller = CameraController(
      _cameras![_selectedCameraIndex],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _toggleFlash() async {
    if (_isChangingFlash) return;

    setState(() {
      _isFlashOn = !_isFlashOn;
      _isChangingFlash = true;
    });

    try {
      await _controller.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    } finally {
      setState(() {
        _isChangingFlash = false;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    int newIndex = (_selectedCameraIndex + 1) % _cameras!.length;

    setState(() {
      _isInitialized = false;
      _isFlashOn = false;
    });

    await _controller.dispose();
    await _initializeCamera(newIndex);
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      final File selectedImage = File(image.path);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScanPage(image: FileImage(selectedImage)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: _isInitialized
          ? SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            _isFlashOn
                                ? LucideIcons.zap300
                                : LucideIcons.zapOff300,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: _toggleFlash,
                        ),
                        IconButton(
                          icon: Icon(
                            LucideIcons.switchCamera300,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: _switchCamera,
                        )
                      ]),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CameraPreview(_controller),
                    Icon(
                      LucideIcons.scan100,
                      color: Colors.white,
                      size: 350,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.photo_rounded,
                                color: AppColors.surfaceA80,
                              ),
                              iconSize: 28,
                              onPressed: _pickImageFromGallery,
                            ),
                            Text(
                              "Photos",
                              style: TextStyle(
                                  color: AppColors.surfaceA60,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(2),
                            elevation: 6,
                            backgroundColor: Colors.white,
                          ),
                          child: const Icon(
                            LucideIcons.circle200,
                            size: 60,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            if (!_isInitialized || _isTakingPicture) {
                              return;
                            }

                            setState(() {
                              _isTakingPicture = true;
                            });

                            try {
                              final XFile picture =
                                  await _controller.takePicture();

                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ScanPage(
                                        image: FileImage(File(picture.path))),
                                  ),
                                );
                              }
                            } catch (e) {
                              debugPrint('Error taking picture: $e');
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isTakingPicture = false;
                                });
                              }
                            }
                          },
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.help,
                                color: AppColors.surfaceA80,
                              ),
                              iconSize: 28,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const SnapTipsPage()),
                                );
                              },
                            ),
                            Text(
                              "Snap Tips",
                              style: TextStyle(
                                  color: AppColors.surfaceA60,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ]),
                ),
              )
            ],
          ),
        ),
      )
          : Container(color: AppColors.surfaceA0),
    );
  }
}
