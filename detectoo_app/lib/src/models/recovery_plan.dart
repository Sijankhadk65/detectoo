import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:flutter/material.dart' hide Builder;

part 'recovery_plan.g.dart';

/// A progress photo uploaded to a recovery step.
abstract class RecoveryStepPhoto
    implements Built<RecoveryStepPhoto, RecoveryStepPhotoBuilder> {
  /// Server-assigned identifier.
  int get id;

  /// Step this photo is attached to.
  int get recoveryStepId;

  /// Full URL of the uploaded photo.
  String get imageUrl;

  /// When the photo was uploaded.
  DateTime get createdAt;

  RecoveryStepPhoto._();

  factory RecoveryStepPhoto([void Function(RecoveryStepPhotoBuilder) updates]) =
      _$RecoveryStepPhoto;

  static Serializer<RecoveryStepPhoto> get serializer =>
      _$recoveryStepPhotoSerializer;
}

/// A full recovery plan for a plant condition.
abstract class RecoveryPlan
    implements Built<RecoveryPlan, RecoveryPlanBuilder> {
  /// Server-assigned identifier. `0` for locally-created mock plans.
  int get id;

  /// Plant this recovery plan is attached to.
  int get plantId;

  /// Optional scan that triggered this recovery plan.
  int? get scanId;

  /// The condition being treated.
  String get condition;

  /// Severity level (e.g. "Mild", "Moderate", "Severe").
  String get severity;

  /// A plain-language explanation of the condition.
  String get summary;

  /// Recovery progress as a value between 0.0 and 1.0.
  double get progress;

  /// When the recovery plan was started.
  DateTime get startedOn;

  /// Estimated time to recovery (e.g. "2–3 weeks"), or `null`.
  String? get estimatedRecovery;

  /// Whether the plan is still being followed.
  bool get isActive;

  /// Ordered list of recovery steps.
  BuiltList<RecoveryStep> get steps;

  /// Things the user should do.
  BuiltList<String> get doList;

  /// Things the user should avoid.
  BuiltList<String> get dontList;

  /// Signs that the plant is improving.
  BuiltList<String> get signsOfImprovement;

  /// Human-readable date label for [startedOn] (e.g. "Apr 3, 2026").
  @BuiltValueField(serialize: false)
  String get startedOnLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[startedOn.month - 1]} ${startedOn.day}, ${startedOn.year}';
  }

  /// Display-safe estimated recovery (never `null`).
  @BuiltValueField(serialize: false)
  String get estimatedRecoveryLabel => estimatedRecovery ?? 'Unknown';

  RecoveryPlan._();

  factory RecoveryPlan([void Function(RecoveryPlanBuilder) updates]) =
      _$RecoveryPlan;

  static Serializer<RecoveryPlan> get serializer => _$recoveryPlanSerializer;
}

/// A single step in a recovery plan.
abstract class RecoveryStep
    implements Built<RecoveryStep, RecoveryStepBuilder> {
  /// Server-assigned identifier. `0` for locally-created mock steps.
  int get id;

  /// Recovery plan this step belongs to.
  int get recoveryPlanId;

  /// The step title.
  String get title;

  /// A detailed description of what to do.
  String get description;

  /// The Material icon code point for display.
  int get iconCodePoint;

  /// Whether this step has been completed.
  bool get completed;

  /// Ordering within the plan.
  int get stepOrder;

  /// Progress photos attached to this step.
  BuiltList<RecoveryStepPhoto> get photos;

  /// Returns the [IconData] for this step's icon.
  @BuiltValueField(serialize: false)
  IconData get iconData =>
      IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  RecoveryStep._();

  factory RecoveryStep([void Function(RecoveryStepBuilder) updates]) =
      _$RecoveryStep;

  static Serializer<RecoveryStep> get serializer => _$recoveryStepSerializer;
}
