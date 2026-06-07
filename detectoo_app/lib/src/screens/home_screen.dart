import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/api_exception.dart';
import '../models/plant.dart';
import '../models/recovery_plan.dart';
import '../models/reminder.dart';
import '../models/task.dart';
import '../providers/api_providers.dart';
import '../providers/auth_provider.dart';
import '../widgets/detectoo_card.dart';
import '../widgets/section_title.dart';
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const VerificationBanner(),
              _buildTopBar(
                context,
                ref,
                colorScheme,
                pendingCount,
                reminderCount,
              ),
              const SizedBox(height: 20),
              _buildGreeting(colorScheme, user?.name),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 0),
                child: const SectionTitle(
                  title: 'Recovery Status',
                  icon: Icons.healing_rounded,
                ),
              ),
              const SizedBox(height: 12),
              _buildRecoveryStatus(context, ref, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the top bar with notification and to-do icons.
  Widget _buildTopBar(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
    int pendingCount,
    int reminderCount,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0, left: 0, right: 20, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Reminders icon
          _buildIconWithBadge(
            icon: Icons.notifications_outlined,
            count: reminderCount,
            color: colorScheme.primary,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
            onTap: () => _showRemindersSheet(context, colorScheme),
          ),
          const SizedBox(width: 12),
          // To-do icon
          _buildIconWithBadge(
            icon: Icons.checklist_rounded,
            count: pendingCount,
            color: colorScheme.secondary,
            backgroundColor: colorScheme.secondary.withValues(alpha: 0.08),
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
    required Color backgroundColor,
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
              color: backgroundColor,
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
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
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
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
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
  Widget _buildGreeting(ColorScheme colorScheme, String? userName) {
    final name = userName ?? 'Plant Lover';

    return Container(
      margin: const EdgeInsets.only(bottom: 0, left: 20, right: 0, top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good Morning,',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
          Text(
            '$name!',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Here's what's happening with your plants today.",
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.45),
            ),
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
      height: 370,
      child: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildRecoveryError(
          context,
          ref,
          colorScheme,
          error,
        ),
        data: (plans) {
          if (plans.isEmpty) {
            return _buildRecoveryEmpty(colorScheme);
          }
          final plants = plantsAsync.valueOrNull ?? const <Plant>[];
          final plantsById = {for (final p in plants) p.id: p};
          const images = ['assets/my_plant_bg.jpg', 'assets/login_bg.jpg'];

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 8),
            itemCount: plans.length,
            separatorBuilder: (_, _) => const SizedBox(width: 0),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.spa_rounded,
              size: 44,
              color: colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 10),
            Text(
              'No active recovery plans',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'All your plants are healthy. Nice work.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.55),
              ),
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
      elevation: 2,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with status badge overlay
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
                  height: 170,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
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
                        const Icon(
                          Icons.healing_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          status.toUpperCase(),
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
          // Plant name and condition
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plantName,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  plan.condition,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PROGRESS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SEVERITY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.severity,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.eco_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
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
                            decoration:
                                done ? TextDecoration.lineThrough : null,
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
                                    ? colorScheme.onSurface
                                        .withValues(alpha: 0.3)
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
        Icon(icon, size: 40, color: colorScheme.primary.withValues(alpha: 0.35)),
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
