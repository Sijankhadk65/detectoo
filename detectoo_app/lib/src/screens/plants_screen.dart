import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/api_exception.dart';
import '../models/plant.dart';
import '../providers/api_providers.dart';
import '../routes.dart';
import '../theme/detectoo_colors.dart';
import '../theme/detectoo_text_styles.dart';
import '../widgets/detectoo_card.dart';
import '../widgets/eyebrow_label.dart';
import '../widgets/icon_badge.dart';

/// Displays a list of plants owned by the user.
///
/// Each plant card shows the plant name, icon, health status,
/// and when it was last watered.
class PlantsScreen extends ConsumerWidget {
  const PlantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantsListProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: plantsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildError(context, ref, error),
          data: (plants) => _buildContent(context, ref, plants),
        ),
      ),
    );
  }

  /// Renders the full populated layout (may include an empty state).
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<Plant> plants,
  ) {
    return RefreshIndicator(
      onRefresh: () => ref.refresh(plantsListProvider.future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        children: [
          const EyebrowLabel('MY GARDEN'),
          const SizedBox(height: 8),
          Text('Your Plants.', style: DetectooText.h1),
          const SizedBox(height: 6),
          Text(
            plants.isEmpty
                ? 'No specimens yet — add your first below.'
                : '${plants.length} specimens under your care.',
            style: DetectooText.body.copyWith(color: DetectooColors.textMuted),
          ),
          const SizedBox(height: 20),
          if (plants.isNotEmpty) ...[
            _buildStatusSummary(plants),
            const SizedBox(height: 20),
          ],
          if (plants.isEmpty)
            _buildEmptyState()
          else
            for (final plant in plants) ...[
              _buildPlantCard(context, plant),
              const SizedBox(height: 16),
            ],
        ],
      ),
    );
  }

  /// Error view with a retry action.
  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    final message = error is ApiException
        ? error.message
        : 'Could not load your plants.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: DetectooColors.textFaint,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: DetectooText.body,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => ref.invalidate(plantsListProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty state when the user has no plants yet.
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.spa_rounded,
            size: 56,
            color: DetectooColors.green600.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text('No plants yet.', style: DetectooText.h3),
          const SizedBox(height: 8),
          Text(
            'Add your first plant to start tracking its health and care.',
            textAlign: TextAlign.center,
            style: DetectooText.body.copyWith(color: DetectooColors.textMuted),
          ),
        ],
      ),
    );
  }

  /// Builds horizontal status summary chips showing counts per health status.
  Widget _buildStatusSummary(List<Plant> plants) {
    final healthyCount = plants
        .where((p) => p.healthStatus == PlantHealthStatus.healthy)
        .length;
    final attentionCount = plants
        .where((p) => p.healthStatus == PlantHealthStatus.needsAttention)
        .length;
    final recoveringCount = plants
        .where((p) => p.healthStatus == PlantHealthStatus.recovering)
        .length;

    return Row(
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
    );
  }

  /// Builds a single status summary chip with a dot indicator.
  Widget _buildStatusChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DetectooRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$count $label',
            style: DetectooText.small.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single tappable plant card with image header and status badge.
  Widget _buildPlantCard(BuildContext context, Plant plant) {
    final imageUrl = plant.imageUrl;

    return DetectooCard(
      clip: true,
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.pushNamed(context, Routes.plantDetail, arguments: plant);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image header with status badge
          Stack(
            children: [
              if (imageUrl != null)
                Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) =>
                      _buildCardImagePlaceholder(plant),
                )
              else
                _buildCardImagePlaceholder(plant),
              // Status badge
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: plant.healthStatus.color,
                    borderRadius: BorderRadius.circular(DetectooRadii.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        plant.healthStatus == PlantHealthStatus.healthy
                            ? Icons.check_circle_rounded
                            : plant.healthStatus == PlantHealthStatus.recovering
                            ? Icons.healing_rounded
                            : Icons.error_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        plant.healthStatus.label.toUpperCase(),
                        style: DetectooText.eyebrow.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Plant info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Row(
              children: [
                IconBadge(icon: plant.iconData, iconSize: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plant.name, style: DetectooText.h3),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.water_drop_outlined,
                            size: 13,
                            color: DetectooColors.green500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Watered ${plant.lastWateredLabel}',
                            style: DetectooText.small,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: DetectooColors.textFaint,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Fallback header shown when a plant has no uploaded photo.
  Widget _buildCardImagePlaceholder(Plant plant) {
    return Container(
      width: double.infinity,
      height: 140,
      color: DetectooColors.green050,
      child: Center(
        child: Icon(
          plant.iconData,
          size: 52,
          color: DetectooColors.green600.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
