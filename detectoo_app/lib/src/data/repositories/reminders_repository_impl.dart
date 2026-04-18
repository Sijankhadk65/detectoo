import '../../models/reminder.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import 'reminders_repository.dart';

/// HTTP-backed [RemindersRepository] against the FastAPI backend.
class RemindersRepositoryImpl implements RemindersRepository {
  /// Creates a [RemindersRepositoryImpl] bound to [client].
  RemindersRepositoryImpl({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<List<Reminder>> listReminders({
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
        await _client.get('/reminders', query: query) as Map<String, dynamic>;

    final items = json['data'];
    if (items is! List) {
      throw const ApiException(
        message: 'Unexpected reminders list shape',
        type: ApiExceptionType.unknown,
      );
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(_mapReminder)
        .toList(growable: false);
  }

  @override
  Future<Reminder> getReminder(int id) async {
    final json = await _client.get('/reminder/$id') as Map<String, dynamic>;
    return _mapReminder(json);
  }

  @override
  Future<Reminder> createReminder({
    required String title,
    required DateTime time,
    required int iconCodePoint,
    int? plantId,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'time': time.toUtc().toIso8601String(),
      'icon_code_point': iconCodePoint,
      'plant_id': ?plantId,
    };
    final json =
        await _client.post('/reminder', body: body) as Map<String, dynamic>;
    return _mapReminder(json);
  }

  @override
  Future<void> updateReminder(
    int id, {
    String? title,
    DateTime? time,
    int? iconCodePoint,
    int? plantId,
  }) async {
    final body = <String, dynamic>{
      'title': ?title,
      'time': ?time?.toUtc().toIso8601String(),
      'icon_code_point': ?iconCodePoint,
      'plant_id': ?plantId,
    };
    await _client.patch('/reminder/$id', body: body);
  }

  @override
  Future<void> deleteReminder(int id) async {
    await _client.delete('/reminder/$id');
  }

  /// Maps a `ReminderRead` JSON payload onto the app's [Reminder] model.
  Reminder _mapReminder(Map<String, dynamic> json) {
    final time = _parseDate(json['time']);
    if (time == null) {
      throw const ApiException(
        message: 'Reminder is missing its time field',
        type: ApiExceptionType.unknown,
      );
    }
    return Reminder(
      (b) => b
        ..id = json['id'] as int
        ..title = json['title'] as String
        ..time = time
        ..iconCodePoint = json['icon_code_point'] as int
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
