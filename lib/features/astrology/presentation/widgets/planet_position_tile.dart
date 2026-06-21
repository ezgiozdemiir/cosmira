import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../domain/entities/natal_chart.dart';

class PlanetPositionTile extends StatelessWidget {
  final PlanetPosition position;

  const PlanetPositionTile({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Text(
            _planetIcon(position.planet),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  position.planet.capitalize,
                  style: AppTextStyles.titleMedium,
                ),
                Text(
                  '${position.sign.zodiacName} ${position.sign.zodiacEmoji} at ${position.degree.toStringAsFixed(1)}°',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          if (position.isRetrograde)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.auraRose.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Rx',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.auraRose,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _planetIcon(String planet) {
    const icons = {
      'sun': '☉',
      'moon': '☽',
      'mercury': '☿',
      'venus': '♀',
      'mars': '♂',
      'jupiter': '♃',
      'saturn': '♄',
      'uranus': '♅',
      'neptune': '♆',
      'pluto': '♇',
    };
    return icons[planet.toLowerCase()] ?? '⊕';
  }
}
