import '../../models/task.dart';

/// Domain contract for plant care tasks (to-do items).
///
/// Screens and providers depend on this interface, never on
/// [ApiClient] directly, so the transport can be faked in tests.
abstract class CareTasksRepository {
  /// Fetches a page of care tasks for the authenticated user.
  ///
  /// When [plantId] is provided, results are restricted to that plant;
  /// when [done] is provided, results are filtered by completion state.
  /// The backend orders results by `due_date` ascending.
  Future<List<Task>> listCareTasks({
    int? plantId,
    bool? done,
    int page = 1,
    int itemsPerPage = 100,
  });

  /// Fetches a single care task by ID.
  Future<Task> getCareTask(int id);

  /// Creates a new care task.
  Future<Task> createCareTask({
    required String title,
    required DateTime dueDate,
    bool done = false,
    int? plantId,
  });

  /// Updates mutable fields on an existing care task. Only non-null
  /// arguments are sent.
  Future<void> updateCareTask(
    int id, {
    String? title,
    bool? done,
    DateTime? dueDate,
    int? plantId,
  });

  /// Soft-deletes a care task.
  Future<void> deleteCareTask(int id);
}
