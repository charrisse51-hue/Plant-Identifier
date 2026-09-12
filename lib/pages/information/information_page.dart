import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_projects/color/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api_config.dart';
import '../../api/history_plants_api.dart';
import '../../api/plant_details_api.dart';
import '../../api/saved_plants_api.dart';
import '../chat/chat_page.dart';

class InformationPage extends StatefulWidget {
  final String imageUrl;
  final int predictedIndex;
  final int speciesId;
  final String commonName;
  final String scientificName;
  final double? confidence;

  const InformationPage({
    super.key,
    required this.imageUrl,
    required this.predictedIndex,
    required this.speciesId,
    required this.commonName,
    required this.scientificName,
    this.confidence,
  });

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 0.0;

  late final String fullImageUrl = widget.imageUrl.startsWith('/media')
      ? '$apiBaseUrl${widget.imageUrl}'
      : widget.imageUrl;

  final GlobalKey _medicalKey = GlobalKey();
  final GlobalKey _culinaryKey = GlobalKey();
  final GlobalKey _culturalKey = GlobalKey();
  final GlobalKey _safetyKey = GlobalKey();
  final GlobalKey _ecologicalKey = GlobalKey();
  final GlobalKey _cultivationKey = GlobalKey();

  final PlantDetailsApi _plantDetailsApi = PlantDetailsApi();

  bool _isSaving = false;

  Map<String, List<String>> sectionData = {};
  Map<String, bool> sectionLoading = {};
  String? _detailsError;

  bool _isDisposed = false;

  bool get _allSectionsLoaded =>
      sectionLoading.values.every((loading) => loading == false);

  bool _snackBarVisible = false;

  @override
  void initState() {
    super.initState();

    debugPrint('--- Plant Data ---');
    debugPrint('Common Name: ${widget.commonName}');
    debugPrint('Scientific Name: ${widget.scientificName}');
    debugPrint('Species ID: ${widget.speciesId}');
    debugPrint('Predicted Index: ${widget.predictedIndex}');
    debugPrint('Confidence: ${widget.confidence}');
    debugPrint('Image URL: ${widget.imageUrl}');
    debugPrint('-------------------');

    _loadUserId();

    _saveToHistoryAutomatically();

    _scrollController.addListener(() {
      double offset = _scrollController.offset;
      double opacity = (offset / 300).clamp(0, 1);
      if (opacity != _appBarOpacity) {
        setState(() {
          _appBarOpacity = opacity;
        });
      }
    });

    _precacheImage();
    _fetchAllSections();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;
    debugPrint('--- User Data ---');
    debugPrint('User ID: $userId');
    debugPrint('-------------------');
  }

  Future<void> _saveToHistoryAutomatically() async {
    try {
      await HistoryPlantsApi.saveHistory(
        speciesId: widget.speciesId,
        commonName: widget.commonName,
        scientificName: widget.scientificName,
        confidence: widget.confidence,
        imageUrl: widget.imageUrl,
      );
      debugPrint('Plant automatically saved to history.');
    } catch (e) {
      debugPrint('Failed to save plant to history automatically: $e');
    }
  }

  void _showLoadingSnackBar() {
    if (!_snackBarVisible) {
      _snackBarVisible = true;
      IconSnackBar.show(
        context,
        duration: const Duration(seconds: 3),
        snackBarType: SnackBarType.fail,
        label: 'Please wait for information to finish',
        labelTextStyle: const TextStyle(color: Colors.white),
      );
      Future.delayed(const Duration(seconds: 2), () {
        _snackBarVisible = false;
      });
    }
  }

  void _showSaveResultSnackBar({required bool success, required String message}) {
    if (!mounted || _snackBarVisible) return;
    _snackBarVisible = true;
    IconSnackBar.show(
      context,
      snackBarType: success ? SnackBarType.success : SnackBarType.fail,
      label: message,
      labelTextStyle: const TextStyle(color: Colors.white),
    );
    Future.delayed(const Duration(seconds: 2), () {
      _snackBarVisible = false;
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _precacheImage() async {
    try {
      if (fullImageUrl.startsWith('http://') || fullImageUrl.startsWith('https://')) {
        await precacheImage(NetworkImage(fullImageUrl), context);
      } else if (widget.imageUrl.isNotEmpty && File(widget.imageUrl).existsSync()) {
        await precacheImage(FileImage(File(widget.imageUrl)), context);
      }
    } catch (_) {
      // Image precache error is non-fatal
    }
  }

  Widget _buildHeaderImage() {
    if (fullImageUrl.startsWith('http://') || fullImageUrl.startsWith('https://')) {
      return Image.network(
        fullImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/plant_logo.png',
            fit: BoxFit.contain,
          );
        },
      );
    } else if (widget.imageUrl.isNotEmpty && File(widget.imageUrl).existsSync()) {
      return Image.file(
        File(widget.imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/plant_logo.png',
            fit: BoxFit.contain,
          );
        },
      );
    } else {
      return Image.asset(
        'assets/images/plant_logo.png',
        fit: BoxFit.contain,
      );
    }
  }

  Future<void> _fetchAllSections() async {
    await _fetchDetailsFromServer();
  }

  Future<void> _fetchDetailsFromServer() async {
    final titles = PlantDetailsApi.sectionTitles;
    setState(() {
      _detailsError = null;
      sectionData = {};
      sectionLoading = {for (final title in titles) title: true};
    });

    try {
      final details = await _plantDetailsApi.getDetails(
        commonName: widget.commonName,
        scientificName: widget.scientificName,
      );
      if (_isDisposed) return;
      setState(() {
        sectionData = details;
        sectionLoading = {for (final title in titles) title: false};
      });
    } catch (error) {
      if (_isDisposed) return;
      setState(() {
        _detailsError = error.toString().replaceFirst('Exception: ', '');
        sectionLoading = {for (final title in titles) title: false};
      });
    }
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox;

      final scrollableBox =
          _scrollController.position.context.storageContext.findRenderObject()
              as RenderBox;
      final viewportHeight = scrollableBox.size.height;

      final widgetOffset = box
          .localToGlobal(Offset.zero, ancestor: scrollableBox)
          .dy;

      final targetOffset =
          _scrollController.offset +
          widgetOffset -
          (viewportHeight / 2) +
          (box.size.height / 2);

      _scrollController.animateTo(
        targetOffset.clamp(
          _scrollController.position.minScrollExtent,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildTagButton(String label, {required VoidCallback onPressed}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceA10,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: InkWell(
        onTap: onPressed,
        child: Text(
          label,
          style: const TextStyle(color: AppColors.primaryDark10, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildSection(
    Key key,
    IconData icon,
    String title,
    List<String>? bulletPoints,
  ) {
    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceA10,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryDark10, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_detailsError != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "•  ",
                  style: TextStyle(fontSize: 14, color: AppColors.surfaceA50),
                ),
                Expanded(
                  child: Text(
                    "Details could not be loaded. Tap a category above to retry.",
                    style: TextStyle(fontSize: 14, color: AppColors.surfaceA50),
                  ),
                ),
              ],
            )
          else if (sectionLoading[title] == true)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(1, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "•  ",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.surfaceA50,
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: DefaultTextStyle(
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.surfaceA50,
                            ),
                            child: AnimatedTextKit(
                              repeatForever: true,
                              pause: const Duration(milliseconds: 500),
                              animatedTexts: [
                                TyperAnimatedText(
                                  'Loading $title...',
                                  speed: const Duration(milliseconds: 100),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            )
          else if (bulletPoints != null)
            ...bulletPoints.map(
              (point) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "•  ",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.surfaceA50,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.surfaceA50,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            LucideIcons.arrowLeft,
            size: 28,
            color: AppColors.surfaceA80,
          ),
        ),
        backgroundColor: AppColors.surfaceA0.withValues(alpha: _appBarOpacity),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            children: [
              Container(
                color: AppColors.surfaceA10,
                height: 300,
                width: double.infinity,
                child: _buildHeaderImage(),
              ),
              Container(
                color: AppColors.surfaceA0,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 5),
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.commonName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.scientificName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: AppColors.surfaceA50,
                              ),
                            ),
                            if (widget.confidence != null) ...[
                              const SizedBox(height: 8),
                              _ConfidenceBadge(confidence: widget.confidence!),
                            ],
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              [
                                'Medical Use',
                                'Culinary Use',
                                'Cultural Significance',
                                'Safety & Toxicity',
                                'Ecological Role',
                                'Cultivation Tips',
                              ].map((category) {
                                return _buildTagButton(
                                  category,
                                  onPressed: () {
                                    if (_detailsError != null) {
                                      _fetchAllSections();
                                      return;
                                    }
                                    switch (category) {
                                      case 'Medical Use':
                                        _scrollToSection(_medicalKey);
                                        break;
                                      case 'Culinary Use':
                                        _scrollToSection(_culinaryKey);
                                        break;
                                      case 'Cultural Significance':
                                        _scrollToSection(_culturalKey);
                                        break;
                                      case 'Safety & Toxicity':
                                        _scrollToSection(_safetyKey);
                                        break;
                                      case 'Ecological Role':
                                        _scrollToSection(_ecologicalKey);
                                        break;
                                      case 'Cultivation Tips':
                                        _scrollToSection(_cultivationKey);
                                        break;
                                    }
                                  },
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                    _buildSection(
                      _medicalKey,
                      Icons.local_hospital,
                      'Medical Use',
                      sectionData['Medical Use'],
                    ),
                    _buildSection(
                      _culinaryKey,
                      Icons.restaurant,
                      'Culinary Use',
                      sectionData['Culinary Use'],
                    ),
                    _buildSection(
                      _culturalKey,
                      Icons.public,
                      'Cultural Significance',
                      sectionData['Cultural Significance'],
                    ),
                    _buildSection(
                      _safetyKey,
                      Icons.warning,
                      'Safety & Toxicity',
                      sectionData['Safety & Toxicity'],
                    ),
                    _buildSection(
                      _ecologicalKey,
                      Icons.eco,
                      'Ecological Role',
                      sectionData['Ecological Role'],
                    ),
                    _buildSection(
                      _cultivationKey,
                      Icons.grass,
                      'Cultivation Tips',
                      sectionData['Cultivation Tips'],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [AppColors.surfaceA0, Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _isSaving
                    ? null // Disable button while saving
                    : () async {
                        if (_isSaving) return;
                        setState(() => _isSaving = true);

                        try {
                          await SavedPlantsApi.savePlant(
                            speciesId: widget.speciesId,
                            commonName: widget.commonName,
                            scientificName: widget.scientificName,
                            confidence: widget.confidence,
                            imageUrl: widget.imageUrl,
                          );

                          _showSaveResultSnackBar(
                            success: true,
                            message: 'Plant saved successfully!',
                          );
                        } catch (e) {
                          _showSaveResultSnackBar(
                            success: false,
                            message: 'Plant already saved',
                          );
                        } finally {
                          if (mounted) {
                            setState(() => _isSaving = false);
                          }
                        }
                      },
                child: const Text(
                  "Save to My Plants",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 50,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                  backgroundColor: AppColors.primaryDark10,
                ),
                onPressed: () {
                  if (!_allSectionsLoaded) {
                    _showLoadingSnackBar();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          plantName: widget.commonName,
                          scientificName: widget.scientificName,
                        ),
                      ),
                    );
                  }
                },
                child: const Icon(Icons.chat, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A visual confidence score badge with colored progress bar
class _ConfidenceBadge extends StatelessWidget {
  final double confidence;
  const _ConfidenceBadge({required this.confidence});

  Color get _color {
    if (confidence >= 75) return Colors.green;
    if (confidence >= 50) return Colors.amber.shade700;
    return Colors.redAccent;
  }

  String get _label {
    if (confidence >= 75) return 'High Confidence';
    if (confidence >= 50) return 'Medium Confidence';
    return 'Low Confidence';
  }

  IconData get _icon {
    if (confidence >= 75) return Icons.check_circle_outline_rounded;
    if (confidence >= 50) return Icons.info_outline_rounded;
    return Icons.warning_amber_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _color.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon, color: _color, size: 16),
              const SizedBox(width: 6),
              Text(
                _label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _color,
                ),
              ),
              const Spacer(),
              Text(
                '${confidence.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: confidence / 100.0,
              minHeight: 6,
              backgroundColor: _color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(_color),
            ),
          ),
        ],
      ),
    );
  }
}
