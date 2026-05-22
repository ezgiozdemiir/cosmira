import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/breathwork_provider.dart';

class BreathingCircle extends StatefulWidget {
  final BreathPhase phase;
  final bool isActive;

  const BreathingCircle({
    super.key,
    required this.phase,
    required this.isActive,
  });

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant BreathingCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.phase != oldWidget.phase) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    switch (widget.phase) {
      case BreathPhase.inhale:
        _controller.forward();
      case BreathPhase.exhale:
        _controller.reverse();
      case BreathPhase.hold:
      case BreathPhase.holdOut:
        _controller.stop();
      case BreathPhase.idle:
      case BreathPhase.complete:
        _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Container(
          width: 200 * _scaleAnimation.value,
          height: 200 * _scaleAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.accentGlow.withOpacity(0.4),
                AppColors.auraViolet.withOpacity(0.2),
                Colors.transparent,
              ],
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: AppColors.accentGlow.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Container(
              width: 100 * _scaleAnimation.value,
              height: 100 * _scaleAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentGlow.withOpacity(0.3),
                border: Border.all(
                  color: AppColors.accentGlow.withOpacity(0.6),
                  width: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
