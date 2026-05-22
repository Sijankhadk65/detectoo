import 'plant.dart';

/// A single recovery step suggested by Claude during plant detection.
class RecoveryStepDetection {
  const RecoveryStepDetection({
    required this.title,
    required this.description,
    required this.stepOrder,
  });

  final String title;
  final String description;
  final int stepOrder;
}

/// Disease or infestation data returned when Claude spots a health issue.
///
/// Carries everything needed to call [RecoveryRepository.createRecoveryPlan]
/// once the plant has been created.
class RecoveryPlanDetection {
  const RecoveryPlanDetection({
    required this.condition,
    required this.severity,
    required this.summary,
    required this.estimatedRecovery,
    required this.doList,
    required this.dontList,
    required this.signsOfImprovement,
    required this.steps,
  });

  final String condition;
  final String severity;
  final String summary;
  final String? estimatedRecovery;
  final List<String> doList;
  final List<String> dontList;
  final List<String> signsOfImprovement;
  final List<RecoveryStepDetection> steps;
}

/// Transient result returned by the `/plant/from-photo` endpoint.
///
/// Not persisted — used only to pre-fill the confirmation form before
/// the user calls `POST /plant` to actually create the plant.
/// If [recoveryPlan] is non-null, the app should also call
/// `POST /recovery-plan` after the plant is created.
class PlantDetection {
  const PlantDetection({
    required this.name,
    required this.healthStatus,
    required this.iconCodePoint,
    required this.imageUrl,
    required this.sunlight,
    required this.humidity,
    this.recoveryPlan,
  });

  final String name;
  final PlantHealthStatus healthStatus;
  final int iconCodePoint;
  final String imageUrl;
  final String sunlight;
  final String humidity;
  final RecoveryPlanDetection? recoveryPlan;
}
