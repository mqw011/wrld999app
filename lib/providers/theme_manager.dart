import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      _activeGenre?.primaryAccent ?? const Color(0xFF9C27B0);

  Color get secondaryAccent =>
      _activeGenre?.secondaryAccent ?? const Color(0xFF7C4DFF);

  Color get scaffoldBg => const Color(0xFF0D0D0D);

  Color get surfaceColor => const Color(0xFF1A1A1A);

  Color get cardColor => const Color(0xFF242424);

  Color get dividerColor => Colors.white.withValues(alpha: 0.08);

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
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        selectedColor: accent,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      textTheme: _buildTextTheme(),
      iconTheme: const IconThemeData(color: Colors.white70, size: 22),
      dividerTheme: DividerThemeData(color: dividerColor, thickness: 1),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scaffoldBg,
        selectedItemColor: accent,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  // ── Text theme ───────────────────────────────────────────
  TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Colors.white,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Colors.white70,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Colors.white54,
        letterSpacing: 0.5,
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────
  static Color _contrastTextColor(Color bg) {
    return bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  /// Returns a gradient suitable for genre hero headers.
  LinearGradient get heroGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryAccent.withValues(alpha: 0.6),
          secondaryAccent.withValues(alpha: 0.3),
          scaffoldBg,
        ],
        stops: const [0.0, 0.5, 1.0],
      );

  /// Returns a shimmer gradient for loading placeholders.
  LinearGradient get shimmerGradient => LinearGradient(
        colors: [
          cardColor,
          surfaceColor,
          cardColor,
        ],
      );
}
