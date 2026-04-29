import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF00695C); // Deep Tropical Teal
  static const Color primaryLight = Color(0xFFE0F2F1);
  static const Color secondary = Color(0xFF4CA1AF); // Ocean Blue
  static const Color accent = Color(0xFF2C3E50); // Midnight Blue

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Rose Red
  static const Color info = Color(0xFF3B82F6); // Bright Blue

  // Neutral Palette
  static const Color background = Color(0xFFF8FAFC); // Soft Slate
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B); // Dark Slate
  static const Color textSecondary = Color(0xFF64748B); // Slate Grey
  static const Color textLight = Color(0xFF94A3B8);
  
  // Layout Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color shadow = Color(0x0D000000);

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, accent],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF34D399), success],
  );
}
