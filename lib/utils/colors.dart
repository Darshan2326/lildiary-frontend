import 'package:flutter/material.dart';

/// Centralized application color palette for LilDiary.
///
/// This file defines all brand colors, accents, surface colors, text colors,
/// badge styles, and gradients used across the LilDiary application.
class AppColors {
  AppColors._();

  // ==========================================
  // Brand & Primary Colors (Blues)
  // ==========================================

  /// Primary theme color (#81D4FA - Light Blue 200).
  /// Used for main theme primaryColor, active buttons, note details icons,
  /// recap banner background, and main action highlights.
  static const Color primary = Color(0xFF81D4FA);

  /// Primary sky blue (#4FC3F7 - Light Blue 300).
  /// Used for login & intro screen action buttons, active indicator dots,
  /// dialog submit buttons, and input focused borders.
  static const Color primarySky = Color(0xFF4FC3F7);

  /// Deep brand blue (#0288D1 - Light Blue 700).
  /// Used for profile screen action icons, dialog highlights, active recap
  /// selection states, and primary badge titles.
  static const Color primaryDark = Color(0xFF0288D1);

  /// Soft light blue (#B3E5FC - Light Blue 100).
  /// Used for dropdown borders and subtle blue dividers.
  static const Color primaryLight = Color(0xFFB3E5FC);

  /// Ice blue surface (#E1F5FE - Light Blue 50).
  /// Used for icon background chips in profile, active selection chips,
  /// and soft blue card containers.
  static const Color primaryBackground = Color(0xFFE1F5FE);

  /// Pale ice blue (#F1F9FE).
  /// Used for opened dropdown menu backgrounds and delicate item highlights.
  static const Color primarySurface = Color(0xFFF1F9FE);

  /// Soft lavender blue (#E3F2FD - Blue 50).
  /// Top gradient start color for the Memories screen background.
  static const Color softBlue = Color(0xFFE3F2FD);

  // ==========================================
  // Accent & Secondary Colors (Pinks & Rose)
  // ==========================================

  /// Secondary accent pink (#F48FB1 - Pink 200).
  /// Used for input field prefix icons (heart, diary, date), note tags,
  /// forgot password icons, and secondary buttons.
  static const Color secondaryPink = Color(0xFFF48FB1);

  /// Bottom navigation bar active color (#EEA3B8).
  /// Used for SalomonBottomBar selected items across the home navigation.
  static const Color navBarSelected = Color(0xFFEEA3B8);

  /// Soft pastel pink (#F1C6D4).
  /// Bottom gradient end color for Calendar and Landing Home screens.
  static const Color pastelPink = Color(0xFFF1C6D4);

  /// Soft pastel blue (#B4DCF1).
  /// Top gradient start color for Calendar and Landing Home screens.
  static const Color pastelBlue = Color(0xFFB4DCF1);

  /// Blush pink (#FCE4EC - Pink 50).
  /// Used for Memories screen bottom gradient and pastel frame badge background.
  static const Color blushPink = Color(0xFFFCE4EC);

  /// Deep magenta/pink (#C2185B - Pink 700).
  /// Used for pastel recap style badge text.
  static const Color deepPink = Color(0xFFC2185B);

  /// Vibrant pink (#E91E63 - Pink 500).
  /// Used for the "Vibrant" recap template badge.
  static const Color vibrantPink = Color(0xFFE91E63);

  // ==========================================
  // Recap Style & Music Palette Colors
  // ==========================================

  /// Light amber (#FFE082 - Amber 200).
  /// Start color for music avatar gradient.
  static const Color amberLight = Color(0xFFFFE082);

  /// Vibrant amber (#FFB300 - Amber 600).
  /// End color for music avatar gradient and star icons.
  static const Color amber = Color(0xFFFFB300);

  /// Soft amber tint (#FFF8E1 - Amber 50).
  /// Background for selected music chip in recap dialog.
  static const Color amberSoft = Color(0xFFFFF8E1);

  /// Warm peach (#FFF3E0 - Orange 50).
  /// Background for energetic/classic frame style badge.
  static const Color peach = Color(0xFFFFF3E0);

  /// Deep orange / rust (#E65100 - Orange 900).
  /// Text color for energetic/classic frame style badge.
  static const Color orangeDeep = Color(0xFFE65100);

  /// Vintage brown (#8D6E63 - Brown 400).
  /// Badge color for the "Vintage" recap template.
  static const Color vintageBrown = Color(0xFF8D6E63);

  /// Minimal blue-grey (#607D8B - Blue Grey).
  /// Badge color for the "Minimal" recap template.
  static const Color minimalGrey = Color(0xFF607D8B);

  // ==========================================
  // Neutral, Surface & Input Colors
  // ==========================================

  /// Form text field fill color (#EDF0F8).
  /// Used as standard background for text input fields across the app.
  static const Color inputFill = Color(0xFFEDF0F8);

  /// Light input fill / card background (#F5F5F5 - Grey 100).
  static const Color inputFillLight = Color(0xFFF5F5F5);

  /// Pure white (#FFFFFF).
  static const Color white = Colors.white;

  /// Pure black (#000000).
  static const Color black = Colors.black;

  /// Transparent color.
  static const Color transparent = Colors.transparent;

  /// Scaffold background color.
  static const Color scaffoldBackground = Colors.white;

  /// Card surface color.
  static const Color cardBackground = Colors.white;

  /// Standard divider and border color (#E0E0E0 - Grey 300).
  static const Color divider = Color(0xFFE0E0E0);

  /// Light border color (#EEEEEE - Grey 200).
  static const Color borderLight = Color(0xFFEEEEEE);

  // ==========================================
  // Typography & Text Colors
  // ==========================================

  /// Primary high-contrast text color (Colors.black87).
  static const Color textPrimary = Colors.black87;

  /// Secondary medium-contrast text color (Colors.black54).
  static const Color textSecondary = Colors.black54;

  /// Hint and placeholder text color (Colors.black38).
  static const Color textHint = Colors.black38;

  /// Disabled text and inactive indicator color (Colors.black26).
  static const Color textDisabled = Colors.black26;

  /// Subtle text / caption color (#757575 - Grey 600).
  static const Color textSubtle = Color(0xFF757575);

  /// Dark text / heading color (#424242 - Grey 800).
  static const Color textHeading = Color(0xFF424242);

  /// Light text color for dark backgrounds.
  static const Color textLight = Colors.white;

  // ==========================================
  // Status, Alert & Feedback Colors
  // ==========================================

  /// Error / danger color (#FF5252 - Red Accent).
  static const Color error = Colors.redAccent;

  /// Error solid red (#F44336 - Red).
  static const Color errorDark = Colors.red;

  /// Light red background for error banners (#FFEBEE - Red 50).
  static const Color errorBackground = Color(0xFFFFEBEE);

  /// Success green (#43A047 - Green 600).
  static const Color success = Color(0xFF43A047);

  /// Success light background (#E8F5E9 - Green 50).
  static const Color successBackground = Color(0xFFE8F5E9);

  /// Warning orange (#EF6C00 - Orange 800).
  static const Color warning = Color(0xFFEF6C00);

  /// Info blue (#1976D2 - Blue 700).
  static const Color info = Color(0xFF1976D2);

  /// Info light background (#E3F2FD - Blue 50).
  static const Color infoBackground = Color(0xFFE3F2FD);

  // ==========================================
  // App Gradients
  // ==========================================

  /// Main app background gradient used in LandingHomeScreen & CalendarScreen.
  /// Flows from pastel blue through white to pastel pink.
  static const LinearGradient homeBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomCenter,
    colors: [
      pastelBlue,
      white,
      pastelPink,
    ],
  );

  /// Memories screen background gradient.
  /// Flows from soft lavender blue through white to blush pink.
  static const LinearGradient memoriesBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      softBlue,
      white,
      blushPink,
    ],
  );

  /// Default avatar / music note gradient (Warm Amber).
  static const LinearGradient musicAvatarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      amberLight,
      amber,
    ],
  );

  /// Selected music avatar gradient (Brand Light Blue to Deep Blue).
  static const LinearGradient musicActiveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primary,
      primaryDark,
    ],
  );

  /// Profile header / subtle highlight gradient.
  static const LinearGradient profileHeaderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      primaryBackground,
      white,
    ],
  );
}

/// Convenience alias for [AppColors].
typedef LilDiaryColors = AppColors;
