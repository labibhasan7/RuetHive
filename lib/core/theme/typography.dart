
import 'package:flutter/material.dart';

TextTheme buildTextTheme(ColorScheme scheme) {
  return TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: scheme.onSurface,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.5,
      color: scheme.onSurface,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.4,
      color: scheme.onSurfaceVariant,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: scheme.primary,
    ),
  );
}