import '../../models/task.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import 'care_tasks_repository.dart';

/// HTTP-backed [CareTasksRepository] against the FastAPI backend.
class CareTasksRepositoryImpl implements CareTasksRepository {
  /// Creates a [CareTasksRepositoryImpl] bound to [client].
  CareTasksRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<List<Task>> listCareTasks({
    int? plantId,
    bool? done,
    int page = 1,
    int itemsPerPage = 100,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'items_per_page': itemsPerPage,
      'plant_id': ?plantId,
      'done': ?done,
    };
    final json =
        await _client.get('/care-tasks', query: query) as Map<String, dynamic>;

    final items = json['data'];
    if (items is! List) {
      throw const ApiException(
        message: 'Unexpected care tasks list shape',
        type: ApiExceptionType.unknown,
      );
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(_mapTask)
        .toList(growable: false);
  }

  @override
  Future<Task> getCareTask(int id) async {
    final json = await _client.get('/care-task/$id') as Map<String, dynamic>;
    return _mapTask(json);
  }

  @override
  Future<Task> createCareTask({
    required String title,
    required DateTime dueDate,
    bool done = false,
    int? plantId,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'due_date': dueDate.toUtc().toIso8601String(),
      'done': done,
      'plant_id': ?plantId,
    };
    final json =
        await _client.post('/care-task', body: body) as Map<String, dynamic>;
    return _mapTask(json);
  }

  @override
  Future<void> updateCareTask(
    int id, {
    String? title,
    bool? done,
    DateTime? dueDate,
    int? plantId,
  }) async {
    final body = <String, dynamic>{
      'title': ?title,
      'done': ?done,
      'due_date': ?dueDate?.toUtc().toIso8601String(),
      'plant_id': ?plantId,
    };
    await _client.patch('/care-task/$id', body: body);
  }

  @override
  Future<void> deleteCareTask(int id) async {
    await _client.delete('/care-task/$id');
  }

  /// Maps a `CareTaskRead` JSON payload onto the app's [Task] model.
  Task _mapTask(Map<String, dynamic> json) {
    final dueDate = _parseDate(json['due_date']);
    if (dueDate == null) {
      throw const ApiException(
        message: 'Care task is missing its due_date field',
        type: ApiExceptionType.unknown,
      );
    }
    return Task(
      (b) => b
        ..id = json['id'] as int
        ..title = json['title'] as String
        ..done = (json['done'] as bool?) ?? false
        ..dueDate = dueDate
        ..plantId = json['plant_id'] as int?,
    );
  }

  DateTime? _parseDate(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }
}
