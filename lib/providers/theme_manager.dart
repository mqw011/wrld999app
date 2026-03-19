import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/app_tokens.dart';
import '../models/genre.dart';

/// Manages dynamic theming based on the active genre.
/// The Scaffold background, AppBar, and accent colors all react
/// to whichever genre hub the user is currently viewing.
class ThemeManager extends ChangeNotifier {
  // ── Current genre state ──────────────────────────────────
  Genre? _activeGenre;

  Genre? get activeGenre => _activeGenre;

  void setActiveGenre(Genre? genre) {
    if (_activeGenre?.id != genre?.id) {
      _activeGenre = genre;
      notifyListeners();
    }
  }

  // ── Derived colors ───────────────────────────────────────
  Color get primaryAccent =>
      _activeGenre?.primaryAccent ?? AppTokens.fallbackPrimaryAccent;

  Color get secondaryAccent =>
      _activeGenre?.secondaryAccent ?? AppTokens.fallbackSecondaryAccent;

  Color get scaffoldBg => AppTokens.colorScaffoldBg;

  Color get surfaceColor => AppTokens.colorSurface;

  Color get cardColor => AppTokens.colorCard;

  Color get dividerColor =>
      Colors.white.withValues(alpha: AppTokens.opacityDivider);

  // ── Theme Data ───────────────────────────────────────────
  ThemeData get themeData {
    final accent = primaryAccent;
    final secondary = secondaryAccent;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: secondary,
        surface: surfaceColor,
        onPrimary: _contrastTextColor(accent),
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: Colors.white,
        elevation: AppTokens.elevationNone,
        scrolledUnderElevation: AppTokens.elevationNone,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: AppTokens.textTitle,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: AppTokens.elevationNone,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLG),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        selectedColor: accent,
        labelStyle: GoogleFonts.inter(
          fontSize: AppTokens.textSM,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusXL),
        ),
        side: BorderSide(
          color: Colors.white.withValues(alpha: AppTokens.opacityChipBorder),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spaceSMPlus,
          vertical: AppTokens.spaceXS + AppTokens.spaceXXS,
        ),
      ),
      textTheme: _buildTextTheme(),
      iconTheme: const IconThemeData(
        color: Colors.white70,
        size: AppTokens.iconMD,
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: AppTokens.borderThin,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scaffoldBg,
        selectedItemColor: accent,
        unselectedItemColor: Colors.white.withValues(
          alpha: AppTokens.opacityNavUnselected,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: AppTokens.elevationNone,
      ),
    );
  }

  // ── Text theme ───────────────────────────────────────────
  TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: AppTokens.text3XL,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: AppTokens.letterSpacingTight,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: AppTokens.text2XL,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: AppTokens.textXL,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: AppTokens.textLG,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: AppTokens.textMDPlus,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: AppTokens.textMD,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: AppTokens.textMD,
        fontWeight: FontWeight.w400,
        color: Colors.white,
        height: AppTokens.lineHeightRelaxed,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: AppTokens.textSM,
        fontWeight: FontWeight.w400,
        color: Colors.white.withValues(alpha: AppTokens.opacityTextMuted),
        height: AppTokens.lineHeightRelaxed,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: AppTokens.textMD,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: AppTokens.textXS,
        fontWeight: FontWeight.w500,
        color: Colors.white.withValues(alpha: AppTokens.opacityTextSubtle),
        letterSpacing: AppTokens.letterSpacingWide,
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────
  static Color _contrastTextColor(Color bg) {
    return bg.computeLuminance() > AppTokens.contrastLuminanceThreshold
        ? Colors.black
        : Colors.white;
  }

  /// Returns a gradient suitable for genre hero headers.
  LinearGradient get heroGradient => AppTokens.heroGradient(
    primaryAccent: primaryAccent,
    secondaryAccent: secondaryAccent,
    scaffoldBg: scaffoldBg,
  );

  /// Returns a shimmer gradient for loading placeholders.
  LinearGradient get shimmerGradient => AppTokens.shimmerGradient(
    cardColor: cardColor,
    surfaceColor: surfaceColor,
  );
}
