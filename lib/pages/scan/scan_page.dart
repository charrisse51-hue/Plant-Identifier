import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'scan_page_model.dart';

class ScanPage extends StatefulWidget {
  final ImageProvider image;

  const ScanPage({super.key, required this.image});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage>
    with SingleTickerProviderStateMixin {
  late ScanPageModel _model;

  @override
  void initState() {
    super.initState();
    _model = ScanPageModel();
    _model.addListener(_onModelChange);
    _model.init(widget.image, context, this);
  }

  void _onModelChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _model.removeListener(_onModelChange);
    _model.dispose();
    super.dispose();
  }

  // ─── Stage info ─────────────────────────────────────────────────────────
  _StageInfo get _stageInfo {
    switch (_model.stage) {
      case ScanStage.compressing:
        return _StageInfo(
          icon: LucideIcons.fileImage,
          label: 'Preparing image…',
          subtitle: 'Optimizing for faster analysis',
          color: const Color(0xFF64B5F6),
        );
      case ScanStage.connecting:
        return _StageInfo(
          icon: LucideIcons.wifi,
          label: 'Connecting to server…',
          subtitle: 'Finding the fastest route',
          color: const Color(0xFF81C784),
        );
      case ScanStage.analyzing:
        return _StageInfo(
          icon: LucideIcons.brainCircuit,
          label: 'Analyzing plant…',
          subtitle: 'AI is identifying your plant',
          color: const Color(0xFFFFB74D),
        );
      case ScanStage.success:
        return _StageInfo(
          icon: LucideIcons.checkCircle2,
          label: 'Plant identified!',
          subtitle: 'Loading results…',
          color: const Color(0xFF66BB6A),
        );
      case ScanStage.error:
        return _StageInfo(
          icon: LucideIcons.alertCircle,
          label: 'Could not identify',
          subtitle: _model.errorMessage ?? 'Please try again',
          color: const Color(0xFFEF5350),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _stageInfo;
    final isScanning = _model.stage != ScanStage.error &&
        _model.stage != ScanStage.success;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B0E),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (_model.stage == ScanStage.error)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white70, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  const Spacer(),
                  Text(
                    'Plant Scanner',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  if (_model.stage == ScanStage.error) const SizedBox(width: 48),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Captured image with scan overlay ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // The captured image
                    AspectRatio(
                      aspectRatio: 3 / 4,
                      child: Image(
                        image: widget.image,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Dark overlay while scanning
                    if (isScanning)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.15),
                                Colors.black.withValues(alpha: 0.35),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Scan line animation
                    if (isScanning)
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _model.controller,
                          builder: (_, __) => CustomPaint(
                            painter: _ScanLinePainter(
                              progress: _model.controller.value,
                              color: info.color,
                            ),
                          ),
                        ),
                      ),

                    // Corner brackets
                    Positioned.fill(
                      child: _CornerBrackets(color: info.color),
                    ),

                    // Success checkmark
                    if (_model.stage == ScanStage.success)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.checkCircle2,
                          color: const Color(0xFF66BB6A),
                          size: 48,
                        ),
                      ),

                    // Error X
                    if (_model.stage == ScanStage.error)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFFEF5350),
                          size: 48,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Stage indicator ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  // Icon + spinner
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isScanning)
                        LoadingAnimationWidget.threeArchedCircle(
                          color: info.color,
                          size: 64,
                        ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: info.color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(info.icon, color: info.color, size: 20),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Stage label
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      info.label,
                      key: ValueKey(info.label),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Subtitle
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      info.subtitle,
                      key: ValueKey(info.subtitle),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Progress dots
                  if (isScanning) _StageDots(stage: _model.stage),

                  // Retry button on error
                  if (_model.stage == ScanStage.error) ...[
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Try Again',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      onPressed: () => _model.retry(context),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Go back',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Scan line painter ──────────────────────────────────────────────────────
class _ScanLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  const _ScanLinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;

    // Glow gradient line
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          color.withValues(alpha: 0.85),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, y - 2, size.width, 4));

    canvas.drawRect(Rect.fromLTWH(0, y - 2, size.width, 4), paint);

    // Soft fade below the line
    final fadePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, y - 40, size.width, 40));

    canvas.drawRect(Rect.fromLTWH(0, y - 40, size.width, 40), fadePaint);
  }

  @override
  bool shouldRepaint(_ScanLinePainter old) =>
      old.progress != progress || old.color != color;
}

// ─── Corner brackets ────────────────────────────────────────────────────────
class _CornerBrackets extends StatelessWidget {
  final Color color;
  const _CornerBrackets({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BracketPainter(color: color));
  }
}

class _BracketPainter extends CustomPainter {
  final Color color;
  const _BracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 28.0;
    const margin = 12.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(margin, margin + len)
        ..lineTo(margin, margin)
        ..lineTo(margin + len, margin),
      paint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - margin - len, margin)
        ..lineTo(size.width - margin, margin)
        ..lineTo(size.width - margin, margin + len),
      paint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(margin, size.height - margin - len)
        ..lineTo(margin, size.height - margin)
        ..lineTo(margin + len, size.height - margin),
      paint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - margin - len, size.height - margin)
        ..lineTo(size.width - margin, size.height - margin)
        ..lineTo(size.width - margin, size.height - margin - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(_BracketPainter old) => old.color != color;
}

// ─── Stage progress dots ────────────────────────────────────────────────────
class _StageDots extends StatelessWidget {
  final ScanStage stage;
  const _StageDots({required this.stage});

  int get _activeIndex {
    switch (stage) {
      case ScanStage.compressing:
        return 0;
      case ScanStage.connecting:
        return 1;
      case ScanStage.analyzing:
        return 2;
      default:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = i <= _activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF4CAF50)
                : Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ─── Stage info data class ───────────────────────────────────────────────────
class _StageInfo {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;

  const _StageInfo({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });
}
