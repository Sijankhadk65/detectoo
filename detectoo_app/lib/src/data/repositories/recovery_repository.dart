import '../../models/recovery_plan.dart';

/// Domain contract for recovery plans and their steps.
///
/// Screens and providers depend on this interface, never on
/// [ApiClient] directly, so the transport can be faked in tests.
abstract class RecoveryRepository {
  /// Fetches a page of recovery plans for the authenticated user.
  ///
  /// Plans returned here carry an empty [RecoveryPlan.steps] list —
  /// call [getRecoveryPlan] to load a plan with its ordered steps.
  Future<List<RecoveryPlan>> listRecoveryPlans({
    int? plantId,
    bool? isActive,
    int page = 1,
    int itemsPerPage = 100,
  });

  /// Fetches a single recovery plan with all its steps.
  Future<RecoveryPlan> getRecoveryPlan(int id);

  /// Creates a recovery plan (with its nested steps) for a plant.
  Future<RecoveryPlan> createRecoveryPlan({
    required int plantId,
    required String condition,
    required String severity,
    required String summary,
    String? estimatedRecovery,
    int? scanId,
    List<RecoveryStepDraft> steps = const [],
    List<String> doList = const [],
    List<String> dontList = const [],
    List<String> signsOfImprovement = const [],
  });

  /// Updates plan-level fields. Only non-null arguments are sent.
  Future<void> updateRecoveryPlan(
    int id, {
    String? condition,
    String? severity,
    String? summary,
    double? progress,
    String? estimatedRecovery,
    bool? isActive,
    List<String>? doList,
    List<String>? dontList,
    List<String>? signsOfImprovement,
  });

  /// Soft-deletes a recovery plan.
  Future<void> deleteRecoveryPlan(int id);

  /// Updates a single step (typically to mark it completed).
  Future<void> updateRecoveryStep(
    int planId,
    int stepId, {
    String? title,
    String? description,
    int? iconCodePoint,
    bool? completed,
    int? stepOrder,
  });
}

/// Minimal step payload used when creating a new [RecoveryPlan].
///
/// The backend creates steps in one call alongside the plan, so
/// they don't have an id yet.
class RecoveryStepDraft {
  /// Creates a new draft step.
  const RecoveryStepDraft({
    required this.title,
    required this.description,
    required this.iconCodePoint,
    this.stepOrder = 0,
  });

  /// Short step title.
  final String title;

  /// Longer description shown to the user.
  final String description;

  /// Material icon code point.
  final int iconCodePoint;

  /// Ordering within the plan; lower values come first.
  final int stepOrder;
}
