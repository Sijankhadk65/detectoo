import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/api_exception.dart';
import '../models/plant.dart';
import '../models/recovery_plan.dart';
import '../models/reminder.dart';
import '../models/task.dart';
import '../providers/api_providers.dart';
import '../providers/auth_provider.dart';
import '../theme/detectoo_colors.dart';
import '../theme/detectoo_text_styles.dart';
import '../widgets/detectoo_card.dart';
import '../widgets/eyebrow_label.dart';
import '../widgets/section_title.dart';
import '../widgets/status_chip.dart';
import '../widgets/verification_banner.dart';

/// Dashboard of the Detectoo application.
///
/// Displays a personalized greeting with notification and to-do icons,
/// and plant recovery statuses.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(authProvider).valueOrNull;
    final tasksAsync = ref.watch(careTasksListProvider);
    final remindersAsync = ref.watch(remindersListProvider);

    final pendingCount = tasksAsync.maybeWhen(
      data: (tasks) => tasks.where((t) => !t.done).length,
      orElse: () => 0,
    );
    final reminderCount = remindersAsync.maybeWhen(
      data: (reminders) => reminders.length,
      orElse: () => 0,
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const VerificationBanner(),
              _buildTopBar(context, pendingCount, reminderCount),
              const SizedBox(height: 16),
              _buildGreeting(user?.name),
              const SizedBox(height: 28),
              const Padding(
                padding: EdgeInsets.only(left: 24, right: 24),
                child: SectionTitle(
                  title: 'Active Recovery',
                  icon: Icons.healing_rounded,
                ),
              ),
              const SizedBox(height: 14),
              _buildRecoveryStatus(context, ref, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the top bar with the wordmark and notification / to-do icons.
  Widget _buildTopBar(
    BuildContext context,
    int pendingCount,
    int reminderCount,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: DetectooColors.green600,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.search_rounded,
              size: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'detect',
                  style: DetectooText.h3.copyWith(
                    color: DetectooColors.green900,
                  ),
                ),
                TextSpan(
                  text: 'oo',
                  style: DetectooText.h3.copyWith(
                    color: DetectooColors.green500,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _buildIconWithBadge(
            icon: Icons.notifications_outlined,
            count: reminderCount,
            color: DetectooColors.green700,
            onTap: () => _showRemindersSheet(context, colorScheme),
          ),
          const SizedBox(width: 12),
          _buildIconWithBadge(
            icon: Icons.checklist_rounded,
            count: pendingCount,
            color: DetectooColors.terracotta,
            onTap: () => _showToDoSheet(context, colorScheme),
          ),
        ],
      ),
    );
  }

  /// Builds an icon button with a count badge overlay.
  Widget _buildIconWithBadge({
    required IconData icon,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          if (count > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Shows the To Do list as a bottom sheet.
  void _showToDoSheet(BuildContext context, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TasksSheet(colorScheme: colorScheme),
    );
  }

  /// Shows today's reminders as a bottom sheet.
  void _showRemindersSheet(BuildContext context, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, sheetRef, _) {
            final remindersAsync = sheetRef.watch(remindersListProvider);
            return _SheetContainer(
              title: 'Reminders',
              icon: Icons.notifications_outlined,
              colorScheme: colorScheme,
              trailing: remindersAsync.maybeWhen(
                data: (reminders) => Text(
                  '${reminders.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                orElse: () => null,
              ),
              child: remindersAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => _buildAsyncError(
                  context,
                  colorScheme,
                  error,
                  'Could not load your reminders.',
                  () => sheetRef.invalidate(remindersListProvider),
                ),
                data: (reminders) => reminders.isEmpty
                    ? _buildEmpty(
                        colorScheme,
                        icon: Icons.notifications_none_rounded,
                        message: 'No reminders scheduled',
                      )
                    : _buildRemindersList(reminders, colorScheme),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRemindersList(
    List<Reminder> reminders,
    ColorScheme colorScheme,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: reminders.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        indent: 52,
        color: colorScheme.outlineVariant.withValues(alpha: 0.3),
      ),
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  reminder.iconData,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reminder.timeLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty(
    ColorScheme colorScheme, {
    required IconData icon,
    required String message,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 40,
            color: colorScheme.primary.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsyncError(
    BuildContext context,
    ColorScheme colorScheme,
    Object error,
    String fallback,
    VoidCallback onRetry,
  ) {
    final message = error is ApiException ? error.message : fallback;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 40,
            color: colorScheme.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  /// Builds the personalized greeting.
  Widget _buildGreeting(String? userName) {
    final name = userName ?? 'Plant Parent';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EyebrowLabel('BOTANICAL DASHBOARD'),
          const SizedBox(height: 12),
          Text(
            'Hello,\n$name!',
            style: DetectooText.h1.copyWith(
              color: DetectooColors.green700,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your digital curator has analysed the environment. '
            'Here is what needs your attention today.',
            style: DetectooText.body.copyWith(color: DetectooColors.textMuted),
          ),
        ],
      ),
    );
  }

  /// Builds the plant recovery status cards.
  Widget _buildRecoveryStatus(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
  ) {
    final plansAsync = ref.watch(recoveryPlansProvider);
    final plantsAsync = ref.watch(plantsListProvider);

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 340,
      child: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            _buildRecoveryError(context, ref, colorScheme, error),
        data: (plans) {
          if (plans.isEmpty) {
            return _buildRecoveryEmpty(colorScheme);
          }
          final plants = plantsAsync.valueOrNull ?? const <Plant>[];
          final plantsById = {for (final p in plants) p.id: p};
          const images = ['assets/my_plant_bg.jpg', 'assets/login_bg.jpg'];

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
            itemCount: plans.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final plan = plans[index];
              final plant = plantsById[plan.plantId];
              return SizedBox(
                width: 300,
                child: _buildRecoveryCard(
                  context,
                  plan,
                  plant,
                  images[index % images.length],
                  colorScheme,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRecoveryEmpty(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: DetectooCard(
        variant: DetectooCardVariant.cream,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.spa_rounded,
              size: 44,
              color: DetectooColors.green600.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 10),
            Text('No active recovery plans.', style: DetectooText.h3),
            const SizedBox(height: 6),
            Text(
              'All your specimens are thriving. Nice work.',
              textAlign: TextAlign.center,
              style: DetectooText.small,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoveryError(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
    Object error,
  ) {
    final message = error is ApiException
        ? error.message
        : 'Could not load recovery plans.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: DetectooColors.textFaint,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: DetectooText.small,
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () => ref.invalidate(recoveryPlansProvider),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single recovery card with image header, status badge,
  /// and stats row.
  Widget _buildRecoveryCard(
    BuildContext context,
    RecoveryPlan plan,
    Plant? plant,
    String imagePath,
    ColorScheme colorScheme,
  ) {
    final percentage = (plan.progress * 100).toInt();
    final plantName = plant?.name ?? 'Plant #${plan.plantId}';
    final status = _statusForProgress(plan.progress);

    return DetectooCard(
      clip: true,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with status badge overlay
          Stack(
            children: [
              Image.asset(
                imagePath,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 12,
                left: 12,
                child: StatusChip(
                  label: status,
                  accent: true,
                  icon: Icons.healing_rounded,
                ),
              ),
            ],
          ),
          // Plant name and condition
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plantName, style: DetectooText.h3),
                const SizedBox(height: 2),
                Text(
                  plan.condition,
                  style: DetectooText.small,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Day ${(plan.progress * 14).round()} of recovery',
                      style: DetectooText.small,
                    ),
                    Text(
                      '$percentage%',
                      style: DetectooText.bodyStrong.copyWith(
                        color: DetectooColors.green600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: plan.progress.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: DetectooColors.green100,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      DetectooColors.green500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Stats row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _statColumn(
                    'SEVERITY',
                    plan.severity,
                    DetectooColors.terracotta,
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: DetectooColors.borderSoft,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statColumn(
                    'CONDITION',
                    plan.condition,
                    DetectooColors.green700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// A small labelled stat for the recovery card footer.
  Widget _statColumn(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DetectooText.eyebrow.copyWith(
            color: DetectooColors.textFaint,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: DetectooText.bodyStrong.copyWith(color: valueColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _statusForProgress(double progress) {
    if (progress >= 0.75) return 'Almost Healthy';
    if (progress >= 0.35) return 'Recovering';
    return 'Treatment Started';
  }
}

/// Shared container chrome for the home-screen bottom sheets.
class _SheetContainer extends StatelessWidget {
  const _SheetContainer({
    required this.title,
    required this.icon,
    required this.colorScheme,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final ColorScheme colorScheme;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                SectionTitle(title: title, icon: icon),
                const Spacer(),
                ?trailing,
              ],
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          Flexible(child: child),
        ],
      ),
    );
  }
}

/// To-do bottom sheet with optimistic toggle state so taps respond
/// instantly and errors can revert the UI.
class _TasksSheet extends ConsumerStatefulWidget {
  const _TasksSheet({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  ConsumerState<_TasksSheet> createState() => _TasksSheetState();
}

class _TasksSheetState extends ConsumerState<_TasksSheet> {
  final Map<int, bool> _overrides = {};
  final Set<int> _inFlight = {};

  Future<void> _toggle(Task task) async {
    if (_inFlight.contains(task.id)) return;
    final current = _overrides[task.id] ?? task.done;
    final next = !current;
    setState(() {
      _overrides[task.id] = next;
      _inFlight.add(task.id);
    });

    try {
      await ref
          .read(careTasksRepositoryProvider)
          .updateCareTask(task.id, done: next);
      if (!mounted) return;
      ref.invalidate(careTasksListProvider);
      setState(() {
        _overrides.remove(task.id);
        _inFlight.remove(task.id);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _overrides.remove(task.id);
        _inFlight.remove(task.id);
      });
      final message = error is ApiException
          ? error.message
          : 'Could not update task. Try again.';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  bool _effectiveDone(Task task) => _overrides[task.id] ?? task.done;

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.colorScheme;
    final tasksAsync = ref.watch(careTasksListProvider);

    return _SheetContainer(
      title: 'To Do',
      icon: Icons.checklist_rounded,
      colorScheme: colorScheme,
      trailing: tasksAsync.maybeWhen(
        data: (tasks) {
          final done = tasks.where(_effectiveDone).length;
          return Text(
            '$done/${tasks.length}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          );
        },
        orElse: () => null,
      ),
      child: tasksAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => _sheetError(
          colorScheme,
          error,
          'Could not load your tasks.',
          () => ref.invalidate(careTasksListProvider),
        ),
        data: (tasks) => tasks.isEmpty
            ? _sheetEmpty(
                colorScheme,
                icon: Icons.check_circle_outline_rounded,
                message: 'Nothing to do right now',
              )
            : _buildList(tasks, colorScheme),
      ),
    );
  }

  Widget _buildList(List<Task> tasks, ColorScheme colorScheme) {
    return Material(
      color: Colors.transparent,
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: tasks.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          indent: 52,
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        itemBuilder: (context, index) {
          final task = tasks[index];
          final done = _effectiveDone(task);
          return InkWell(
            onTap: () => _toggle(task),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: done ? colorScheme.secondary : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: done
                            ? colorScheme.secondary
                            : colorScheme.outline.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: done
                        ? const Icon(
                            Icons.check_rounded,
                            size: 15,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: done
                                ? colorScheme.onSurface.withValues(alpha: 0.4)
                                : colorScheme.onSurface,
                            decoration: done
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 12,
                              color: done
                                  ? colorScheme.onSurface.withValues(alpha: 0.3)
                                  : colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.dueDateLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: done
                                    ? colorScheme.onSurface.withValues(
                                        alpha: 0.3,
                                      )
                                    : colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget _sheetEmpty(
  ColorScheme colorScheme, {
  required IconData icon,
  required String message,
}) {
  return Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 40,
          color: colorScheme.primary.withValues(alpha: 0.35),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    ),
  );
}

Widget _sheetError(
  ColorScheme colorScheme,
  Object error,
  String fallback,
  VoidCallback onRetry,
) {
  final message = error is ApiException ? error.message : fallback;
  return Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.cloud_off_rounded,
          size: 40,
          color: colorScheme.onSurface.withValues(alpha: 0.35),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('Try again'),
        ),
      ],
    ),
  );
}
