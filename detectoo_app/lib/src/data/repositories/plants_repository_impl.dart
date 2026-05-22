import 'dart:io';

import '../../models/plant.dart';
import '../../models/plant_detection.dart'
    show
        PlantDetection,
        RecoveryPlanDetection,
        RecoveryStepDetection;
import '../api/api_client.dart';
import '../api/api_exception.dart';
import 'plants_repository.dart';

/// HTTP-backed [PlantsRepository] against the FastAPI backend.
class PlantsRepositoryImpl implements PlantsRepository {
  /// Creates a [PlantsRepositoryImpl] bound to [client].
  PlantsRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<List<Plant>> listPlants({
    int page = 1,
    int itemsPerPage = 100,
  }) async {
    final json = await _client.get(
      '/plants',
      query: {'page': page, 'items_per_page': itemsPerPage},
    ) as Map<String, dynamic>;

    final items = json['data'];
    if (items is! List) {
      throw const ApiException(
        message: 'Unexpected plants list shape',
        type: ApiExceptionType.unknown,
      );
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(_mapPlant)
        .toList(growable: false);
  }

  @override
  Future<Plant> getPlant(int id) async {
    final json = await _client.get('/plant/$id') as Map<String, dynamic>;
    return _mapPlant(json);
  }

  @override
  Future<Plant> createPlant({
    required String name,
    required int iconCodePoint,
    PlantHealthStatus healthStatus = PlantHealthStatus.healthy,
    DateTime? lastWatered,
    String? imageUrl,
    String? sunlight,
    String? humidity,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'icon_code_point': iconCodePoint,
      'health_status': healthStatus.name,
      'last_watered': ?lastWatered?.toIso8601String(),
      'image_url': ?imageUrl,
      'sunlight': ?sunlight,
      'humidity': ?humidity,
    };
    final json =
        await _client.post('/plant', body: body) as Map<String, dynamic>;
    return _mapPlant(json);
  }

  @override
  Future<void> updatePlant(
    int id, {
    String? name,
    int? iconCodePoint,
    PlantHealthStatus? healthStatus,
    DateTime? lastWatered,
  }) async {
    final body = <String, dynamic>{
      'name': ?name,
      'icon_code_point': ?iconCodePoint,
      'health_status': ?healthStatus?.name,
      'last_watered': ?lastWatered?.toIso8601String(),
    };
    await _client.patch('/plant/$id', body: body);
  }

  @override
  Future<void> deletePlant(int id) async {
    await _client.delete('/plant/$id');
  }

  @override
  Future<PlantDetection> detectPlantFromPhoto(File photo) async {
    final json = await _client.postMultipart(
      '/plant/from-photo',
      file: photo,
    ) as Map<String, dynamic>;

    return PlantDetection(
      name: json['name'] as String,
      healthStatus: _parseStatus(json['health_status'] as String?),
      iconCodePoint: json['icon_code_point'] as int,
      imageUrl: json['image_url'] as String,
      sunlight: json['sunlight'] as String? ?? 'indirect',
      humidity: json['humidity'] as String? ?? 'medium',
      recoveryPlan: _parseRecoveryPlan(json['disease']),
    );
  }

  /// Maps a `PlantRead` JSON payload onto the app's [Plant] model.
  Plant _mapPlant(Map<String, dynamic> json) {
    return Plant(
      (b) => b
        ..id = json['id'] as int
        ..name = json['name'] as String
        ..iconCodePoint = json['icon_code_point'] as int
        ..healthStatus = _parseStatus(json['health_status'] as String?)
        ..lastWatered = _parseDate(json['last_watered'])
        ..imageUrl = json['image_url'] as String?
        ..sunlight = json['sunlight'] as String?
        ..humidity = json['humidity'] as String?,
    );
  }

  RecoveryPlanDetection? _parseRecoveryPlan(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final rawSteps = raw['steps'];
    final steps = rawSteps is List
        ? rawSteps
            .whereType<Map<String, dynamic>>()
            .map(
              (s) => RecoveryStepDetection(
                title: s['title'] as String? ?? '',
                description: s['description'] as String? ?? '',
                stepOrder: s['step_order'] as int? ?? 0,
              ),
            )
            .toList()
        : <RecoveryStepDetection>[];

    return RecoveryPlanDetection(
      condition: raw['condition'] as String? ?? 'Unknown Condition',
      severity: raw['severity'] as String? ?? 'Mild',
      summary: raw['summary'] as String? ?? '',
      estimatedRecovery: raw['estimated_recovery'] as String?,
      doList: _parseStringList(raw['do_list']),
      dontList: _parseStringList(raw['dont_list']),
      signsOfImprovement: _parseStringList(raw['signs_of_improvement']),
      steps: steps,
    );
  }

  List<String> _parseStringList(Object? raw) {
    if (raw is! List) return [];
    return raw.whereType<String>().toList();
  }

  PlantHealthStatus _parseStatus(String? raw) {
    if (raw == null) return PlantHealthStatus.healthy;
    try {
      return PlantHealthStatus.valueOf(raw);
    } catch (_) {
      return PlantHealthStatus.healthy;
    }
  }

  DateTime? _parseDate(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }
}
