import 'package:flutter/material.dart';

import '../models/plant.dart';
import '../models/recovery_plan.dart';
import '../widgets/icon_badge.dart';
import '../widgets/section_title.dart';
import '../widgets/status_chip.dart';

/// Recovery screen for the Detectoo application.
///
/// Displays a detailed, easy-to-understand recovery plan for an
/// affected plant. Designed to be informative for users with no
/// prior plant care expertise.
class RecoveryScreen extends StatelessWidget {
  const RecoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plant = ModalRoute.of(context)?.settings.arguments as Plant?;
    final colorScheme = Theme.of(context).colorScheme;

    // TODO: Replace with actual recovery plan data based on the plant.
    final plan = RecoveryPlan(
      condition: 'Black Spot Fungus',
      severity: 'Moderate',
      summary:
          'Black spot is a common fungal disease that causes dark spots on '
          'leaves. It spreads through water splashing on infected leaves. '
          "Don't worry — with the right care, your plant can fully recover "
          'in a few weeks.',
      progress: 0.6,
      startedOn: 'Apr 3, 2026',
      estimatedRecovery: '2–3 weeks',
      steps: const [
        RecoveryStep(
          title: 'Remove affected leaves',
          description:
              'Gently pluck off any leaves with dark spots. This stops '
              'the fungus from spreading to healthy parts of the plant.',
          icon: Icons.content_cut_rounded,
          completed: true,
        ),
        RecoveryStep(
          title: 'Apply fungicide spray',
          description:
              'Use a mild fungicide (like neem oil mixed with water) and '
              'spray it on the remaining leaves. Do this once every 5 days.',
          icon: Icons.shower_outlined,
          completed: true,
        ),
        RecoveryStep(
          title: 'Improve air circulation',
          description:
              'Move your plant to a spot with better airflow. Avoid '
              'crowding it with other plants. Good air flow helps leaves '
              'dry faster and prevents fungus growth.',
          icon: Icons.air_rounded,
          completed: true,
        ),
        RecoveryStep(
          title: 'Adjust watering method',
          description:
              'Water the soil directly, not the leaves. Wet leaves are '
              "the main reason fungus spreads. It's best to water in the "
              'morning so any splashes dry during the day.',
          icon: Icons.water_drop_outlined,
          completed: false,
        ),
        RecoveryStep(
          title: 'Monitor for new spots',
          description:
              'Check your plant every 2–3 days. If you see new spots '
              'appearing, repeat the fungicide spray. If no new spots '
              'appear for 2 weeks, your plant is recovering well!',
          icon: Icons.visibility_outlined,
          completed: false,
        ),
      ],
      doList: const [
        'Water at the base of the plant, not on the leaves',
        'Keep the plant in a spot with good sunlight and air flow',
        'Clean up any fallen leaves from the soil surface',
        'Wash your hands after handling the affected plant',
      ],
      dontList: const [
        "Don't mist or spray water on the leaves",
        "Don't place this plant too close to your other plants",
        "Don't over-fertilize — it can stress the plant further",
        "Don't ignore new spots — treat them early",
      ],
      signsOfImprovement: const [
        'No new dark spots appearing on leaves',
        'New healthy green leaves growing',
        'Existing spots not getting larger',
        'Plant looks more vibrant and upright',
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          IconBadge(
            icon: Icons.healing_rounded,
            iconSize: 36,
            padding: 14,
            borderRadius: 16,
            backgroundColor:
                colorScheme.primaryContainer.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 14),
          if (plant != null) ...[
            Text(
              plant.name,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            plan.condition,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 10),
          StatusChip(
            label: '${plan.severity} Severity',
            color: _severityColor(plan.severity),
            showBorder: true,
          ),
        ],
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
              Icon(Icons.timeline_rounded, size: 20, color: colorScheme.primary),
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
                  color: colorScheme.primary,
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
                  colorScheme.primaryContainer.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildTimelineInfo(
                'Started',
                plan.startedOn,
                Icons.calendar_today_outlined,
                colorScheme,
              ),
              const SizedBox(width: 20),
              _buildTimelineInfo(
                'Est. Recovery',
                plan.estimatedRecovery,
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
  Widget _buildSteps(List<RecoveryStep> steps, ColorScheme colorScheme) {
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
                            ? colorScheme.primary
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
                              ? colorScheme.primary.withValues(alpha: 0.3)
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
                        ? colorScheme.primaryContainer.withValues(alpha: 0.12)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: step.completed
                          ? colorScheme.primary.withValues(alpha: 0.2)
                          : colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            step.icon,
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
                              color: colorScheme.primary,
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
