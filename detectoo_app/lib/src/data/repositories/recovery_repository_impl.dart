import 'dart:io';

import '../../models/recovery_plan.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import 'recovery_repository.dart';

/// HTTP-backed [RecoveryRepository] against the FastAPI backend.
class RecoveryRepositoryImpl implements RecoveryRepository {
  /// Creates a [RecoveryRepositoryImpl] bound to [client].
  RecoveryRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<List<RecoveryPlan>> listRecoveryPlans({
    int? plantId,
    bool? isActive,
    int page = 1,
    int itemsPerPage = 100,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'items_per_page': itemsPerPage,
      'plant_id': ?plantId,
      'is_active': ?isActive,
    };
    final json = await _client.get('/recovery-plans', query: query)
        as Map<String, dynamic>;

    final items = json['data'];
    if (items is! List) {
      throw const ApiException(
        message: 'Unexpected recovery plans list shape',
        type: ApiExceptionType.unknown,
      );
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map((plan) => _mapPlan(plan, steps: const []))
        .toList(growable: false);
  }

  @override
  Future<RecoveryPlan> getRecoveryPlan(int id) async {
    final json =
        await _client.get('/recovery-plan/$id') as Map<String, dynamic>;
    final rawSteps = json['steps'];
    final steps = rawSteps is List
        ? rawSteps
            .whereType<Map<String, dynamic>>()
            .map(_mapStep)
            .toList(growable: false)
        : const <RecoveryStep>[];

    return _mapPlan(json, steps: steps);
  }

  @override
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
  }) async {
    final body = <String, dynamic>{
      'plant_id': plantId,
      'condition': condition,
      'severity': severity,
      'summary': summary,
      'estimated_recovery': ?estimatedRecovery,
      'scan_id': ?scanId,
      'do_list': doList,
      'dont_list': dontList,
      'signs_of_improvement': signsOfImprovement,
      'steps': steps.map(_stepDraftToJson).toList(),
    };
    final json = await _client.post('/recovery-plan', body: body)
        as Map<String, dynamic>;

    final rawSteps = json['steps'];
    final createdSteps = rawSteps is List
        ? rawSteps
            .whereType<Map<String, dynamic>>()
            .map(_mapStep)
            .toList(growable: false)
        : const <RecoveryStep>[];

    return _mapPlan(json, steps: createdSteps);
  }

  @override
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
  }) async {
    final body = <String, dynamic>{
      'condition': ?condition,
      'severity': ?severity,
      'summary': ?summary,
      'progress': ?progress,
      'estimated_recovery': ?estimatedRecovery,
      'is_active': ?isActive,
      'do_list': ?doList,
      'dont_list': ?dontList,
      'signs_of_improvement': ?signsOfImprovement,
    };
    await _client.patch('/recovery-plan/$id', body: body);
  }

  @override
  Future<void> deleteRecoveryPlan(int id) async {
    await _client.delete('/recovery-plan/$id');
  }

  @override
  Future<void> updateRecoveryStep(
    int planId,
    int stepId, {
    String? title,
    String? description,
    int? iconCodePoint,
    bool? completed,
    int? stepOrder,
  }) async {
    final body = <String, dynamic>{
      'title': ?title,
      'description': ?description,
      'icon_code_point': ?iconCodePoint,
      'completed': ?completed,
      'step_order': ?stepOrder,
    };
    await _client.patch('/recovery-plan/$planId/step/$stepId', body: body);
  }

  @override
  Future<RecoveryStepPhoto> uploadStepPhoto(
    int planId,
    int stepId,
    File photo,
  ) async {
    final json = await _client.postMultipart(
      '/recovery-plan/$planId/step/$stepId/photo',
      file: photo,
    ) as Map<String, dynamic>;

    return RecoveryStepPhoto(
      (b) => b
        ..id = json['id'] as int
        ..recoveryStepId = json['recovery_step_id'] as int
        ..imageUrl = json['image_url'] as String
        ..createdAt = _parseDate(json['created_at']) ?? DateTime.now(),
    );
  }

  RecoveryPlan _mapPlan(
    Map<String, dynamic> json, {
    required List<RecoveryStep> steps,
  }) {
    final startedOn = _parseDate(json['started_on']);
    if (startedOn == null) {
      throw const ApiException(
        message: 'Recovery plan is missing its started_on field',
        type: ApiExceptionType.unknown,
      );
    }

    return RecoveryPlan(
      (b) => b
        ..id = json['id'] as int
        ..plantId = json['plant_id'] as int
        ..scanId = json['scan_id'] as int?
        ..condition = json['condition'] as String
        ..severity = json['severity'] as String
        ..summary = json['summary'] as String
        ..progress = ((json['progress'] as num?) ?? 0).toDouble()
        ..startedOn = startedOn
        ..estimatedRecovery = json['estimated_recovery'] as String?
        ..isActive = (json['is_active'] as bool?) ?? true
        ..doList.replace(_stringList(json['do_list']))
        ..dontList.replace(_stringList(json['dont_list']))
        ..signsOfImprovement.replace(_stringList(json['signs_of_improvement']))
        ..steps.replace(steps),
    );
  }

  RecoveryStep _mapStep(Map<String, dynamic> json) {
    final rawPhotos = json['photos'];
    final photos = rawPhotos is List
        ? rawPhotos
            .whereType<Map<String, dynamic>>()
            .map(_mapStepPhoto)
            .toList(growable: false)
        : const <RecoveryStepPhoto>[];

    return RecoveryStep(
      (b) => b
        ..id = json['id'] as int
        ..recoveryPlanId = json['recovery_plan_id'] as int
        ..title = json['title'] as String
        ..description = json['description'] as String
        ..iconCodePoint = json['icon_code_point'] as int
        ..completed = (json['completed'] as bool?) ?? false
        ..stepOrder = (json['step_order'] as int?) ?? 0
        ..photos.replace(photos),
    );
  }

  RecoveryStepPhoto _mapStepPhoto(Map<String, dynamic> json) {
    return RecoveryStepPhoto(
      (b) => b
        ..id = json['id'] as int
        ..recoveryStepId = json['recovery_step_id'] as int
        ..imageUrl = json['image_url'] as String
        ..createdAt = _parseDate(json['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _stepDraftToJson(RecoveryStepDraft step) => {
        'title': step.title,
        'description': step.description,
        'icon_code_point': step.iconCodePoint,
        'step_order': step.stepOrder,
      };

  List<String> _stringList(Object? raw) {
    if (raw is List) {
      return raw.whereType<String>().toList(growable: false);
    }
    return const [];
  }

  DateTime? _parseDate(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }
}
