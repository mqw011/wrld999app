import 'package:flutter/material.dart';
import '../models/genre.dart';

/// Breadcrumb segment: label + optional tap callback.
class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  const BreadcrumbItem({required this.label, this.onTap});
}

/// Custom breadcrumb widget rendering: 999 > Genre > Sub-genre
/// Each segment is tappable for navigation.
class BreadcrumbBar extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final Color accentColor;

  const BreadcrumbBar({
    super.key,
    required this.items,
    this.accentColor = Colors.white,
  });

  /// Factory for building breadcrumbs from genre navigation state.
  factory BreadcrumbBar.fromGenre({
    Key? key,
    Genre? genre,
    String? subGenreName,
    required Color accentColor,
    required VoidCallback onHomeTap,
    VoidCallback? onGenreTap,
  }) {
    final crumbs = <BreadcrumbItem>[
      BreadcrumbItem(label: '999', onTap: onHomeTap),
    ];
    if (genre != null) {
      crumbs.add(BreadcrumbItem(label: genre.name, onTap: onGenreTap));
    }
    if (subGenreName != null) {
      crumbs.add(BreadcrumbItem(label: subGenreName));
    }
    return BreadcrumbBar(key: key, items: crumbs, accentColor: accentColor);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _buildSegments(context),
      ),
    );
  }

  List<Widget> _buildSegments(BuildContext context) {
    final widgets = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;

      widgets.add(
        GestureDetector(
          onTap: isLast ? null : item.onTap,
          child: Text(
            item.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
              color: isLast
                  ? accentColor
                  : Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
      );

      if (!isLast) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              Icons.chevron_right,
              size: 16,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        );
      }
    }

    return widgets;
  }
}
