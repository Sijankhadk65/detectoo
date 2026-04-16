import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/recovery.dart';
import '../models/task.dart';
import '../providers/auth_provider.dart';
import '../widgets/detectoo_card.dart';
import '../widgets/section_title.dart';

/// Dashboard of the Detectoo application.
///
/// Displays a personalized greeting with notification and to-do icons,
/// and plant recovery statuses.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // TODO: Replace with actual data.
  // Sorted: incomplete tasks earliest-first, then completed at the end.
  static final _tasks = [
    Task(
      (b) => b
        ..title = 'Water the Monstera'
        ..dueDate = 'Today, 8:00 AM'
        ..done = false,
    ),
    Task(
      (b) => b
        ..title = 'Move Fern to shade'
        ..dueDate = 'Today, 12:00 PM'
        ..done = false,
    ),
    Task(
      (b) => b
        ..title = 'Fertilize Aloe Vera'
        ..dueDate = 'Tomorrow, 9:00 AM'
        ..done = false,
    ),
    Task(
      (b) => b
        ..title = 'Repot the Snake Plant'
        ..dueDate = 'Tomorrow, 2:00 PM'
        ..done = false,
    ),
    Task(
      (b) => b
        ..title = 'Prune dead leaves on Pothos'
        ..dueDate = 'Wed, 8:00 AM'
        ..done = false,
    ),
    Task(
      (b) => b
        ..title = 'Check soil pH for Roses'
        ..dueDate = 'Thu, 3:00 PM'
        ..done = false,
    ),
    Task(
      (b) => b
        ..title = 'Buy potting soil'
        ..dueDate = 'Yesterday, 10:00 AM'
        ..done = true,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(authProvider);
    final pendingCount = _tasks.where((t) => !t.done).length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context, colorScheme, pendingCount),
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
              _buildRecoveryStatus(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the top bar with notification and to-do icons.
  Widget _buildTopBar(
    BuildContext context,
    ColorScheme colorScheme,
    int pendingCount,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0, left: 0, right: 20, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Notifications icon
          _buildIconWithBadge(
            icon: Icons.notifications_outlined,
            count: 3,
            color: colorScheme.primary,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
            onTap: () {
              // TODO: Show notifications
            },
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
    final doneCount = _tasks.where((t) => t.done).length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    const SectionTitle(
                      title: 'To Do',
                      icon: Icons.checklist_rounded,
                    ),
                    const Spacer(),
                    Text(
                      '$doneCount/${_tasks.length}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
              // Task list
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _tasks.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    indent: 52,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // Checkbox
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: task.done
                                  ? colorScheme.secondary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: task.done
                                    ? colorScheme.secondary
                                    : colorScheme.outline.withValues(
                                        alpha: 0.4,
                                      ),
                                width: 1.5,
                              ),
                            ),
                            child: task.done
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 15,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          // Title and due date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: task.done
                                        ? colorScheme.onSurface.withValues(
                                            alpha: 0.4,
                                          )
                                        : colorScheme.onSurface,
                                    decoration: task.done
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
                                      color: task.done
                                          ? colorScheme.onSurface.withValues(
                                              alpha: 0.3,
                                            )
                                          : colorScheme.secondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      task.dueDate,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: task.done
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
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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
  Widget _buildRecoveryStatus(BuildContext context, ColorScheme colorScheme) {
    // TODO: Replace with actual recovery data.
    final recoveries = [
      (
        recovery: Recovery(
          (b) => b
            ..plantName = 'Rose Bush'
            ..condition = 'Black Spot Fungus'
            ..progress = 0.7
            ..status = 'Recovering',
        ),
        image: 'assets/my_plant_bg.jpg',
      ),
      (
        recovery: Recovery(
          (b) => b
            ..plantName = 'Tomato Plant'
            ..condition = 'Leaf Blight'
            ..progress = 0.3
            ..status = 'Treatment Started',
        ),
        image: 'assets/login_bg.jpg',
      ),
      (
        recovery: Recovery(
          (b) => b
            ..plantName = 'Basil'
            ..condition = 'Root Rot'
            ..progress = 0.9
            ..status = 'Almost Healthy',
        ),
        image: 'assets/my_plant_bg.jpg',
      ),
    ];

    // Break out of parent padding so cards scroll edge-to-edge.
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 370,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(bottom: 8),
        itemCount: recoveries.length,
        separatorBuilder: (_, _) => const SizedBox(width: 0),
        itemBuilder: (context, index) {
          final r = recoveries[index];
          return SizedBox(
            width: 300,
            child: _buildRecoveryCard(r.recovery, r.image, colorScheme),
          );
        },
      ),
    );
  }

  /// Builds a single recovery card with image header, status badge,
  /// and stats row.
  Widget _buildRecoveryCard(
    Recovery recovery,
    String imagePath,
    ColorScheme colorScheme,
  ) {
    final percentage = (recovery.progress * 100).toInt();

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
                // Status badge
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
                          recovery.status.toUpperCase(),
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
                  recovery.plantName,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  recovery.condition,
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
                // Progress stat
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
                // Divider
                Container(
                  width: 1,
                  height: 36,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 16),
                // Condition stat
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
                        recovery.progress >= 0.7
                            ? 'Mild'
                            : recovery.progress >= 0.4
                            ? 'Moderate'
                            : 'Severe',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Recovery icon
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
}
