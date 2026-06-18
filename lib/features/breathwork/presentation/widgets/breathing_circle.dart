import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/breathwork_provider.dart';

class BreathingCircle extends StatefulWidget {
  final BreathPhase phase;
  final bool isActive;
  final int phaseSeconds;

  const BreathingCircle({
    super.key,
    required this.phase,
    required this.isActive,
    this.phaseSeconds = 4,
  });

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle>
    with TickerProviderStateMixin {
  // Main size controller: 0.0 = small (exhaled), 1.0 = large (inhaled)
  late final AnimationController _expandCtrl;
  // Organic wobble: drives slight rx/ry asymmetry during inhale/exhale
  late final AnimationController _wobbleCtrl;
  // Continuous wave offset for hold surface ripple
  late final AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();
    _expandCtrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: math.max(1, widget.phaseSeconds)),
    );
    _wobbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // Set the correct starting position for the current phase.
    // This matters when the widget is recreated mid-session because the
    // parent Column's children list changes length on isActive toggle.
    _expandCtrl.value = switch (widget.phase) {
      BreathPhase.inhale => 0.0,           // will grow to 1
      BreathPhase.hold || BreathPhase.exhale => 1.0, // already expanded
      _ => 0.2,                            // idle dim sphere
    };

    // Start the animation for the current phase once the widget is mounted.
    // didUpdateWidget is never called for freshly created widgets, so this
    // handles the recreation case.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateAnimation();
    });
  }

  @override
  void didUpdateWidget(covariant BreathingCircle old) {
    super.didUpdateWidget(old);
    if (widget.phase != old.phase) _updateAnimation();
  }

  void _updateAnimation() {
    final secs = math.max(1, widget.phaseSeconds);
    _expandCtrl.duration = Duration(seconds: secs);

    switch (widget.phase) {
      case BreathPhase.inhale:
        // Always start from 0 so the first inhale reliably grows from small
        _expandCtrl.value = 0.0;
        _expandCtrl.animateTo(
          1.0,
          duration: Duration(seconds: secs),
          curve: Curves.easeInOut,
        );
        if (!_wobbleCtrl.isAnimating) _wobbleCtrl.repeat(reverse: true);
        _waveCtrl.stop();
      case BreathPhase.exhale:
        // Always start from 1 so exhale reliably shrinks from full
        _expandCtrl.value = 1.0;
        _expandCtrl.animateTo(
          0.0,
          duration: Duration(seconds: secs),
          curve: Curves.easeInOut,
        );
        if (!_wobbleCtrl.isAnimating) _wobbleCtrl.repeat(reverse: true);
        _waveCtrl.stop();
      case BreathPhase.hold:
      case BreathPhase.holdOut:
        _expandCtrl.stop();
        _wobbleCtrl.stop();
        if (!_waveCtrl.isAnimating) _waveCtrl.repeat();
      case BreathPhase.complete:
        _expandCtrl.animateTo(0.0, duration: const Duration(seconds: 2));
        _wobbleCtrl.stop();
        _waveCtrl.stop();
      case BreathPhase.idle:
        _expandCtrl.animateTo(0.2, duration: const Duration(milliseconds: 800));
        _wobbleCtrl.stop();
        _waveCtrl.stop();
    }
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    _wobbleCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_expandCtrl, _wobbleCtrl, _waveCtrl]),
      builder: (_, __) => CustomPaint(
        size: const Size(280, 280),
        painter: _SpherePainter(
          expand: _expandCtrl.value,
          wobble: _wobbleCtrl.value,
          wave: _waveCtrl.value,
          phase: widget.phase,
          isActive: widget.isActive,
        ),
      ),
    );
  }
}

class _SpherePainter extends CustomPainter {
  final double expand;
  final double wobble;
  final double wave;
  final BreathPhase phase;
  final bool isActive;

  const _SpherePainter({
    required this.expand,
    required this.wobble,
    required this.wave,
    required this.phase,
    required this.isActive,
  });

  bool get _isHold => phase == BreathPhase.hold || phase == BreathPhase.holdOut;
  bool get _isMoving => phase == BreathPhase.inhale || phase == BreathPhase.exhale;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final maxR = size.width * 0.43;
    final minR = size.width * 0.18;
    final r = minR + (maxR - minR) * expand;

    if (r < 4) return;

    // Asymmetric wobble: slight oval deformation during inhale/exhale
    final wobbleAmt = _isMoving ? (wobble - 0.5) * 0.1 : 0.0;
    final rx = r * (1.0 + wobbleAmt);
    final ry = r * (1.0 - wobbleAmt * 0.6);

    _drawOuterGlow(canvas, c, r);
    _drawSphere(canvas, c, rx, ry, r);
    _drawHighlight(canvas, c, r);
  }

  void _drawOuterGlow(Canvas canvas, Offset c, double r) {
    // Two-layer soft glow ring
    canvas.drawCircle(
      c,
      r * 1.9,
      Paint()
        ..color = AppColors.auraViolet.withValues(alpha: 0.12)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.7),
    );
    canvas.drawCircle(
      c,
      r * 1.35,
      Paint()
        ..color = AppColors.accentGlow.withValues(alpha: 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.35),
    );
  }

  void _drawSphere(Canvas canvas, Offset c, double rx, double ry, double r) {
    final path = _isHold ? _wavyPath(c, r) : _smoothPath(c, rx, ry);

    // Shader rect slightly larger than sphere to give gradient room to breathe
    final rect = Rect.fromCenter(
      center: c,
      width: rx * 2.4,
      height: ry * 2.4,
    );

    // Radial gradient offset to upper-left → 3D lit-from-top-left illusion
    final bodyPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.36, -0.40),
        radius: 1.22,
        colors: [
          Color(0xCCFFFFFF),      // bright specular core
          Color(0xFF2DD4BF),      // auraTeal
          Color(0xFF8B5CF6),      // auraViolet
          Color(0xFF2D1B69),      // deepPurple
          Color(0xFF0B1026),      // midnight
        ],
        stops: [0.0, 0.20, 0.55, 0.82, 1.0],
      ).createShader(rect);

    canvas.drawPath(path, bodyPaint);

    // Subtle rim light (edge glow gives the sphere a floating look)
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = AppColors.auraTeal.withValues(alpha: 0.40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  // Smooth ellipse path for inhale/exhale (slight organic rx vs ry)
  Path _smoothPath(Offset c, double rx, double ry) {
    final path = Path();
    const steps = 120;
    for (int i = 0; i <= steps; i++) {
      final a = (i / steps) * 2 * math.pi;
      final x = c.dx + rx * math.cos(a);
      final y = c.dy + ry * math.sin(a);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    return path..close();
  }

  // Wavy path for hold: sine harmonics flow around the perimeter
  Path _wavyPath(Offset c, double r) {
    final path = Path();
    const steps = 240;
    final offset = wave * 2 * math.pi;
    for (int i = 0; i <= steps; i++) {
      final a = (i / steps) * 2 * math.pi;
      final perturbation = r *
          (0.038 * math.sin(7 * a + offset) +
              0.024 * math.sin(5 * a - offset * 0.8) +
              0.015 * math.sin(11 * a + offset * 1.4));
      final radius = r + perturbation;
      final x = c.dx + radius * math.cos(a);
      final y = c.dy + radius * math.sin(a);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    return path..close();
  }

  void _drawHighlight(Canvas canvas, Offset c, double r) {
    if (r < 18) return;

    // Soft primary highlight blob — upper-left
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx - r * 0.26, c.dy - r * 0.29),
        width: r * 0.62,
        height: r * 0.37,
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.26)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.12),
    );

    // Sharp specular point — tiny bright glint
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx - r * 0.30, c.dy - r * 0.33),
        width: r * 0.19,
        height: r * 0.12,
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.70)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.04),
    );
  }

  @override
  bool shouldRepaint(covariant _SpherePainter old) =>
      old.expand != expand ||
      old.wobble != wobble ||
      old.wave != wave ||
      old.phase != phase;
}
