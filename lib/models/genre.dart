import 'package:flutter/material.dart';

class SubGenre {
  final String id;
  final String name;
  final String description;
  final String imageUrl;

  const SubGenre({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl = '',
  });
}

class Genre {
  final String id;
  final String name;
  final String description;
  final Color primaryAccent;
  final Color secondaryAccent;
  final String imageUrl;
  final IconData icon;
  final List<SubGenre> subGenres;
  final List<String> tags;

  const Genre({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.imageUrl,
    required this.icon,
    this.subGenres = const [],
    this.tags = const [],
  });

  /// Pre-defined genre data matching Stitch screen IDs.
  static List<Genre> get allGenres => [
        Genre(
          id: '7b3f3fcfe1124ba69c0708d4343f42ea',
          name: 'Hip-Hop',
          description: 'Beats, bars & culture. From boom-bap to trap.',
          primaryAccent: const Color(0xFFFFD700),
          secondaryAccent: const Color(0xFFFF0000),
          imageUrl:
              'https://images.unsplash.com/photo-1571609860754-01e1b0e44bf3?w=600',
          icon: Icons.mic,
          tags: ['Rap', 'Trap', 'Boom Bap', 'Drill', 'Rage'],
          subGenres: [
            const SubGenre(
              id: 'hh-rage',
              name: 'Rage',
              description: 'High-energy, distorted 808s and aggressive flows.',
              imageUrl:
                  'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
            ),
            const SubGenre(
              id: 'hh-drill',
              name: 'Drill',
              description:
                  'Dark, gritty beats born from Chicago to the world.',
              imageUrl:
                  'https://images.unsplash.com/photo-1526478806334-5fd488fcaabc?w=400',
            ),
            const SubGenre(
              id: 'hh-trap',
              name: 'Trap',
              description: 'Rolling hi-hats, booming 808s, the ATL sound.',
              imageUrl:
                  'https://images.unsplash.com/photo-1504898770365-14faca6a7320?w=400',
            ),
            const SubGenre(
              id: 'hh-boombap',
              name: 'Boom Bap',
              description: 'Classic East Coast loops and breakbeats.',
              imageUrl:
                  'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400',
            ),
          ],
        ),
        Genre(
          id: '8604e81115b149ceb71f6c66a3af4188',
          name: 'K-Pop',
          description: 'Global pop phenomenon from South Korea.',
          primaryAccent: const Color(0xFFFF1493),
          secondaryAccent: const Color(0xFFFF69B4),
          imageUrl:
              'https://images.unsplash.com/photo-1534809027769-b00d750a6bac?w=600',
          icon: Icons.star,
          tags: ['Idol', 'Boy Group', 'Girl Group', 'Solo', 'OST'],
          subGenres: [
            const SubGenre(
              id: 'kp-idol',
              name: 'Idol Pop',
              description: 'Polished group performances and catchy hooks.',
            ),
            const SubGenre(
              id: 'kp-khiphop',
              name: 'K-Hip-Hop',
              description: 'Korean hip-hop fused with pop sensibilities.',
            ),
            const SubGenre(
              id: 'kp-rnb',
              name: 'K-R&B',
              description: 'Smooth, soulful Korean R&B.',
            ),
          ],
        ),
        Genre(
          id: 'c3815d01b42b4905b54c792301d85ff3',
          name: 'Jazz',
          description: 'The art of improvisation and soul.',
          primaryAccent: const Color(0xFF1A237E),
          secondaryAccent: const Color(0xFFFFD700),
          imageUrl:
              'https://images.unsplash.com/photo-1511192336575-5a79af67a629?w=600',
          icon: Icons.music_note,
          tags: ['Smooth', 'Bebop', 'Fusion', 'Contemporary', 'Free Jazz'],
          subGenres: [
            const SubGenre(
              id: 'jz-smooth',
              name: 'Smooth Jazz',
              description: 'Mellow, polished, radio-friendly jazz.',
            ),
            const SubGenre(
              id: 'jz-bebop',
              name: 'Bebop',
              description: 'Fast tempo, complex harmonies and improvisation.',
            ),
            const SubGenre(
              id: 'jz-fusion',
              name: 'Jazz Fusion',
              description: 'Jazz meets rock, funk, and electronic.',
            ),
          ],
        ),
        Genre(
          id: 'aea330f9577b43e8831ab3bedab5c8ef',
          name: 'Traditional',
          description: 'Turkic folk, world roots, and cultural heritage.',
          primaryAccent: const Color(0xFF8D6E63),
          secondaryAccent: const Color(0xFFD7CCC8),
          imageUrl:
              'https://images.unsplash.com/photo-1508979822114-db7bc83c2081?w=600',
          icon: Icons.terrain,
          tags: ['Turkic Folk', 'Throat Singing', 'Dombra', 'World Music'],
          subGenres: [
            const SubGenre(
              id: 'tr-turkic',
              name: 'Turkic Folk',
              description:
                  'Ancient melodies of the steppe — dombra, kobyz, and throat singing.',
            ),
            const SubGenre(
              id: 'tr-anatolian',
              name: 'Anatolian',
              description: 'Rich folk traditions of Anatolia.',
            ),
            const SubGenre(
              id: 'tr-central-asian',
              name: 'Central Asian',
              description: 'Heritage sounds from Kazakhstan to Kyrgyzstan.',
            ),
          ],
        ),
        Genre(
          id: '3f573ca1e8b54a50b4e23c7d6f9a0e12',
          name: 'Electronic',
          description: 'Synthesized soundscapes and dancefloor energy.',
          primaryAccent: const Color(0xFF00E5FF),
          secondaryAccent: const Color(0xFF7C4DFF),
          imageUrl:
              'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=600',
          icon: Icons.graphic_eq,
          tags: ['House', 'Techno', 'Drum & Bass', 'Ambient', 'Dubstep'],
          subGenres: [
            const SubGenre(
              id: 'el-house',
              name: 'House',
              description: 'Four-on-the-floor groove from Chicago.',
            ),
            const SubGenre(
              id: 'el-techno',
              name: 'Techno',
              description: 'Industrial rhythms from Detroit.',
            ),
            const SubGenre(
              id: 'el-dnb',
              name: 'Drum & Bass',
              description: 'Breakbeat-driven, high-BPM energy.',
            ),
          ],
        ),
        Genre(
          id: '903d06c2f4a14d3e9b5a8c7e2d1f0b34',
          name: 'Rock & Metal',
          description: 'Guitar-driven power and raw energy.',
          primaryAccent: const Color(0xFFD32F2F),
          secondaryAccent: const Color(0xFF212121),
          imageUrl:
              'https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?w=600',
          icon: Icons.flash_on,
          tags: ['Classic Rock', 'Metal', 'Punk', 'Alternative', 'Grunge'],
          subGenres: [
            const SubGenre(
              id: 'rm-metal',
              name: 'Heavy Metal',
              description: 'Loud, distorted, and unapologetic.',
            ),
            const SubGenre(
              id: 'rm-punk',
              name: 'Punk Rock',
              description: 'Fast, stripped-down, rebellious.',
            ),
            const SubGenre(
              id: 'rm-alt',
              name: 'Alternative',
              description: 'Genre-bending rock from the underground.',
            ),
          ],
        ),
      ];
}
