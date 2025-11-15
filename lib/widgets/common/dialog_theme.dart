// lib/widgets/common/dialog_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A class that provides consistent styling for dialogs throughout the app
class AppDialogTheme {
  // Constants for dialog styling
  static const double borderRadius = 16.0;
  static const EdgeInsets contentPadding = EdgeInsets.fromLTRB(24, 20, 24, 24);
  static const EdgeInsets actionsPadding = EdgeInsets.fromLTRB(24, 0, 24, 16);

  // Color scheme matching the group list header
  static const Color primaryDark = Color(0xFF0D1F2D);
  static const Color blueAccent = Color(0xFF2196F3);
  static const Color greenAccent = Color(0xFF4CAF50);
  static const Color backgroundColor = Color(0xFFFCF9F5);
  static const Color surfaceColor = Colors.white;

  // Animated dialog builder with enhanced animations
  static Widget animatedDialogBuilder(BuildContext context, Widget? child) {
    return child!
        .animate()
        .scale(
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
        )
        .fadeIn(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        )
        .slideY(
          begin: 0.1,
          end: 0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuart,
        );
  }

  // Enhanced dialog decoration with gradient and modern styling
  static BoxDecoration get dialogDecoration => BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: primaryDark.withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, 16),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: primaryDark.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      );

  // Header decoration with gradient
  static BoxDecoration getHeaderDecoration(Color accentColor) => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor,
            accentColor.withOpacity(0.8),
          ],
          stops: const [0.0, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  // Text styles with improved typography
  static TextStyle get headerTitleStyle => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.5,
      );

  static TextStyle get titleStyle => const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: primaryDark,
        letterSpacing: 0.3,
      );

  static TextStyle get contentStyle => TextStyle(
        fontSize: 16,
        color: primaryDark.withOpacity(0.7),
        height: 1.4,
        letterSpacing: 0.1,
      );

  static TextStyle get labelStyle => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryDark.withOpacity(0.8),
        letterSpacing: 0.2,
      );

  // Enhanced button styles
  static ButtonStyle getCancelButtonStyle() => TextButton.styleFrom(
        foregroundColor: primaryDark.withOpacity(0.7),
        minimumSize: const Size(120, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: primaryDark.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      );
  
  static ButtonStyle getConfirmButtonStyle(Color backgroundColor) => FilledButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: backgroundColor,
        minimumSize: const Size(120, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 4,
        shadowColor: backgroundColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      );
  
  // Enhanced input decoration with modern styling
  static InputDecoration getInputDecoration(String label, {IconData? prefixIcon, Color accentColor = blueAccent}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: primaryDark.withOpacity(0.6),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: prefixIcon != null
        ? Container(
            margin: const EdgeInsets.only(right: 12),
            child: Icon(
              prefixIcon,
              size: 22,
              color: accentColor.withOpacity(0.7),
            ),
          )
        : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: primaryDark.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: primaryDark.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: accentColor,
          width: 2.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2.5,
        ),
      ),
      filled: true,
      fillColor: backgroundColor.withOpacity(0.3),
      hintStyle: TextStyle(
        color: primaryDark.withOpacity(0.4),
        fontSize: 14,
      ),
    );
  }

  // Utility method for creating feature cards
  static Widget buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryDark.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
