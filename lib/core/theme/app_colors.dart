import 'package:flutter/material.dart';

class AppColors {
  // Brand Color Palette (Tolak Bencana - Figma Design System)
  static const Color primaryGreen = Color(0xFF15803D); // Primary (#15803D)
  static const Color primaryGreenHover = Color(0xFF166534); // Hover (#166534)
  static const Color primaryGreenPressed = Color(0xFF14532D); // Pressed (#14532D)
  static const Color primaryGreenLight = Color(0xFF16A34A); // Light (#16A34A)
  static const Color primaryGreenSubtle = Color(0xFFDCFCE7); // Subtle (#DCFCE7)
  static const Color primaryGreenSubtleStrong = Color(0xFFBBF7D0); // Subtle Strong (#BBF7D0)

  // Secondary Colors (Figma Yellow & Alert Orange)
  static const Color secondaryYellow = Color(0xFFF59E0B);
  static const Color secondaryYellowSubtle = Color(0xFFFEF9C3);
  static const Color secondaryOrange = Color(0xFFF97316); // Orange Warning (#F97316)
  static const Color secondaryOrangeSubtle = Color(0xFFFFEDD5);

  // Semantic Colors
  static const Color dangerRed = Color(0xFFDC2626); // Red for critical
  static const Color successGreen = Color(0xFF15803D); // Green for success/resolved
  static const Color infoBlue = Color(0xFF1E3A8A); // Blue for info/verified (#1E3A8A)

  // Neutrals
  static const Color backgroundLight = Color(0xFFF3F4F6);
  static const Color white = Colors.white;
  static const Color textDark = Color(0xFF0F172A);
  static const Color textLight = Color(0xFF64748B);
  static const Color borderSubtle = Color(0xFFE2E8F0);

  // Aliases for seamless compatibility with all existing views
  static const Color primaryTeal = primaryGreen;
  static const Color softTeal = primaryGreenSubtle;
  static const Color primaryBlue = primaryGreen;
  static const Color primaryBlueHover = primaryGreenHover;
  static const Color primaryBluePressed = primaryGreenPressed;
  static const Color primaryBlueLight = primaryGreenLight;
  static const Color primaryBlueSubtle = primaryGreenSubtle;
}
