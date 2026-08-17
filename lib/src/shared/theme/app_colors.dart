import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Hues - Refined Deep Sea Emerald & Mint Mist
  static const Color primary = Color(0xFF0F766E); // Deep Sea Emerald
  static const Color primaryDark = Color(0xFF115E59); // Rich Pine
  static const Color primaryLight = Color(0xFFE0F2F1); // Mint Mist
  static const Color primaryAccent = Color(0xFF14B8A6); // Vibrant Turquoise

  // Secondary & Accent Hues
  static const Color secondary = Color(0xFF0284C7); // Mediterranean Sky Blue
  static const Color accent = Color(0xFF0F172A); // Midnight Obsidian
  static const Color warmAmber = Color(0xFFF59E0B); // Golden Hour Sun
  static const Color coral = Color(0xFFF43F5E); // Tropical Sunset Coral
  static const Color purpleAccent = Color(0xFF8B5CF6); // Royalty Purple

  // Semantic Feedback Colors
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Rose Red
  static const Color info = Color(0xFF3B82F6); // Bright Sky Blue

  // Modern Neutral Palette (Clean, Crisp, Apple-like)
  static const Color background = Color(0xFFF8FAFC); // Canvas Slate
  static const Color cardBackground = Colors.white; // Pure Card Surface
  static const Color surfaceSubtle = Color(0xFFF1F5F9); // Subtle Container Fill
  static const Color textPrimary = Color(0xFF0F172A); // Obsidian Black
  static const Color textSecondary = Color(0xFF475569); // Slate Graphite
  static const Color textLight = Color(0xFF94A3B8); // Muted Slate
  static const Color textMuted = Color(0xFFCBD5E1); // Ultra Light Muted

  // Layout Borders & Dividers
  static const Color border = Color(0xFFE2E8F0); // Subtle Line Border
  static const Color borderLight = Color(0xFFF1F5F9); // Ultra Subtle Border
  static const Color divider = Color(0xFFF1F5F9);
  static const Color shadow = Color(0x0C0F172A); // Soft Diffused Ambient Shadow
  static const Color shadowMedium = Color(0x180F172A);

  // Frosted Glass Overlays
  static const Color glassFill = Color(0xDDFFFFFF);
  static const Color glassFillDark = Color(0xCC0F172A);
  static const Color glassBorder = Color(0x40FFFFFF);

  // Modern Linear Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F766E), Color(0xFF0369A1)],
  );

  static const LinearGradient goldPassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF34D399), success],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF7E5F), Color(0xFFFEB47B)],
  );
}
