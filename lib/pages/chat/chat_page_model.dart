import 'package:flutter/material.dart';
import '../../api/chat_api.dart';

class ChatPageModel extends ChangeNotifier {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ChatApi _api = ChatApi();

  bool isSending = false;
  String? _lastUserText;

  final String plantName;
  final String scientificName;

  ChatPageModel({required this.plantName, required this.scientificName}) {
    _addInitialBotMessage();
  }

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
          'Hello! I am your botanical guide for **$plantName** (*$scientificName*).\n\n'
          'Ask me about watering, sunlight, soil, propagation, or common issues!',
      'time': _formatCurrentTime(),
      'hasError': false,
    });
    notifyListeners();
  }

  void clearHistory() {
    _addInitialBotMessage();
    controller.clear();
    scrollToBottom();
  }

  void sendMessage([String? directText]) {
    if (isSending) return;
    final text = directText ?? controller.text.trim();
    if (text.isEmpty) return;

    _lastUserText = text;

    messages.add({
      'role': 'user',
      'text': text,
      'time': _formatCurrentTime(),
    });

    messages.add({
      'role': 'bot',
      'text': '',
      'time': _formatCurrentTime(),
      'hasError': false,
    });

    controller.clear();
    isSending = true;
    notifyListeners();

    scrollToBottom();
    _fetchBotReply(text);
  }

  Future<void> _fetchBotReply(String userText) async {
    final botIndex = messages.lastIndexWhere((msg) => msg['role'] == 'bot');

    try {
      final reply = await _api.sendMessage(
        message: userText,
        plantName: plantName,
        scientificName: scientificName,
      );

      if (botIndex != -1 && botIndex < messages.length) {
        messages[botIndex]['text'] = reply;
        messages[botIndex]['hasError'] = false;
      }
    } catch (e) {
      debugPrint('[ChatPageModel] Bot reply error: $e');
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

  void retryLastMessage() {
    if (isSending || _lastUserText == null) return;

    if (messages.isNotEmpty && messages.last['role'] == 'bot') {
      messages.removeLast();
    }

    messages.add({
      'role': 'bot',
      'text': '',
      'time': _formatCurrentTime(),
      'hasError': false,
    });

    isSending = true;
    notifyListeners();
    scrollToBottom();
    _fetchBotReply(_lastUserText!);
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
