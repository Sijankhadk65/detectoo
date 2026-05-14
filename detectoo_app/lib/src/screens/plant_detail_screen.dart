import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/plant.dart';
import '../providers/api_providers.dart';
import '../routes.dart';
import '../widgets/detectoo_button.dart';
import '../widgets/detectoo_card.dart';
import '../widgets/icon_badge.dart';
import '../widgets/section_title.dart';

/// Displays detailed information about a specific plant.
///
/// Shows the plant's photo (or icon hero), health status, last watered time,
/// care instructions, a delete option, and a link to recovery if applicable.
class PlantDetailScreen extends ConsumerStatefulWidget {
  const PlantDetailScreen({super.key});

  @override
  ConsumerState<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends ConsumerState<PlantDetailScreen> {
  bool _isDeleting = false;

  Future<void> _confirmDelete(Plant plant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete plant?'),
        content: Text(
          'Remove "${plant.name}" from your garden? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await ref.read(plantsRepositoryProvider).deletePlant(plant.id);
      ref.invalidate(plantsListProvider);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete plant. Try again.')),
        );
        setState(() => _isDeleting = false);
      }
    }
  }

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
              _buildTopBar(context, plant, colorScheme),
              _buildPlantHero(plant, colorScheme),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCards(plant, colorScheme),
                    const SizedBox(height: 24),
                    SectionTitle(
                      title: 'Care Log',
                      icon: Icons.history_rounded,
                      iconColor: colorScheme.secondary,
                    ),
                    const SizedBox(height: 12),
                    _buildCareLog(colorScheme),
                    const SizedBox(height: 24),
                    const SectionTitle(
                      title: 'Care Tips',
                      icon: Icons.tips_and_updates_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildCareTips(colorScheme),
                    if (plant.healthStatus != PlantHealthStatus.healthy) ...[
                      const SizedBox(height: 24),
                      _buildRecoveryButton(context, plant, colorScheme),
                    ],
                    const SizedBox(height: 16),
                    _buildDeleteButton(plant, colorScheme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the back button bar with a delete icon on the right.
  Widget _buildTopBar(
      BuildContext context, Plant plant, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          if (_isDeleting)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              onPressed: () => _confirmDelete(plant),
              icon: Icon(
                Icons.delete_outline_rounded,
                color: colorScheme.error,
              ),
              tooltip: 'Delete plant',
            ),
        ],
      ),
    );
  }

  /// Builds the hero section: uploaded photo or icon fallback.
  Widget _buildPlantHero(Plant plant, ColorScheme colorScheme) {
    final imageUrl = plant.imageUrl;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: imageUrl != null
          ? Stack(
              children: [
                Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) =>
                      _buildIconHero(plant, colorScheme),
                ),
                // Gradient overlay with name + status
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: _buildNameStatusOverlay(plant),
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(28),
              child: _buildIconHero(plant, colorScheme),
            ),
    );
  }

  Widget _buildIconHero(Plant plant, ColorScheme colorScheme) {
    return Column(
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
        _buildStatusPill(plant, onDark: false),
      ],
    );
  }

  Widget _buildNameStatusOverlay(Plant plant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          plant.name,
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        _buildStatusPill(plant, onDark: true),
      ],
    );
  }

  Widget _buildStatusPill(Plant plant, {required bool onDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: onDark
            ? Colors.white.withValues(alpha: 0.2)
            : plant.healthStatus.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: onDark
              ? Colors.white.withValues(alpha: 0.4)
              : plant.healthStatus.color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        plant.healthStatus.label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: onDark ? Colors.white : plant.healthStatus.color,
        ),
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
            plant.lastWateredLabel,
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
            iconColor: colorScheme.secondary,
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
    ColorScheme colorScheme, {
    Color? iconColor,
  }) {
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
          Icon(icon, size: 22, color: iconColor ?? colorScheme.primary),
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

  /// Builds the care log timeline.
  Widget _buildCareLog(ColorScheme colorScheme) {
    final logs = [
      _CareLogEntry(
          action: 'Watered',
          date: 'Today, 8:00 AM',
          icon: Icons.water_drop_outlined),
      _CareLogEntry(
          action: 'Fertilized',
          date: 'Apr 5, 2026',
          icon: Icons.science_outlined),
      _CareLogEntry(
          action: 'Repotted',
          date: 'Mar 20, 2026',
          icon: Icons.swap_horiz_rounded),
      _CareLogEntry(
          action: 'Pruned',
          date: 'Mar 10, 2026',
          icon: Icons.content_cut_rounded),
    ];

    return Column(
      children: logs
          .map((log) => DetectooCard(
                elevation: 0.5,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    IconBadge(icon: log.icon),
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
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.7),
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
    return DetectooButton(
      label: 'View Recovery Plan',
      icon: Icons.healing_rounded,
      color: colorScheme.secondary,
      onPressed: () {
        Navigator.pushNamed(context, Routes.recovery, arguments: plant);
      },
    );
  }

  /// Builds the delete button at the bottom of the screen.
  Widget _buildDeleteButton(Plant plant, ColorScheme colorScheme) {
    return OutlinedButton.icon(
      onPressed: _isDeleting ? null : () => _confirmDelete(plant),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
        foregroundColor: colorScheme.error,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: const Icon(Icons.delete_outline_rounded),
      label: const Text(
        'Remove Plant',
        style: TextStyle(fontWeight: FontWeight.w600),
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
