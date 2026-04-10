import 'package:flutter/material.dart';

/// A full recovery plan for a plant condition.
class RecoveryPlan {
  final String condition;
  final String severity;
  final String summary;
  final double progress;
  final String startedOn;
  final String estimatedRecovery;
  final List<RecoveryStep> steps;
  final List<String> doList;
  final List<String> dontList;
  final List<String> signsOfImprovement;

  const RecoveryPlan({
    required this.condition,
    required this.severity,
    required this.summary,
    required this.progress,
    required this.startedOn,
    required this.estimatedRecovery,
    required this.steps,
    required this.doList,
    required this.dontList,
    required this.signsOfImprovement,
  });
}

/// A single step in a recovery plan.
class RecoveryStep {
  final String title;
  final String description;
  final IconData icon;
  final bool completed;

  const RecoveryStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.completed,
  });
}
