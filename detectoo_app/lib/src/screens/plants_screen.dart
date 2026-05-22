import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/api_exception.dart';
import '../models/plant.dart';
import '../providers/api_providers.dart';
import '../routes.dart';
import '../widgets/detectoo_card.dart';
import '../widgets/gradient_banner.dart';

/// Displays a list of plants owned by the user.
///
/// Each plant card shows the plant name, icon, health status,
/// and when it was last watered.
class PlantsScreen extends ConsumerWidget {
  const PlantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final plantsAsync = ref.watch(plantsListProvider);

    return Scaffold(
      body: SafeArea(
        child: plantsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildError(context, ref, colorScheme, error),
          data: (plants) => _buildContent(context, ref, colorScheme, plants),
        ),
      ),
    );
  }

  /// Renders the full populated layout (may include an empty state).
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
    List<Plant> plants,
  ) {
    return RefreshIndicator(
      onRefresh: () => ref.refresh(plantsListProvider.future),
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
            child: plants.isEmpty
                ? _buildEmptyState(colorScheme)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: plants.length,
                    itemBuilder: (context, index) {
                      return _buildPlantCard(
                        context,
                        plants[index],
                        colorScheme,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Error view with a retry action.
  Widget _buildError(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
    Object error,
  ) {
    final message = error is ApiException
        ? error.message
        : 'Could not load your plants.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
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
  Widget _buildEmptyState(ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      children: [
        Icon(
          Icons.yard_rounded,
          size: 56,
          color: colorScheme.primary.withValues(alpha: 0.4),
        ),
        const SizedBox(height: 16),
        Text(
          'No plants yet',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add your first plant to start tracking its health and care.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
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
      BuildContext context, Plant plant, ColorScheme colorScheme) {
    final imageUrl = plant.imageUrl;

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
                if (imageUrl != null)
                  Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) =>
                        _buildCardImagePlaceholder(plant, colorScheme),
                  )
                else
                  _buildCardImagePlaceholder(plant, colorScheme),
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
                            'Watered ${plant.lastWateredLabel}',
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

  /// Fallback header shown when a plant has no uploaded photo.
  Widget _buildCardImagePlaceholder(Plant plant, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: 140,
      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Center(
        child: Icon(
          plant.iconData,
          size: 52,
          color: colorScheme.primary.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
