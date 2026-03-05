import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/genre.dart';
import '../models/post.dart';
import '../providers/navigation_provider.dart';
import '../providers/theme_manager.dart';
import '../widgets/breadcrumb_widget.dart';

/// Stitch ID: bad92919112140179cd3c4cc968b814d
/// Discussion Thread — "Rage Thread" detailed view with post bubbles
/// and media player placeholders.
class DiscussionThreadScreen extends StatelessWidget {
  final Genre genre;
  final SubGenre? subGenre;

  const DiscussionThreadScreen({
    super.key,
    required this.genre,
    this.subGenre,
  });

  @override
  Widget build(BuildContext context) {
    final tm = context.watch<ThemeManager>();
    final nav = context.read<NavigationProvider>();
    final posts = Post.sampleRagePosts;

    return Scaffold(
      backgroundColor: tm.scaffoldBg,
      appBar: AppBar(
        backgroundColor: tm.scaffoldBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => nav.goBack(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔥 Rage Thread',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${posts.length} posts',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white54,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.sort, color: genre.primaryAccent),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.white54),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Breadcrumb ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: BreadcrumbBar.fromGenre(
              genre: genre,
              subGenreName: subGenre?.name ?? 'Rage',
              accentColor: genre.primaryAccent,
              onHomeTap: () {
                tm.setActiveGenre(null);
                nav.navigateToExplore();
              },
              onGenreTap: () => nav.goBack(),
            ),
          ),

          Divider(
            color: Colors.white.withValues(alpha: 0.06),
            height: 1,
          ),

          // ── Posts list ───────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: posts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _PostBubble(
                post: posts[index],
                accentColor: genre.primaryAccent,
              ),
            ),
          ),

          // ── Compose bar ──────────────────────────────────
          _ComposeBar(accentColor: genre.primaryAccent),
        ],
      ),
    );
  }
}

// ── Post bubble ──────────────────────────────────────────────
class _PostBubble extends StatelessWidget {
  final Post post;
  final Color accentColor;

  const _PostBubble({required this.post, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1A1A),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: accentColor.withValues(alpha: 0.2),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: post.authorAvatarUrl,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const SizedBox(),
                    errorWidget: (_, _, _) => Icon(
                      Icons.person,
                      size: 20,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _formatTimestamp(post.timestamp),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz,
                    size: 18, color: Colors.white38),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content
          Text(
            post.content,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),

          // Media placeholder
          if (post.mediaType != null) ...[
            const SizedBox(height: 12),
            _MediaPlaceholder(post: post, accentColor: accentColor),
          ],

          const SizedBox(height: 14),

          // Actions row
          Row(
            children: [
              _ActionChip(
                icon: Icons.favorite_border,
                label: '${post.likes}',
                color: accentColor,
              ),
              const SizedBox(width: 16),
              _ActionChip(
                icon: Icons.chat_bubble_outline,
                label: '${post.replies}',
                color: Colors.white54,
              ),
              const SizedBox(width: 16),
              _ActionChip(
                icon: Icons.share_outlined,
                label: 'Share',
                color: Colors.white54,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime ts) {
    final hour = ts.hour.toString().padLeft(2, '0');
    final minute = ts.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

// ── Media placeholder ────────────────────────────────────────
class _MediaPlaceholder extends StatelessWidget {
  final Post post;
  final Color accentColor;

  const _MediaPlaceholder({required this.post, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    if (post.mediaType == PostMediaType.audio) {
      return _AudioPlayerPlaceholder(accentColor: accentColor);
    }

    if (post.mediaType == PostMediaType.image && post.mediaUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: post.mediaUrl!,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (_, _) => Container(
            height: 180,
            color: accentColor.withValues(alpha: 0.1),
          ),
          errorWidget: (_, _, _) => Container(
            height: 180,
            color: accentColor.withValues(alpha: 0.1),
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.white38),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ── Audio player placeholder ─────────────────────────────────
class _AudioPlayerPlaceholder extends StatelessWidget {
  final Color accentColor;
  const _AudioPlayerPlaceholder({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: accentColor.withValues(alpha: 0.1),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.2),
            ),
            child: Icon(Icons.play_arrow, color: accentColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Waveform placeholder
                Container(
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: CustomPaint(
                    size: const Size(double.infinity, 24),
                    painter: _WaveformPainter(color: accentColor),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '0:00 / 2:34',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.white38,
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

/// Simple fake waveform painter.
class _WaveformPainter extends CustomPainter {
  final Color color;
  _WaveformPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const bars = 40;
    final spacing = size.width / bars;
    // Deterministic pseudo-random bar heights.
    final heights = List.generate(bars, (i) {
      final h = ((i * 7 + 3) % 11) / 11.0;
      return h * size.height * 0.8 + size.height * 0.15;
    });

    for (var i = 0; i < bars; i++) {
      final x = i * spacing + spacing / 2;
      final barH = heights[i];
      final top = (size.height - barH) / 2;
      canvas.drawLine(Offset(x, top), Offset(x, top + barH), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Action chip (like, reply, share) ─────────────────────────
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: color),
        ),
      ],
    );
  }
}

// ── Compose bar at the bottom ────────────────────────────────
class _ComposeBar extends StatelessWidget {
  final Color accentColor;
  const _ComposeBar({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline,
                color: Colors.white38, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFF1A1A1A),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Text(
                'Add to the thread...',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white30,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor,
            ),
            child: Icon(
              Icons.send,
              size: 16,
              color: accentColor.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
