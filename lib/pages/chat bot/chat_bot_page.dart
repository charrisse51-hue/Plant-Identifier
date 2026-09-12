import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../color/app_colors.dart';
import 'chat_bot_page_model.dart';

class ChatBotPage extends StatelessWidget {
  const ChatBotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatBotPageModel(),
      child: const _ChatBotPageView(),
    );
  }
}

class _ChatBotPageView extends StatelessWidget {
  const _ChatBotPageView();

  void _showImageSourceSheet(BuildContext context, ChatBotPageModel model) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A221C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attach Plant Photo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Chat-Bot AI will inspect leaves, pests, and growth conditions.',
                  style: TextStyle(
                    color: AppColors.surfaceA50,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          model.pickImage(ImageSource.camera);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF222C24),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2E3D34)),
                          ),
                          child: Column(
                            children: const [
                              Icon(LucideIcons.camera, color: Color(0xFF48CF88), size: 28),
                              SizedBox(height: 8),
                              Text(
                                'Take Photo',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          model.pickImage(ImageSource.gallery);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF222C24),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2E3D34)),
                          ),
                          child: Column(
                            children: const [
                              Icon(LucideIcons.image, color: Color(0xFF48CF88), size: 28),
                              SizedBox(height: 8),
                              Text(
                                'Choose Gallery',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmClearHistory(BuildContext context, ChatBotPageModel model) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2621),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Chat History?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will clear all messages in your current botanical conversation.',
          style: TextStyle(color: Colors.white70),
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
    final model = Provider.of<ChatBotPageModel>(context);
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return SafeArea(
      top: true,
      bottom: false,
      child: Column(
        children: [
          // ── Header Bar (Matching Reference Screenshot) ─────────────────
          Container(
            color: AppColors.surfaceA0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Botanical Sparkle / Leaf Container
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

                // Title & Subtitle with Online Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Chat-Bot",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
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
                          const Text(
                            "Online · Qwen 3.8 Vision",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFF86EFAC),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
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
                  "🪴 Easiest plants for beginners?",
                  () => model.sendMessage("What are the easiest indoor plants for beginners?"),
                ),
                _buildQuickChip(
                  "💧 How often should I water?",
                  () => model.sendMessage("How do I know how often to water my plants?"),
                ),
                _buildQuickChip(
                  "⚠️ Why are leaves turning yellow?",
                  () => model.sendMessage("Why are my plant's leaves turning yellow?"),
                ),
                _buildQuickChip(
                  "🌿 Pet-safe indoor plants?",
                  () => model.sendMessage("What are the best non-toxic, pet-safe houseplants?"),
                ),
                _buildQuickChip(
                  "🌱 How to propagate cuttings?",
                  () => model.sendMessage("How do I propagate plant cuttings in water?"),
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
                final imagePath = msg['imagePath'] as String?;
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
                              children: const [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF48CF88),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    "Analyzing botanical data & vision...",
                                    style: TextStyle(
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
                          if (imagePath != null && File(imagePath).existsSync()) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(imagePath),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                              ),
                            ),
                            if (text.isNotEmpty) const SizedBox(height: 8),
                          ],
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
                              if (imagePath != null && File(imagePath).existsSync()) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(imagePath),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 200,
                                  ),
                                ),
                                if (text.isNotEmpty) const SizedBox(height: 8),
                              ],
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

          // ── Selected Image Preview Box (Above Composer) ────────────────
          if (model.selectedImage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2621),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF48CF88).withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      model.selectedImage!,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Plant photo attached',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Ready for AI vision identification',
                          style: TextStyle(
                            color: Color(0xFF86EFAC),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                    onPressed: model.removeSelectedImage,
                  ),
                ],
              ),
            ),

          // Validation Error Alert
          if (model.validationError != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF441818),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEF5350).withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.alertCircle, color: Color(0xFFEF5350), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      model.validationError!,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  InkWell(
                    onTap: model.removeSelectedImage,
                    child: const Icon(Icons.close, color: Colors.white70, size: 16),
                  ),
                ],
              ),
            ),

          // ── Composer Input Bar [ 📷 ] [ Text ] [ ➤ ] ────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(10, 8, 10, isKeyboardOpen ? 6 : 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceA0,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Image Upload Button (Camera / Gallery)
                IconButton(
                  tooltip: 'Attach plant photo',
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF222824),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: model.selectedImage != null
                            ? const Color(0xFF48CF88)
                            : const Color(0xFF2E3D34),
                      ),
                    ),
                    child: Icon(
                      LucideIcons.image,
                      color: model.selectedImage != null
                          ? const Color(0xFF48CF88)
                          : AppColors.surfaceA80,
                      size: 19,
                    ),
                  ),
                  onPressed: model.isSending ? null : () => _showImageSourceSheet(context, model),
                ),

                const SizedBox(width: 4),

                // Text Input Field
                Expanded(
                  child: TextField(
                    controller: model.controller,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                    ),
                    decoration: InputDecoration(
                      hintText: model.selectedImage != null
                          ? 'Ask a question about this image...'
                          : 'Ask about watering, soil, pests...',
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

                // Send Button
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

  /// Parses markdown headings, bold text, numbered lists, and bullet points into clean, readable widgets.
  Widget _buildFormattedBotMessage(String rawText) {
    final lines = rawText.split('\n');
    final List<Widget> children = [];

    for (int i = 0; i < lines.length; i++) {
      final rawLine = lines[i];
      final line = rawLine.trim();
      if (line.isEmpty) {
        children.add(const SizedBox(height: 6));
        continue;
      }

      // Check if line is a numbered item (e.g. "1. Snake Plant" or "1. **Snake Plant**")
      final numMatch = RegExp(r'^(\d+)\.\s+(.*)').firstMatch(line);
      if (numMatch != null) {
        final numStr = numMatch.group(1)!;
        final textPart = numMatch.group(2)!;
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4, left: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$numStr. ",
                  style: const TextStyle(
                    color: Color(0xFF86EFAC),
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    height: 1.45,
                  ),
                ),
                Expanded(
                  child: _parseFormattedSpans(textPart),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Check if line is a bullet point (starts with •, -, or * )
      final isBullet = RegExp(r'^[-*•]\s+').hasMatch(line);
      if (isBullet) {
        final content = line.replaceFirst(RegExp(r'^[-*•]\s+'), '');
        final isIndented = rawLine.startsWith('   ') || rawLine.startsWith('\t') || rawLine.startsWith('  ');

        children.add(
          Padding(
            padding: EdgeInsets.only(
              bottom: 4,
              left: isIndented ? 20 : 6,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7, right: 8),
                  child: Icon(
                    Icons.circle,
                    size: isIndented ? 4 : 5,
                    color: isIndented
                        ? const Color(0xFF86EFAC).withValues(alpha: 0.85)
                        : const Color(0xFF48CF88),
                  ),
                ),
                Expanded(
                  child: _parseFormattedSpans(content),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Section Headings (e.g. 🌿 ..., 🔎 ..., ⚠️ ..., 🌱 ..., etc.)
      final isHeading = RegExp(r'^[🌿🔎⚠️🌱💧☀️🍂🍁🍃🥀🐛🐾🌑🪴🦟✨🔍]\s+').hasMatch(line) ||
          (line.startsWith('**') && line.endsWith('**') && line.length < 60);

      children.add(
        Padding(
          padding: EdgeInsets.only(
            top: isHeading ? 8 : 2,
            bottom: isHeading ? 6 : 4,
          ),
          child: _parseFormattedSpans(line),
        ),
      );
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
