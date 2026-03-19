import 'package:flutter/material.dart';

/// Central design tokens for spacing, radius, typography, shadows and gradients.
///
/// These values are the single source of truth for core UI primitives.
class AppTokens {
  AppTokens._();

  // Spacing
  static const double spaceXXS = 2;
  static const double spaceXS = 4;
  static const double spaceSM = 8;
  static const double spaceSMPlus = 12;
  static const double spaceMD = 16;
  static const double spaceMDPlus = 20;
  static const double spaceLG = 24;
  static const double spaceXL = 32;
  static const double space2XL = 48;

  // Radius
  static const double radiusSM = 8;
  static const double radiusMD = 12;
  static const double radiusLG = 16;
  static const double radiusXL = 20;
  static const double radiusFull = 999;

  // Typography
  static const double textXS = 11;
  static const double textSM = 13;
  static const double textMD = 15;
  static const double textMDPlus = 16;
  static const double textLG = 18;
  static const double textTitle = 20;
  static const double textXL = 22;
  static const double text2XL = 28;
  static const double text3XL = 32;
  static const double text4XL = 36;

  static const double lineHeightRelaxed = 1.5;
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingWide = 0.5;

  // Icon sizes
  static const double iconSM = 16;
  static const double iconMD = 22;

  // Elevation and border
  static const double elevationNone = 0;
  static const double borderThin = 1;

  // Opacity tokens
  static const double opacityDivider = 0.08;
  static const double opacityChipBorder = 0.12;
  static const double opacityTextMuted = 0.7;
  static const double opacityTextSubtle = 0.54;
  static const double opacityNavUnselected = 0.38;
  static const double opacityBreadcrumbIdle = 0.5;
  static const double opacityBreadcrumbChevron = 0.3;

  // Color tokens
  static const Color colorScaffoldBg = Color(0xFF0D0D0D);
  static const Color colorSurface = Color(0xFF1A1A1A);
  static const Color colorCard = Color(0xFF242424);

  static const Color fallbackPrimaryAccent = Color(0xFF9C27B0);
  static const Color fallbackSecondaryAccent = Color(0xFF7C4DFF);

  // Accessibility tokens
  static const double contrastLuminanceThreshold = 0.5;

  // Shadow tokens
  static const Color shadowColorSoft = Color(0x33000000);
  static const Color shadowColorStrong = Color(0x55000000);

  static const List<BoxShadow> shadowSoft = [
    BoxShadow(color: shadowColorSoft, blurRadius: 12, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> shadowStrong = [
    BoxShadow(color: shadowColorStrong, blurRadius: 20, offset: Offset(0, 10)),
  ];

  // Gradient tokens
  static const double heroGradientPrimaryAlpha = 0.6;
  static const double heroGradientSecondaryAlpha = 0.3;
  static const List<double> heroGradientStops = [0, 0.5, 1];

  static const Alignment heroGradientBegin = Alignment.topLeft;
  static const Alignment heroGradientEnd = Alignment.bottomRight;

  static const Alignment shimmerGradientBegin = Alignment.centerLeft;
  static const Alignment shimmerGradientEnd = Alignment.centerRight;

  static const List<double> shimmerGradientStops = [0.2, 0.5, 0.8];

  static LinearGradient heroGradient({
    required Color primaryAccent,
    required Color secondaryAccent,
    required Color scaffoldBg,
  }) {
    return LinearGradient(
      begin: heroGradientBegin,
      end: heroGradientEnd,
      colors: [
        primaryAccent.withValues(alpha: heroGradientPrimaryAlpha),
        secondaryAccent.withValues(alpha: heroGradientSecondaryAlpha),
        scaffoldBg,
      ],
      stops: heroGradientStops,
    );
  }

  static LinearGradient shimmerGradient({
    required Color cardColor,
    required Color surfaceColor,
  }) {
    return LinearGradient(
      begin: shimmerGradientBegin,
      end: shimmerGradientEnd,
      colors: [cardColor, surfaceColor, cardColor],
      stops: shimmerGradientStops,
    );
  }
}
