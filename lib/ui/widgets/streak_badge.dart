import 'package:flutter/material.dart';
import '../../data/models/badge.dart' as models;

class StreakBadge extends StatelessWidget {
  final models.Badge badge;
  final double size;

  const StreakBadge({
    super.key,
    required this.badge,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    // Map milestone to image asset
    String assetPath;
    switch (badge.milestone) {
      case 5:
        assetPath = 'assets/badge_5.jpg';
        break;
      case 10:
        assetPath = 'assets/badge_10.jpg';
        break;
      case 20:
        assetPath = 'assets/badge_20.jpg';
        break;
      default:
        assetPath = 'assets/badge_default.jpg';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(assetPath, width: size, height: size),
        const SizedBox(height: 4),
        Text('Streak ${badge.milestone}',
            style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}