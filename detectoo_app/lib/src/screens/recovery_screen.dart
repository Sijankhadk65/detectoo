import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/api_exception.dart';
import '../models/plant.dart';
import '../models/recovery_plan.dart';
import '../providers/api_providers.dart';
import '../widgets/gradient_banner.dart';
import '../widgets/section_title.dart';
import '../widgets/status_chip.dart';

/// Recovery screen for the Detectoo application.
///
/// Displays a detailed, easy-to-understand recovery plan for an
/// affected plant. Designed to be informative for users with no
/// prior plant care expertise.
class RecoveryScreen extends ConsumerWidget {
  const RecoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plant = ModalRoute.of(context)?.settings.arguments as Plant?;
    final colorScheme = Theme.of(context).colorScheme;

    if (plant == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context, colorScheme),
              Expanded(child: _buildMissingPlant(colorScheme)),
            ],
          ),
        ),
      );
    }

    final planAsync = ref.watch(recoveryPlanForPlantProvider(plant.id));

    return Scaffold(
      body: SafeArea(
        child: planAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context, colorScheme),
              Expanded(
                child: _buildError(context, ref, plant, colorScheme, error),
              ),
            ],
          ),
          data: (plan) {
            if (plan == null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(context, colorScheme),
                  Expanded(child: _buildNoPlan(plant, colorScheme)),
                ],
              );
            }
            return _buildPlanContent(context, plant, plan, colorScheme);
          },
        ),
      ),
    );
  }

  Widget _buildPlanContent(
    BuildContext context,
    Plant plant,
    RecoveryPlan plan,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(context, colorScheme),
          _buildHeader(plant, plan, colorScheme),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWhatIsThis(plan, colorScheme),
                const SizedBox(height: 24),
                _buildProgressSection(plan, colorScheme),
                const SizedBox(height: 24),
                const SectionTitle(
                  title: 'Recovery Steps',
                  icon: Icons.format_list_numbered_rounded,
                ),
                const SizedBox(height: 12),
                _buildSteps(plan.steps, colorScheme),
                const SizedBox(height: 24),
                _buildDoAndDont(plan, colorScheme),
                const SizedBox(height: 24),
                const SectionTitle(
                  title: 'Signs Your Plant Is Getting Better',
                  icon: Icons.trending_up_rounded,
                ),
                const SizedBox(height: 12),
                _buildSignsOfImprovement(plan, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingPlant(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No plant was passed to the recovery screen.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildNoPlan(Plant plant, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.spa_rounded,
              size: 48,
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              '${plant.name} has no active recovery plan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan your plant to detect issues and start a recovery plan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    WidgetRef ref,
    Plant plant,
    ColorScheme colorScheme,
    Object error,
  ) {
    final message = error is ApiException
        ? error.message
        : 'Could not load the recovery plan.';
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
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () =>
                  ref.invalidate(recoveryPlanForPlantProvider(plant.id)),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
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
        icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
      ),
    );
  }

  /// Builds the header with plant name, condition, and severity.
  Widget _buildHeader(
    Plant? plant,
    RecoveryPlan plan,
    ColorScheme colorScheme,
  ) {
    final sevColor = _severityColor(plan.severity);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GradientBanner(
        colors: [colorScheme.primary, const Color(0xFF00695C)],
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.healing_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            if (plant != null) ...[
              Text(
                plant.name,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              plan.condition,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: sevColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sevColor.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                '${plan.severity} Severity',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the "What is this?" explainer section.
  Widget _buildWhatIsThis(RecoveryPlan plan, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'What Is This?',
          icon: Icons.help_outline_rounded,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            plan.summary,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the progress overview with bar and timeline info.
  Widget _buildProgressSection(RecoveryPlan plan, ColorScheme colorScheme) {
    final percentage = (plan.progress * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded,
                  size: 20, color: colorScheme.secondary),
              const SizedBox(width: 8),
              Text(
                'Recovery Progress',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: plan.progress,
              minHeight: 10,
              backgroundColor:
                  colorScheme.secondaryContainer.withValues(alpha: 0.5),
              valueColor:
                  AlwaysStoppedAnimation<Color>(colorScheme.secondary),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildTimelineInfo(
                'Started',
                plan.startedOnLabel,
                Icons.calendar_today_outlined,
                colorScheme,
              ),
              const SizedBox(width: 20),
              _buildTimelineInfo(
                'Est. Recovery',
                plan.estimatedRecoveryLabel,
                Icons.schedule_outlined,
                colorScheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a small timeline info item.
  Widget _buildTimelineInfo(
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the numbered recovery steps as a vertical timeline.
  Widget _buildSteps(BuiltList<RecoveryStep> steps, ColorScheme colorScheme) {
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline indicator
              SizedBox(
                width: 36,
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: step.completed
                            ? colorScheme.secondary
                            : colorScheme.primaryContainer
                                .withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: step.completed
                            ? const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Colors.white,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: step.completed
                              ? colorScheme.secondary.withValues(alpha: 0.3)
                              : colorScheme.outlineVariant
                                  .withValues(alpha: 0.3),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Step content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: step.completed
                        ? colorScheme.secondaryContainer
                            .withValues(alpha: 0.15)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: step.completed
                          ? colorScheme.secondary.withValues(alpha: 0.25)
                          : colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            step.iconData,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              step.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (step.completed)
                            StatusChip(
                              label: 'Done',
                              color: colorScheme.secondary,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        step.description,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color:
                              colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Builds the Do's and Don'ts section side by side.
  Widget _buildDoAndDont(RecoveryPlan plan, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: "Do's & Don'ts",
          icon: Icons.rule_rounded,
        ),
        const SizedBox(height: 12),
        // Do's
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.thumb_up_outlined,
                    size: 18,
                    color: const Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Do This',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...plan.doList.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 16,
                        color: const Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Don'ts
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFC62828).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFC62828).withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.thumb_down_outlined,
                    size: 18,
                    color: const Color(0xFFC62828),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Avoid This',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFC62828),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...plan.dontList.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.cancel_outlined,
                        size: 16,
                        color: const Color(0xFFC62828),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the signs of improvement checklist.
  Widget _buildSignsOfImprovement(
    RecoveryPlan plan,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: plan.signsOfImprovement
            .map(
              (sign) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        sign,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color:
                              colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  /// Returns a color based on severity level.
  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return const Color(0xFF2E7D32);
      case 'moderate':
        return const Color(0xFFE65100);
      case 'severe':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF616161);
    }
  }
}
