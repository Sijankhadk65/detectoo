import 'package:flutter/material.dart';

import '../models/plant.dart';
import '../routes.dart';
import '../widgets/detectoo_card.dart';
import '../widgets/gradient_banner.dart';

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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildHeaderBanner(colorScheme, plants),
            ),
            const SizedBox(height: 16),
            _buildStatusSummary(colorScheme, plants),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: plants.length,
                itemBuilder: (context, index) {
                  final images = [
                    'assets/my_plant_bg.jpg',
                    'assets/login_bg.jpg',
                  ];
                  return _buildPlantCard(
                    context,
                    plants[index],
                    images[index % images.length],
                    colorScheme,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the screen header as a gradient banner.
  Widget _buildHeaderBanner(ColorScheme colorScheme, List<Plant> plants) {
    return GradientBanner(
      colors: [
        const Color(0xFF2E7D32),
        const Color(0xFF00695C),
      ],
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Plants',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${plants.length} plants in your garden',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFFB300).withValues(alpha: 0.3),
                  const Color(0xFFFF8F00).withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFFFD54F).withValues(alpha: 0.25),
              ),
            ),
            child: const Icon(
              Icons.yard_rounded,
              size: 28,
              color: Color(0xFFFFD54F),
            ),
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
          ),
          const SizedBox(width: 8),
          _buildStatusChip(
            'Attention',
            attentionCount,
            PlantHealthStatus.needsAttention.color,
          ),
          const SizedBox(width: 8),
          _buildStatusChip(
            'Recovering',
            recoveringCount,
            PlantHealthStatus.recovering.color,
          ),
        ],
      ),
    );
  }

  /// Builds a single status summary chip with a dot indicator.
  Widget _buildStatusChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
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

  /// Builds a single tappable plant card with image header and status badge.
  Widget _buildPlantCard(
      BuildContext context, Plant plant, String imagePath,
      ColorScheme colorScheme) {
    return DetectooCard(
      elevation: 1.5,
      onTap: () {
        Navigator.pushNamed(context, Routes.plantDetail, arguments: plant);
      },
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image header with status badge
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Stack(
              children: [
                Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: 140,
                  fit: BoxFit.cover,
                ),
                // Status badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: plant.healthStatus.color,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          plant.healthStatus == PlantHealthStatus.healthy
                              ? Icons.check_circle_rounded
                              : plant.healthStatus ==
                                      PlantHealthStatus.recovering
                                  ? Icons.healing_rounded
                                  : Icons.warning_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          plant.healthStatus.label.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Plant info
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              children: [
                // Plant icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    plant.iconData,
                    size: 22,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.name,
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.water_drop_outlined,
                            size: 13,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Watered ${plant.lastWatered}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
