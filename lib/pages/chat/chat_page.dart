import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../color/app_colors.dart';
import 'chat_page_model.dart';

class ChatPage extends StatelessWidget {
  final String plantName;
  final String scientificName;

  const ChatPage({
    super.key,
    required this.plantName,
    required this.scientificName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatPageModel(
        plantName: plantName,
        scientificName: scientificName,
      ),
      child: const _ChatPageView(),
    );
  }
}

class _ChatPageView extends StatelessWidget {
  const _ChatPageView();

  void _confirmClearHistory(BuildContext context, ChatPageModel model) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2621),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Chat History?', style: TextStyle(color: Colors.white)),
        content: Text(
          'This will clear all messages in your conversation about ${model.plantName}.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              model.clearHistory();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ChatPageModel>();
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.surfaceA0,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: true,
        bottom: !isKeyboardOpen,
        child: Column(
          children: [
            // ── Header Bar ────────────────────────────────────────────────
            Container(
              color: AppColors.surfaceA0,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      LucideIcons.arrowLeft,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 2),

                  // Botanical Leaf / Bot Container
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E40).withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF48CF88).withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Icon(
                      LucideIcons.bot,
                      color: Color(0xFF48CF88),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Plant Name & Online Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          model.plantName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF48CF88),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                "${model.scientificName} · Online",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF86EFAC),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Clear Chat History (Trash Button)
                  IconButton(
                    tooltip: 'Clear conversation',
                    icon: const Icon(
                      LucideIcons.trash2,
                      color: Color(0xFFEF5350),
                      size: 20,
                    ),
                    onPressed: () => _confirmClearHistory(context, model),
                  ),
                ],
              ),
            ),

            // ── Quick Suggestion Chips ──────────────────────────────────────
            Container(
              height: 44,
              color: AppColors.surfaceA0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                children: [
                  _buildQuickChip(
                    "💧 How often to water?",
                    () => model.sendMessage("How often should I water ${model.plantName}?"),
                  ),
                  _buildQuickChip(
                    "☀️ Sunlight needs?",
                    () => model.sendMessage("What kind of sunlight does ${model.plantName} need?"),
                  ),
                  _buildQuickChip(
                    "🌱 Best soil & potting?",
                    () => model.sendMessage("What soil mix and pot type are best for ${model.plantName}?"),
                  ),
                  _buildQuickChip(
                    "⚠️ Common pests & diseases?",
                    () => model.sendMessage("What are common pests or issues for ${model.plantName}?"),
                  ),
                  _buildQuickChip(
                    "🌿 How to propagate?",
                    () => model.sendMessage("How do I propagate cuttings of ${model.plantName}?"),
                  ),
                  _buildQuickChip(
                    "💊 Uses & benefits?",
                    () => model.sendMessage("What are the medicinal or practical uses of ${model.plantName}?"),
                  ),
                ],
              ),
            ),

            Container(height: 1, color: AppColors.surfaceA30.withValues(alpha: 0.6)),

            // ── Chat Messages List ──────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                controller: model.scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                itemCount: model.messages.length,
                itemBuilder: (context, index) {
                  final msg = model.messages[index];
                  final isUser = msg['role'] == 'user';
                  final text = (msg['text'] ?? '').toString();
                  final time = (msg['time'] ?? '').toString();
                  final hasError = msg['hasError'] == true;

                  // Typing indicator
                  if (text.isEmpty && !isUser) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBotAvatar(),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E2621),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFF2E3D34)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF48CF88),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      "Analyzing botanical data for ${model.plantName}...",
                                      style: const TextStyle(
                                        color: Color(0xFF86EFAC),
                                        fontSize: 12.5,
                                        fontStyle: FontStyle.italic,
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

                  // User message bubble (aligned right, no avatar)
                  if (isUser) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.82,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B5E40),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                            bottomLeft: Radius.circular(14),
                            bottomRight: Radius.circular(4),
                          ),
                          border: Border.all(
                            color: const Color(0xFF2A7E56),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (text.isNotEmpty)
                              Text(
                                text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.5,
                                  height: 1.4,
                                ),
                              ),
                            if (time.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  time,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  // AI message bubble with bot avatar on the left
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBotAvatar(),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E2621),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(14),
                                topRight: Radius.circular(14),
                                bottomLeft: Radius.circular(4),
                                bottomRight: Radius.circular(14),
                              ),
                              border: Border.all(
                                color: const Color(0xFF2E3D34),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (text.isNotEmpty) _buildFormattedBotMessage(text),
                                if (hasError) ...[
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      minimumSize: const Size(0, 32),
                                    ),
                                    icon: const Icon(Icons.refresh, size: 15),
                                    label: const Text('Retry', style: TextStyle(fontSize: 12)),
                                    onPressed: model.retryLastMessage,
                                  ),
                                ],
                                if (time.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      time,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.4),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Composer Input Bar (Text-only, No photo uploading) ────────
            Container(
              color: AppColors.surfaceA0,
              padding: EdgeInsets.only(
                left: 14,
                right: 14,
                top: 8,
                bottom: isKeyboardOpen ? 8 : 14,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: model.controller,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ask about ${model.plantName}...',
                        hintStyle: TextStyle(
                          color: AppColors.surfaceA50.withValues(alpha: 0.8),
                          fontSize: 13.5,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF222824),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 11,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(color: Color(0xFF2E3D34)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(color: Color(0xFF2E3D34)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Color(0xFF48CF88),
                            width: 1.5,
                          ),
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onTap: model.scrollToBottom,
                      onSubmitted: (_) => model.sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF1B5E40),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      iconSize: 20,
                      icon: model.isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(LucideIcons.send, color: Colors.white),
                      onPressed: model.isSending ? null : () => model.sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFE2E8F0),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF1A231D),
        side: const BorderSide(color: Color(0xFF2E3D34)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: onTap,
      ),
    );
  }

  /// Small emerald green botanical/robot avatar shown to the left of AI messages.
  Widget _buildBotAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF10B981),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Icon(
          LucideIcons.bot,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  /// Parses markdown headings, bold text, bullet points into clean, readable widgets.
  Widget _buildFormattedBotMessage(String rawText) {
    final lines = rawText.split('\n');
    final List<Widget> children = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        children.add(const SizedBox(height: 6));
        continue;
      }

      final isBullet = RegExp(r'^[-*•]\s+').hasMatch(line) ||
          RegExp(r'^\d+\.\s+').hasMatch(line);

      if (isBullet) {
        final content = line
            .replaceFirst(RegExp(r'^[-*•]\s+'), '')
            .replaceFirst(RegExp(r'^\d+\.\s+'), '');

        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 7, right: 8),
                  child: Icon(
                    Icons.circle,
                    size: 5,
                    color: Color(0xFF48CF88),
                  ),
                ),
                Expanded(
                  child: _parseFormattedSpans(content),
                ),
              ],
            ),
          ),
        );
      } else {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _parseFormattedSpans(line),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  /// Parses **bold** and *italic* markdown segments into styled spans.
  Widget _parseFormattedSpans(String text) {
    final List<InlineSpan> spans = [];
    final regex = RegExp(r'(\*\*.*?\*\*|\*.*?\*)');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 14.5,
              height: 1.45,
            ),
          ),
        );
      }

      final token = match.group(0)!;
      if (token.startsWith('**') && token.endsWith('**')) {
        final inner = token.substring(2, token.length - 2);
        spans.add(
          TextSpan(
            text: inner,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF86EFAC),
              fontSize: 14.5,
              height: 1.45,
            ),
          ),
        );
      } else if (token.startsWith('*') && token.endsWith('*')) {
        final inner = token.substring(1, token.length - 1);
        spans.add(
          TextSpan(
            text: inner,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Color(0xFFCBD5E1),
              fontSize: 14.5,
              height: 1.45,
            ),
          ),
        );
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex),
          style: const TextStyle(
            color: Color(0xFFE2E8F0),
            fontSize: 14.5,
            height: 1.45,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
