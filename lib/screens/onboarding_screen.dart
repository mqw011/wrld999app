import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/design/app_tokens.dart';
import '../models/genre.dart';
import '../providers/navigation_provider.dart';
import '../providers/theme_manager.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  static const Color _baseBg = Color(0xFF0A0A0F);

  final Set<String> _selectedGenreIds = <String>{};

  late final AnimationController _introController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fade = CurvedAnimation(parent: _introController, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, AppTokens.spaceSM / AppTokens.space2XL),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _introController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  void _toggleGenre(String id) {
    setState(() {
      if (_selectedGenreIds.contains(id)) {
        _selectedGenreIds.remove(id);
      } else {
        _selectedGenreIds.add(id);
      }
    });
  }

  void _continue() {
    if (_selectedGenreIds.isEmpty) {
      return;
    }
    context.read<NavigationProvider>().completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeManager tm = context.watch<ThemeManager>();
    final List<Genre> genres = Genre.allGenres;
    final Color onSurface = tm.themeData.colorScheme.onSurface;

    final Genre? selectedGenre = genres.cast<Genre?>().firstWhere(
          (Genre? genre) => genre != null && _selectedGenreIds.contains(genre.id),
          orElse: () => null,
        );

    final Color primaryGlow = selectedGenre?.primaryAccent ?? tm.primaryAccent;
    final Color secondaryGlow = selectedGenre?.secondaryAccent ?? tm.secondaryAccent;

    return Scaffold(
      backgroundColor: _baseBg,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  _baseBg,
                  primaryGlow.withValues(alpha: AppTokens.opacityDivider * (AppTokens.spaceSM / AppTokens.spaceXXS)),
                  _baseBg,
                ],
                stops: const <double>[
                  AppTokens.spaceXS / AppTokens.spaceMD,
                  AppTokens.spaceSM / AppTokens.spaceMD,
                  AppTokens.spaceSMPlus / AppTokens.spaceMD,
                ],
              ),
            ),
          ),
          Positioned(
            top: -AppTokens.space2XL,
            right: -AppTokens.space2XL,
            child: IgnorePointer(
              child: Container(
                width: AppTokens.space2XL * (AppTokens.spaceSM / AppTokens.spaceXXS),
                height: AppTokens.space2XL * (AppTokens.spaceSM / AppTokens.spaceXXS),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      secondaryGlow.withValues(alpha: AppTokens.opacityTextSubtle),
                      secondaryGlow.withValues(alpha: AppTokens.opacityDivider),
                      _baseBg.withValues(alpha: AppTokens.elevationNone),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: AppTokens.spaceLG),
                      Text(
                        'WRLD',
                        style: GoogleFonts.sora(
                          fontSize: AppTokens.textMD,
                          fontWeight: FontWeight.w700,
                          color: onSurface.withValues(alpha: AppTokens.opacityTextMuted),
                          letterSpacing: AppTokens.letterSpacingWide * (AppTokens.spaceSM / AppTokens.spaceXXS),
                        ),
                      ),
                      const SizedBox(height: AppTokens.spaceSMPlus),
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[primaryGlow, secondaryGlow],
                          ).createShader(bounds);
                        },
                        child: Text(
                          'Your music,\nyour world.',
                          style: GoogleFonts.sora(
                            fontSize: AppTokens.text3XL,
                            fontWeight: FontWeight.w800,
                            height: AppTokens.spaceSMPlus / AppTokens.spaceSM,
                            color: onSurface,
                            letterSpacing: AppTokens.letterSpacingTight,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTokens.spaceMD),
                      Text(
                        'Select your core genres to unlock a curated atmosphere with live discussions and moving visuals.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: AppTokens.textSM,
                          fontWeight: FontWeight.w500,
                          color: onSurface.withValues(alpha: AppTokens.opacityTextSubtle),
                          height: AppTokens.lineHeightRelaxed,
                        ),
                      ),
                      const SizedBox(height: AppTokens.spaceXL),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: AppTokens.spaceSMPlus,
                            runSpacing: AppTokens.spaceSMPlus,
                            children: genres
                                .map(
                                  (Genre genre) => _GenreChip(
                                    genre: genre,
                                    selected: _selectedGenreIds.contains(genre.id),
                                    onTap: () => _toggleGenre(genre.id),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTokens.spaceMD),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.all(AppTokens.spaceMD),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppTokens.radiusXL),
                          color: onSurface.withValues(alpha: AppTokens.opacityDivider),
                          border: Border.all(
                            color: _selectedGenreIds.isEmpty
                                ? onSurface.withValues(alpha: AppTokens.opacityDivider)
                                : primaryGlow.withValues(alpha: AppTokens.opacityTextSubtle),
                          ),
                          boxShadow: _selectedGenreIds.isEmpty
                              ? const <BoxShadow>[]
                              : <BoxShadow>[
                                  BoxShadow(
                                    color: primaryGlow.withValues(alpha: AppTokens.opacityTextSubtle),
                                    blurRadius: AppTokens.spaceLG,
                                    spreadRadius: AppTokens.spaceXXS,
                                  ),
                                ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${_selectedGenreIds.length} selected',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: AppTokens.textSM,
                                fontWeight: FontWeight.w600,
                                color: onSurface.withValues(alpha: AppTokens.opacityTextSubtle),
                              ),
                            ),
                            const SizedBox(height: AppTokens.spaceSMPlus),
                            GestureDetector(
                              onTap: _selectedGenreIds.isEmpty ? null : _continue,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeOutCubic,
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppTokens.spaceMD,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppTokens.radiusLG),
                                  gradient: _selectedGenreIds.isEmpty
                                      ? null
                                      : LinearGradient(
                                          colors: <Color>[primaryGlow, secondaryGlow],
                                        ),
                                  color: _selectedGenreIds.isEmpty
                                      ? onSurface.withValues(alpha: AppTokens.opacityDivider)
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    'Enter The Hub',
                                    style: GoogleFonts.sora(
                                      fontSize: AppTokens.textMDPlus,
                                      fontWeight: FontWeight.w700,
                                      color: _selectedGenreIds.isEmpty
                                          ? onSurface.withValues(alpha: AppTokens.opacityTextSubtle)
                                          : onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTokens.spaceLG),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  final Genre genre;
  final bool selected;
  final VoidCallback onTap;

  const _GenreChip({
    required this.genre,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color onSurface = Theme.of(context).colorScheme.onSurface;

    return AnimatedScale(
      duration: const Duration(milliseconds: 260),
      scale: selected
          ? AppTokens.spaceMDPlus / AppTokens.spaceMD
          : AppTokens.spaceMD / AppTokens.spaceMD,
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spaceMD,
            vertical: AppTokens.spaceSMPlus,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radiusFull),
            color: selected
                ? genre.primaryAccent.withValues(alpha: AppTokens.opacityChipBorder)
                : onSurface.withValues(alpha: AppTokens.opacityDivider),
            border: Border.all(
              color: selected
                  ? genre.primaryAccent
                  : onSurface.withValues(alpha: AppTokens.opacityChipBorder),
            ),
            boxShadow: selected
                ? <BoxShadow>[
                    BoxShadow(
                      color: genre.primaryAccent.withValues(
                        alpha: AppTokens.opacityTextSubtle,
                      ),
                      blurRadius: AppTokens.spaceMDPlus,
                      spreadRadius: AppTokens.spaceXXS,
                    ),
                  ]
                : const <BoxShadow>[],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                genre.icon,
                size: AppTokens.iconSM + AppTokens.spaceXXS,
                color: selected
                    ? genre.primaryAccent
                    : onSurface.withValues(alpha: AppTokens.opacityTextMuted),
              ),
              const SizedBox(width: AppTokens.spaceSM),
              Text(
                genre.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: AppTokens.textSM,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? onSurface
                      : onSurface.withValues(alpha: AppTokens.opacityTextMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
