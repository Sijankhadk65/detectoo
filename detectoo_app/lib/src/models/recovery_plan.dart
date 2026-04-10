import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:flutter/material.dart' hide Builder;

part 'recovery_plan.g.dart';

/// A full recovery plan for a plant condition.
abstract class RecoveryPlan
    implements Built<RecoveryPlan, RecoveryPlanBuilder> {
  /// The condition being treated.
  String get condition;

  /// Severity level (e.g. "Mild", "Moderate", "Severe").
  String get severity;

  /// A plain-language explanation of the condition.
  String get summary;

  /// Recovery progress as a value between 0.0 and 1.0.
  double get progress;

  /// When the recovery plan was started (e.g. "Apr 3, 2026").
  String get startedOn;

  /// Estimated time to recovery (e.g. "2–3 weeks").
  String get estimatedRecovery;

  /// Ordered list of recovery steps.
  BuiltList<RecoveryStep> get steps;

  /// Things the user should do.
  BuiltList<String> get doList;

  /// Things the user should avoid.
  BuiltList<String> get dontList;

  /// Signs that the plant is improving.
  BuiltList<String> get signsOfImprovement;

  RecoveryPlan._();

  factory RecoveryPlan([void Function(RecoveryPlanBuilder) updates]) =
      _$RecoveryPlan;

  static Serializer<RecoveryPlan> get serializer => _$recoveryPlanSerializer;
}

/// A single step in a recovery plan.
abstract class RecoveryStep
    implements Built<RecoveryStep, RecoveryStepBuilder> {
  /// The step title.
  String get title;

  /// A detailed description of what to do.
  String get description;

  /// The Material icon code point for display.
  int get iconCodePoint;

  /// Whether this step has been completed.
  bool get completed;

  /// Returns the [IconData] for this step's icon.
  @BuiltValueField(serialize: false)
  IconData get iconData =>
      IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  RecoveryStep._();

  factory RecoveryStep([void Function(RecoveryStepBuilder) updates]) =
      _$RecoveryStep;

  static Serializer<RecoveryStep> get serializer => _$recoveryStepSerializer;
}
