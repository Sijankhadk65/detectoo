import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../data/api/api_exception.dart';
import '../models/plant.dart';
import '../models/recovery_plan.dart';
import '../providers/api_providers.dart';
import '../services/notification_service.dart';
import '../theme/detectoo_colors.dart';
import '../theme/detectoo_text_styles.dart';
import '../widgets/detectoo_card.dart';
import '../widgets/eyebrow_label.dart';
import '../widgets/section_title.dart';
import '../widgets/status_chip.dart';

/// Recovery screen for the Detectoo application.
///
/// Displays a detailed, easy-to-understand recovery plan for an
/// affected plant. Supports uploading progress photos to individual steps.
class RecoveryScreen extends ConsumerStatefulWidget {
  const RecoveryScreen({super.key});

  @override
  ConsumerState<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends ConsumerState<RecoveryScreen> {
  /// Step IDs currently being uploaded to (to show per-step loading indicator).
  final Set<int> _uploadingSteps = {};

  /// Step IDs currently being marked as done.
  final Set<int> _completingSteps = {};

  Future<void> _markStepDone(RecoveryPlan plan, RecoveryStep step) async {
    setState(() => _completingSteps.add(step.id));
    try {
      await ref
          .read(recoveryRepositoryProvider)
          .updateRecoveryStep(plan.id, step.id, completed: true);
      await NotificationService.cancelStepReminder(step.id);
      ref.invalidate(recoveryPlanForPlantProvider(plan.plantId));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update step. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _completingSteps.remove(step.id));
    }
  }

  Future<void> _pickAndUploadPhoto(RecoveryPlan plan, RecoveryStep step) async {
    final picker = ImagePicker();
    final source = await _askImageSource();
    if (source == null || !mounted) return;

    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null || !mounted) return;

    setState(() => _uploadingSteps.add(step.id));
    try {
      await ref
          .read(recoveryRepositoryProvider)
          .uploadStepPhoto(plan.id, step.id, File(picked.path));
      ref.invalidate(recoveryPlanForPlantProvider(plan.plantId));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload photo. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingSteps.remove(step.id));
    }
  }

  Future<ImageSource?> _askImageSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                _buildSteps(plan, plan.steps, colorScheme, _completingSteps),
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
              '${plant.name} has no active recovery plan.',
              textAlign: TextAlign.center,
              style: DetectooText.h3,
            ),
            const SizedBox(height: 8),
            Text(
              'Scan your plant to detect issues and start a recovery plan.',
              textAlign: TextAlign.center,
              style: DetectooText.small,
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

  /// Builds the header: eyebrow, title, summary, moody plant image, and a
  /// critical-care alert overlay.
  Widget _buildHeader(
    Plant? plant,
    RecoveryPlan plan,
    ColorScheme colorScheme,
  ) {
    final plantName = plant?.name ?? 'Your specimen';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EyebrowLabel('DIAGNOSIS CONFIRMED'),
          const SizedBox(height: 10),
          Text('$plantName Recovery.', style: DetectooText.h1),
          const SizedBox(height: 10),
          Text(
            plan.summary,
            style: DetectooText.body.copyWith(color: DetectooColors.textMuted),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        DetectooColors.surfaceDark,
                        DetectooColors.surfaceDarkDeep,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      plant?.iconData ?? Icons.local_florist_rounded,
                      size: 64,
                      color: DetectooColors.green300.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DetectooColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: DetectooShadows.card,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_rounded,
                        size: 18,
                        color: DetectooColors.terracotta,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${plan.severity} severity — ',
                                style: DetectooText.small.copyWith(
                                  color: DetectooColors.terracotta,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text: plan.condition,
                                style: DetectooText.small,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
        DetectooCard(
          variant: DetectooCardVariant.cream,
          padding: const EdgeInsets.all(16),
          child: Text(
            plan.summary,
            style: DetectooText.body.copyWith(color: DetectooColors.textBody),
          ),
        ),
      ],
    );
  }

  /// Builds the progress overview with bar and timeline info.
  Widget _buildProgressSection(RecoveryPlan plan, ColorScheme colorScheme) {
    final percentage = (plan.progress * 100).toInt();

    return DetectooCard(
      variant: DetectooCardVariant.dark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recovery Progress',
                style: DetectooText.h3.copyWith(color: Colors.white),
              ),
              const Spacer(),
              Text(
                '$percentage%',
                style: DetectooText.h3.copyWith(color: DetectooColors.green300),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: plan.progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(
                DetectooColors.green500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTimelineInfo(
                'Started',
                plan.startedOnLabel,
                Icons.calendar_today_outlined,
              ),
              const SizedBox(width: 24),
              _buildTimelineInfo(
                'Est. Recovery',
                plan.estimatedRecoveryLabel,
                Icons.schedule_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a small timeline info item for the dark vitals card.
  Widget _buildTimelineInfo(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: DetectooColors.green300),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: DetectooText.small.copyWith(
                color: DetectooColors.textOnDarkMuted,
              ),
            ),
            Text(
              value,
              style: DetectooText.bodyStrong.copyWith(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the numbered recovery steps as a vertical timeline.
  Widget _buildSteps(
    RecoveryPlan plan,
    BuiltList<RecoveryStep> steps,
    ColorScheme colorScheme,
    Set<int> completingSteps,
  ) {
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        final isUploading = _uploadingSteps.contains(step.id);
        final isCompleting = completingSteps.contains(step.id);

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
                            ? DetectooColors.green600
                            : DetectooColors.green100,
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
                                style: DetectooText.small.copyWith(
                                  color: DetectooColors.green700,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: step.completed
                              ? DetectooColors.green300
                              : DetectooColors.borderSoft,
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
                        ? DetectooColors.green050
                        : DetectooColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: step.completed ? null : DetectooShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            step.iconData,
                            size: 18,
                            color: DetectooColors.green600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(step.title, style: DetectooText.h3),
                          ),
                          if (step.completed)
                            const StatusChip(label: 'Done')
                          else if (isCompleting)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: DetectooColors.green600,
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: () => _markStepDone(plan, step),
                              child: const StatusChip(
                                label: 'Mark done',
                                icon: Icons.check_circle_outline_rounded,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        step.description,
                        style: DetectooText.small.copyWith(
                          color: DetectooColors.textBody,
                          height: 1.5,
                        ),
                      ),
                      // Photo gallery + add button
                      const SizedBox(height: 12),
                      _buildStepPhotoRow(plan, step, colorScheme, isUploading),
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

  /// Builds the horizontal photo strip and "Add photo" button for a step.
  Widget _buildStepPhotoRow(
    RecoveryPlan plan,
    RecoveryStep step,
    ColorScheme colorScheme,
    bool isUploading,
  ) {
    final photos = step.photos;
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...photos.map(
            (photo) => GestureDetector(
              onTap: () => _viewPhoto(photo.imageUrl),
              child: Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(right: 8),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: colorScheme.surfaceContainerHighest,
                ),
                child: Image.network(
                  photo.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Icon(
                    Icons.broken_image_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
          // Add photo button
          GestureDetector(
            onTap: isUploading ? null : () => _pickAndUploadPhoto(plan, step),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.25),
                  style: BorderStyle.solid,
                ),
              ),
              child: isUploading
                  ? Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.add_a_photo_rounded,
                      size: 24,
                      color: colorScheme.primary.withValues(alpha: 0.7),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Opens a full-screen photo viewer.
  void _viewPhoto(String imageUrl) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) => const Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white54,
                  size: 60,
                ),
              ),
            ),
            Positioned(
              top: -12,
              right: -12,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the Do's and Don'ts section side by side.
  Widget _buildDoAndDont(RecoveryPlan plan, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: "Do's & Don'ts", icon: Icons.rule_rounded),
        const SizedBox(height: 12),
        // Do's
        _buildDoDontCard(
          title: 'Do This',
          icon: Icons.thumb_up_outlined,
          itemIcon: Icons.check_circle_outline_rounded,
          color: DetectooColors.green600,
          background: DetectooColors.green050,
          items: plan.doList,
        ),
        const SizedBox(height: 12),
        // Don'ts
        _buildDoDontCard(
          title: 'Avoid This',
          icon: Icons.thumb_down_outlined,
          itemIcon: Icons.cancel_outlined,
          color: DetectooColors.terracotta,
          background: DetectooColors.terracottaBg,
          items: plan.dontList,
        ),
      ],
    );
  }

  /// Builds one of the Do / Don't cards.
  Widget _buildDoDontCard({
    required String title,
    required IconData icon,
    required IconData itemIcon,
    required Color color,
    required Color background,
    required BuiltList<String> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: DetectooText.bodyStrong.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(itemIcon, size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: DetectooText.small.copyWith(
                        color: DetectooColors.textBody,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the signs of improvement checklist.
  Widget _buildSignsOfImprovement(RecoveryPlan plan, ColorScheme colorScheme) {
    return DetectooCard(
      variant: DetectooCardVariant.cream,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: plan.signsOfImprovement
            .map(
              (sign) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: DetectooColors.green500,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        sign,
                        style: DetectooText.small.copyWith(
                          color: DetectooColors.textBody,
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
}
