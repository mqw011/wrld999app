import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/genre.dart';
import '../providers/navigation_provider.dart';
import '../providers/theme_manager.dart';

/// Stitch ID: 0c71379f0e9b4f87bcc171fdb4b1331a
/// "Choose Your Vibe" onboarding screen with multi-select genre chips.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final Set<String> _selectedGenreIds = {};
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
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
    if (_selectedGenreIds.isEmpty) return;
    context.read<NavigationProvider>().completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final tm = context.watch<ThemeManager>();
    final genres = Genre.allGenres;

    return Scaffold(
      backgroundColor: tm.scaffoldBg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                // ── Logo ─────────────────────────────────────
                Text(
                  '999',
                  style: GoogleFonts.inter(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 8),
                // ── Title ────────────────────────────────────
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFF7C4DFF)],
                  ).createShader(bounds),
                  child: Text(
                    'Choose Your Vibe',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pick the genres that move you. We\'ll curate your hub.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                // ── Genre chips ──────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: genres.map((genre) {
                        final selected =
                            _selectedGenreIds.contains(genre.id);
                        return _GenreChip(
                          genre: genre,
                          selected: selected,
                          onTap: () => _toggleGenre(genre.id),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // ── Selection counter ────────────────────────
                Center(
                  child: Text(
                    '${_selectedGenreIds.length} genre${_selectedGenreIds.length == 1 ? '' : 's'} selected',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white38,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // ── Continue button ──────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: _selectedGenreIds.isNotEmpty
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF9C27B0),
                                Color(0xFF7C4DFF),
                              ],
                            )
                          : null,
                      color: _selectedGenreIds.isEmpty
                          ? Colors.white.withValues(alpha: 0.06)
                          : null,
                    ),
                    child: ElevatedButton(
                      onPressed:
                          _selectedGenreIds.isNotEmpty ? _continue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Enter the Hub',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _selectedGenreIds.isNotEmpty
                              ? Colors.white
                              : Colors.white30,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: selected
              ? genre.primaryAccent.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.06),
          border: Border.all(
            color: selected
                ? genre.primaryAccent
                : Colors.white.withValues(alpha: 0.1),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              genre.icon,
              size: 18,
              color: selected ? genre.primaryAccent : Colors.white54,
            ),
            const SizedBox(width: 8),
            Text(
              genre.name,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? genre.primaryAccent : Colors.white70,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.check_circle,
                size: 16,
                color: genre.primaryAccent,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
