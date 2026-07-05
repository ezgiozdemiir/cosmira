import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Deterministic star field using fixed seed positions — a shared cosmic
/// backdrop for full-bleed screens (Instagram Story exports, etc.).
class StarField extends StatelessWidget {
  const StarField({super.key});

  @override
  Widget build(BuildContext context) {
    final rng = math.Random(42);
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: List.generate(30, (i) {
          final x = rng.nextDouble() * constraints.maxWidth;
          final y = rng.nextDouble() * constraints.maxHeight;
          final size = rng.nextDouble() * 2.5 + 0.8;
          final opacity = rng.nextDouble() * 0.5 + 0.1;
          return Positioned(
            left: x,
            top: y,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      );
    });
  }
}
