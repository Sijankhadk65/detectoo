import '../../models/scan_result.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import 'scans_repository.dart';

/// HTTP-backed [ScansRepository] against the FastAPI backend.
class ScansRepositoryImpl implements ScansRepository {
  /// Creates a [ScansRepositoryImpl] bound to [client].
  ScansRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<List<ScanResult>> listScans({
    int? plantId,
    int page = 1,
    int itemsPerPage = 100,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'items_per_page': itemsPerPage,
      'plant_id': ?plantId,
    };
    final json =
        await _client.get('/scans', query: query) as Map<String, dynamic>;

    final items = json['data'];
    if (items is! List) {
      throw const ApiException(
        message: 'Unexpected scans list shape',
        type: ApiExceptionType.unknown,
      );
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(_mapScan)
        .toList(growable: false);
  }

  @override
  Future<ScanResult> getScan(int id) async {
    final json = await _client.get('/scan/$id') as Map<String, dynamic>;
    return _mapScan(json);
  }

  @override
  Future<ScanResult> createScan({
    required String plantName,
    required String species,
    required bool isHealthy,
    List<DetectedIssue> issues = const [],
    String? imageUrl,
    int? plantId,
  }) async {
    final body = <String, dynamic>{
      'plant_name': plantName,
      'species': species,
      'is_healthy': isHealthy,
      'issues': issues.map(_issueToJson).toList(),
      'image_url': ?imageUrl,
      'plant_id': ?plantId,
    };
    final json =
        await _client.post('/scan', body: body) as Map<String, dynamic>;
    return _mapScan(json);
  }

  @override
  Future<void> updateScan(int id, {int? plantId}) async {
    final body = <String, dynamic>{
      'plant_id': ?plantId,
    };
    await _client.patch('/scan/$id', body: body);
  }

  @override
  Future<void> deleteScan(int id) async {
    await _client.delete('/scan/$id');
  }

  /// Maps a `ScanRead` JSON payload onto the app's [ScanResult] model.
  ScanResult _mapScan(Map<String, dynamic> json) {
    final rawIssues = json['issues'];
    final issues = rawIssues is List
        ? rawIssues
            .whereType<Map<String, dynamic>>()
            .map(_mapIssue)
            .toList(growable: false)
        : const <DetectedIssue>[];

    return ScanResult(
      (b) => b
        ..id = json['id'] as int
        ..plantId = json['plant_id'] as int?
        ..plantName = json['plant_name'] as String
        ..species = json['species'] as String
        ..isHealthy = (json['is_healthy'] as bool?) ?? true
        ..imageUrl = json['image_url'] as String?
        ..createdAt = _parseDate(json['created_at'])
        ..issues.replace(issues),
    );
  }

  DetectedIssue _mapIssue(Map<String, dynamic> json) {
    return DetectedIssue(
      (b) => b
        ..name = json['name'] as String
        ..description = json['description'] as String
        ..severity = json['severity'] as String
        ..confidence = (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> _issueToJson(DetectedIssue issue) => {
        'name': issue.name,
        'description': issue.description,
        'severity': issue.severity,
        'confidence': issue.confidence,
      };

  DateTime? _parseDate(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }
}
