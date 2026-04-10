import 'package:flutter/material.dart';

import '../models/recovery.dart';
import '../models/reminder.dart';
import '../models/task.dart';

/// Dashboard of the Detectoo application.
///
/// Displays reminders, tasks/todos, and plant recovery statuses
/// to give users a quick overview of their plant care activity.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(colorScheme),
              const SizedBox(height: 24),
              _buildSectionTitle('Reminders', Icons.notifications_outlined, colorScheme),
              const SizedBox(height: 12),
              _buildReminders(colorScheme),
              const SizedBox(height: 24),
              _buildSectionTitle('Tasks', Icons.checklist_rounded, colorScheme),
              const SizedBox(height: 12),
              _buildTasks(colorScheme),
              const SizedBox(height: 24),
              _buildSectionTitle('Recovery Status', Icons.healing_rounded, colorScheme),
              const SizedBox(height: 12),
              _buildRecoveryStatus(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the greeting header with the user's name and today's date.
  Widget _buildGreeting(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning! 🌱',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Here's what's happening with your plants today.",
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.local_florist_rounded,
              size: 32,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a section title row with an icon and heading text.
  Widget _buildSectionTitle(
    String title,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 22, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  /// Builds the reminders list.
  Widget _buildReminders(ColorScheme colorScheme) {
    // TODO: Replace with actual reminder data.
    final reminders = [
      Reminder(
        title: 'Water the Monstera',
        time: 'Today, 8:00 AM',
        icon: Icons.water_drop_outlined,
      ),
      Reminder(
        title: 'Move Fern to shade',
        time: 'Today, 12:00 PM',
        icon: Icons.wb_shade_outlined,
      ),
      Reminder(
        title: 'Fertilize Aloe Vera',
        time: 'Tomorrow, 9:00 AM',
        icon: Icons.science_outlined,
      ),
    ];

    return Column(
      children: reminders.map((r) => _buildReminderCard(r, colorScheme)).toList(),
    );
  }

  /// Builds a single reminder card.
  Widget _buildReminderCard(Reminder reminder, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(reminder.icon, size: 20, color: colorScheme.primary),
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
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reminder.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
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
    );
  }

  /// Builds the tasks/todos list with checkboxes.
  Widget _buildTasks(ColorScheme colorScheme) {
    // TODO: Replace with actual task data.
    final tasks = [
      Task(title: 'Repot the Snake Plant', done: false),
      Task(title: 'Buy potting soil', done: true),
      Task(title: 'Prune dead leaves on Pothos', done: false),
      Task(title: 'Check soil pH for Roses', done: false),
    ];

    return Column(
      children: tasks.map((t) => _buildTaskCard(t, colorScheme)).toList(),
    );
  }

  /// Builds a single task card with a checkbox indicator.
  Widget _buildTaskCard(Task task, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: task.done
                  ? colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: task.done
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: task.done
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: task.done
                    ? colorScheme.onSurface.withValues(alpha: 0.4)
                    : colorScheme.onSurface,
                decoration: task.done ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the plant recovery status cards.
  Widget _buildRecoveryStatus(ColorScheme colorScheme) {
    // TODO: Replace with actual recovery data.
    final recoveries = [
      Recovery(
        plantName: 'Rose Bush',
        condition: 'Black Spot Fungus',
        progress: 0.7,
        status: 'Recovering',
      ),
      Recovery(
        plantName: 'Tomato Plant',
        condition: 'Leaf Blight',
        progress: 0.3,
        status: 'Treatment Started',
      ),
      Recovery(
        plantName: 'Basil',
        condition: 'Root Rot',
        progress: 0.9,
        status: 'Almost Healthy',
      ),
    ];

    return Column(
      children: recoveries.map((r) => _buildRecoveryCard(r, colorScheme)).toList(),
    );
  }

  /// Builds a single recovery status card with a progress indicator.
  Widget _buildRecoveryCard(Recovery recovery, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.eco_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recovery.plantName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      recovery.condition,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  recovery.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: recovery.progress,
              minHeight: 6,
              backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(recovery.progress * 100).toInt()}% recovered',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
