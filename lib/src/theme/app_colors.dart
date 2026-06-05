import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const midnight = Color(0xFF050713);
  static const obsidian = Color(0xFF090B18);
  static const ink = Color(0xFF101425);
  static const glass = Color(0x2EFFFFFF);
  static const glassStrong = Color(0x4DFFFFFF);
  static const textPrimary = Color(0xFFF8FAFF);
  static const textSecondary = Color(0xFFB6C0D8);
  static const muted = Color(0xFF67718C);

  static const electricBlue = Color(0xFF2F80FF);
  static const indigo = Color(0xFF5B5CF6);
  static const purple = Color(0xFF8B5CF6);
  static const cyan = Color(0xFF20D9FF);
  static const emerald = Color(0xFF32F5A3);
  static const orange = Color(0xFFFFB545);
  static const pink = Color(0xFFFF4FD8);
  static const rose = Color(0xFFFF6B8B);
  static const lime = Color(0xFFC9FF4A);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [electricBlue, indigo, purple],
  );

  static const neonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cyan, electricBlue, pink, orange],
  );

  static const successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [emerald, cyan],
  );

  static const warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange, rose, pink],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3BFF), Color(0xFF872EFF), Color(0xFFFF4FD8)],
  );

  static const auroraBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF070A1B), Color(0xFF0B1027), Color(0xFF050713)],
  );
}
