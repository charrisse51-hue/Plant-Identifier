import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../api/chat_api.dart';

class ChatBotPageModel extends ChangeNotifier {
  final ChatApi _api = ChatApi();
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, dynamic>> messages = [];
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool isSending = false;
  File? selectedImage;
  String? validationError;

  // Stored for retry capability
  String? _lastUserText;
  File? _lastUserImage;

  ChatBotPageModel() {
    _addInitialBotMessage();
  }

  /// Format timestamp like "5:11 PM"
  static String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour == 0 ? 12 : (now.hour > 12 ? now.hour - 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void _addInitialBotMessage() {
    messages.clear();
    messages.add({
      'role': 'bot',
      'text':
          'Hello! I am your AI Chat-Bot powered by Qwen 3.8 Vision. '
          'Ask me any plant care question, or attach a photo for diagnosis!',
      'time': _formatCurrentTime(),
    });
    notifyListeners();
  }

  /// Pick image from camera or gallery
  Future<void> pickImage(ImageSource source) async {
    validationError = null;
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
      );

      if (picked == null) {
        // User cancelled selection - no crash, no change
        return;
      }

      final file = File(picked.path);
      final pathLower = file.path.toLowerCase();

      // Validate supported format: jpg, jpeg, png, webp
      final isSupported = pathLower.endsWith('.jpg') ||
          pathLower.endsWith('.jpeg') ||
          pathLower.endsWith('.png') ||
          pathLower.endsWith('.webp');

      if (!isSupported) {
        validationError =
            'Unsupported format. Please select a JPG, PNG, or WEBP photo.';
        notifyListeners();
        return;
      }

      // Validate file size: limit to 12 MB
      final fileSizeBytes = await file.length();
      if (fileSizeBytes > 12 * 1024 * 1024) {
        validationError =
            'Photo is too large (over 12MB). Please select a smaller photo.';
        notifyListeners();
        return;
      }

      selectedImage = file;
      validationError = null;
      notifyListeners();
    } catch (e) {
      debugPrint('[ChatBotPageModel] Error picking image: $e');
      validationError = 'Could not access photo. Please check permissions.';
      notifyListeners();
    }
  }

  /// Remove currently selected image preview
  void removeSelectedImage() {
    selectedImage = null;
    validationError = null;
    notifyListeners();
  }

  /// Clear entire chat history
  void clearHistory() {
    _addInitialBotMessage();
    selectedImage = null;
    validationError = null;
    controller.clear();
    scrollToBottom();
  }

  /// Send message (Text-only, Image-only, or Image + Text)
  void sendMessage([String? directText]) {
    if (isSending) return;

    final text = directText ?? controller.text.trim();
    final imageToSend = selectedImage;

    // Must have either text or image
    if (text.isEmpty && imageToSend == null) return;

    _lastUserText = text;
    _lastUserImage = imageToSend;

    // Add user message to history
    messages.add({
      'role': 'user',
      'text': text,
      'imagePath': imageToSend?.path,
      'time': _formatCurrentTime(),
    });

    // Add bot placeholder for typing indicator
    messages.add({
      'role': 'bot',
      'text': '',
      'time': _formatCurrentTime(),
      'hasError': false,
    });

    controller.clear();
    selectedImage = null;
    validationError = null;
    isSending = true;
    notifyListeners();

    scrollToBottom();
    _fetchBotReply(text, imageToSend);
  }

  Future<void> _fetchBotReply(String userText, File? imageFile) async {
    final botIndex = messages.lastIndexWhere((msg) => msg['role'] == 'bot');

    try {
      final reply = await _api.sendMessage(
        message: userText,
        imageFile: imageFile,
      );

      if (botIndex != -1 && botIndex < messages.length) {
        messages[botIndex]['text'] = reply;
        messages[botIndex]['hasError'] = false;
      }
    } catch (e) {
      debugPrint('[ChatBotPageModel] Bot reply error: $e');
      if (botIndex != -1 && botIndex < messages.length) {
        messages[botIndex]['text'] =
            '⚠️ I could not process the request. Please check that the server is running and tap Retry.';
        messages[botIndex]['hasError'] = true;
      }
    } finally {
      isSending = false;
      notifyListeners();
      scrollToBottom();
    }
  }

  /// Retry the last failed message
  void retryLastMessage() {
    if (isSending) return;
    if (_lastUserText == null && _lastUserImage == null) return;

    // Remove the error bot bubble
    if (messages.isNotEmpty && messages.last['role'] == 'bot') {
      messages.removeLast();
    }

    // Re-add bot placeholder
    messages.add({
      'role': 'bot',
      'text': '',
      'time': _formatCurrentTime(),
      'hasError': false,
    });

    isSending = true;
    notifyListeners();
    scrollToBottom();
    _fetchBotReply(_lastUserText ?? '', _lastUserImage);
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
