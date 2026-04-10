import 'package:flutter/material.dart';

import '../models/plant.dart';
import '../routes.dart';

/// Displays detailed information about a specific plant.
///
/// Shows the plant's health status, last watered time,
/// care instructions, and a link to recovery if applicable.
class PlantDetailScreen extends StatelessWidget {
  const PlantDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plant = ModalRoute.of(context)!.settings.arguments as Plant;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context, colorScheme),
              _buildPlantHero(plant, colorScheme),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCards(plant, colorScheme),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Care Log', Icons.history_rounded, colorScheme),
                    const SizedBox(height: 12),
                    _buildCareLog(colorScheme),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Care Tips', Icons.tips_and_updates_outlined, colorScheme),
                    const SizedBox(height: 12),
                    _buildCareTips(colorScheme),
                    if (plant.healthStatus != PlantHealthStatus.healthy) ...[
                      const SizedBox(height: 24),
                      _buildRecoveryButton(context, plant, colorScheme),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the back button bar.
  Widget _buildTopBar(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_rounded,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  /// Builds the hero section with plant icon, name, and status.
  Widget _buildPlantHero(Plant plant, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(plant.iconData, size: 40, color: colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            plant.name,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: plant.healthStatus.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: plant.healthStatus.color.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              plant.healthStatus.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: plant.healthStatus.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the quick info cards row (last watered, health, added).
  Widget _buildInfoCards(Plant plant, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            'Last Watered',
            plant.lastWatered,
            Icons.water_drop_outlined,
            colorScheme,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildInfoCard(
            'Sunlight',
            'Indirect',
            Icons.wb_sunny_outlined,
            colorScheme,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildInfoCard(
            'Humidity',
            'Medium',
            Icons.opacity_outlined,
            colorScheme,
          ),
        ),
      ],
    );
  }

  /// Builds a single info card.
  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a section title row.
  Widget _buildSectionTitle(
    String title,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  /// Builds the care log timeline.
  Widget _buildCareLog(ColorScheme colorScheme) {
    // TODO: Replace with actual care log data.
    final logs = [
      _CareLogEntry(action: 'Watered', date: 'Today, 8:00 AM', icon: Icons.water_drop_outlined),
      _CareLogEntry(action: 'Fertilized', date: 'Apr 5, 2026', icon: Icons.science_outlined),
      _CareLogEntry(action: 'Repotted', date: 'Mar 20, 2026', icon: Icons.swap_horiz_rounded),
      _CareLogEntry(action: 'Pruned', date: 'Mar 10, 2026', icon: Icons.content_cut_rounded),
    ];

    return Column(
      children: logs
          .map((log) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(log.icon, size: 18, color: colorScheme.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        log.action,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      log.date,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  /// Builds the care tips section.
  Widget _buildCareTips(ColorScheme colorScheme) {
    // TODO: Replace with actual care tips based on plant type.
    final tips = [
      'Water when the top inch of soil feels dry.',
      'Place in bright, indirect sunlight.',
      'Mist leaves occasionally to maintain humidity.',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: tips
            .map((tip) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.eco_outlined,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  /// Builds a button to navigate to the recovery screen.
  Widget _buildRecoveryButton(
    BuildContext context,
    Plant plant,
    ColorScheme colorScheme,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, Routes.recovery, arguments: plant);
        },
        icon: const Icon(Icons.healing_rounded),
        label: const Text('View Recovery Plan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CareLogEntry {
  final String action;
  final String date;
  final IconData icon;

  const _CareLogEntry({
    required this.action,
    required this.date,
    required this.icon,
  });
}
