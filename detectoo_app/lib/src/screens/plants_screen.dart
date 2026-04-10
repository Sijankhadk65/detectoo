import 'package:flutter/material.dart';

import '../models/plant.dart';
import '../routes.dart';
import '../widgets/detectoo_card.dart';
import '../widgets/status_chip.dart';

/// Displays a list of plants owned by the user.
///
/// Each plant card shows the plant name, icon, health status,
/// and when it was last watered.
class PlantsScreen extends StatelessWidget {
  const PlantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // TODO: Replace with actual plant data.
    final plants = [
      Plant((b) => b
        ..name = 'Monstera'
        ..iconCodePoint = Icons.yard_rounded.codePoint
        ..healthStatus = PlantHealthStatus.healthy
        ..lastWatered = '2 hours ago'),
      Plant((b) => b
        ..name = 'Snake Plant'
        ..iconCodePoint = Icons.grass_rounded.codePoint
        ..healthStatus = PlantHealthStatus.healthy
        ..lastWatered = 'Yesterday'),
      Plant((b) => b
        ..name = 'Rose Bush'
        ..iconCodePoint = Icons.local_florist_rounded.codePoint
        ..healthStatus = PlantHealthStatus.recovering
        ..lastWatered = '3 days ago'),
      Plant((b) => b
        ..name = 'Fiddle Leaf Fig'
        ..iconCodePoint = Icons.park_rounded.codePoint
        ..healthStatus = PlantHealthStatus.needsAttention
        ..lastWatered = '5 days ago'),
      Plant((b) => b
        ..name = 'Aloe Vera'
        ..iconCodePoint = Icons.eco_rounded.codePoint
        ..healthStatus = PlantHealthStatus.healthy
        ..lastWatered = '1 day ago'),
      Plant((b) => b
        ..name = 'Tomato Plant'
        ..iconCodePoint = Icons.filter_vintage_rounded.codePoint
        ..healthStatus = PlantHealthStatus.recovering
        ..lastWatered = '4 days ago'),
      Plant((b) => b
        ..name = 'Basil'
        ..iconCodePoint = Icons.spa_rounded.codePoint
        ..healthStatus = PlantHealthStatus.needsAttention
        ..lastWatered = '6 days ago'),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(colorScheme, plants.length),
            const SizedBox(height: 12),
            _buildStatusSummary(colorScheme, plants),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: plants.length,
                itemBuilder: (context, index) =>
                    _buildPlantCard(context, plants[index], colorScheme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the screen header with title and plant count.
  Widget _buildHeader(ColorScheme colorScheme, int plantCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'My Plants',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          StatusChip(
            label: '$plantCount plants',
            color: colorScheme.primary,
            backgroundAlpha: 0.15,
          ),
        ],
      ),
    );
  }

  /// Builds horizontal status summary chips showing counts per health status.
  Widget _buildStatusSummary(ColorScheme colorScheme, List<Plant> plants) {
    final healthyCount =
        plants.where((p) => p.healthStatus == PlantHealthStatus.healthy).length;
    final attentionCount = plants
        .where((p) => p.healthStatus == PlantHealthStatus.needsAttention)
        .length;
    final recoveringCount = plants
        .where((p) => p.healthStatus == PlantHealthStatus.recovering)
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatusChip(
            'Healthy',
            healthyCount,
            PlantHealthStatus.healthy.color,
            colorScheme,
          ),
          const SizedBox(width: 8),
          _buildStatusChip(
            'Attention',
            attentionCount,
            PlantHealthStatus.needsAttention.color,
            colorScheme,
          ),
          const SizedBox(width: 8),
          _buildStatusChip(
            'Recovering',
            recoveringCount,
            PlantHealthStatus.recovering.color,
            colorScheme,
          ),
        ],
      ),
    );
  }

  /// Builds a single status summary chip with a dot indicator.
  Widget _buildStatusChip(
    String label,
    int count,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count $label',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single tappable plant card.
  Widget _buildPlantCard(
      BuildContext context, Plant plant, ColorScheme colorScheme) {
    return DetectooCard(
      onTap: () {
        Navigator.pushNamed(context, Routes.plantDetail, arguments: plant);
      },
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(plant.iconData, size: 26, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.water_drop_outlined,
                      size: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Watered ${plant.lastWatered}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          StatusChip(
            label: plant.healthStatus.label,
            color: plant.healthStatus.color,
          ),
        ],
      ),
    );
  }
}
