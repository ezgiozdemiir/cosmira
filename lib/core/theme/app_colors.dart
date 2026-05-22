import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary palette
  static const Color midnight = Color(0xFF0B1026);
  static const Color black = Color(0xFF000000);
  static const Color deepPurple = Color(0xFF2D1B69);
  static const Color softIndigo = Color(0xFF4B3F72);
  static const Color accentGlow = Color(0xFF7B68EE);

  // Surface
  static const Color surface = Color(0xFF111827);
  static const Color card = Color(0xFF1A1A2E);
  static const Color cardBorder = Color(0x26FFFFFF); // 15% white

  // Text
  static const Color textPrimary = Color(0xE6FFFFFF); // 90%
  static const Color textSecondary = Color(0x99FFFFFF); // 60%
  static const Color textTertiary = Color(0x4DFFFFFF); // 30%

  // Semantic
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFF60A5FA);

  // Aura colors
  static const Color auraViolet = Color(0xFF8B5CF6);
  static const Color auraIndigo = Color(0xFF6366F1);
  static const Color auraTeal = Color(0xFF2DD4BF);
  static const Color auraRose = Color(0xFFFB7185);
  static const Color auraAmber = Color(0xFFFBBF24);
  static const Color auraEmerald = Color(0xFF34D399);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [midnight, black],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1AFFFFFF),
      Color(0x0DFFFFFF),
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentGlow, deepPurple],
  );

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7B68EE),
      Color(0xFF4B3F72),
      Color(0xFF2D1B69),
    ],
  );
}
