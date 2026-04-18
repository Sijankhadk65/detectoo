import '../../models/reminder.dart';

/// Domain contract for plant-care reminders.
///
/// Screens and providers depend on this interface, never on
/// [ApiClient] directly, so the transport can be faked in tests.
abstract class RemindersRepository {
  /// Fetches a page of reminders for the authenticated user.
  ///
  /// When [plantId] is provided, results are restricted to that plant.
  /// The backend orders results by `time` ascending.
  Future<List<Reminder>> listReminders({
    int? plantId,
    int page = 1,
    int itemsPerPage = 100,
  });

  /// Fetches a single reminder by ID.
  Future<Reminder> getReminder(int id);

  /// Creates a new reminder.
  Future<Reminder> createReminder({
    required String title,
    required DateTime time,
    required int iconCodePoint,
    int? plantId,
  });

  /// Updates mutable fields on an existing reminder. Only non-null
  /// arguments are sent.
  Future<void> updateReminder(
    int id, {
    String? title,
    DateTime? time,
    int? iconCodePoint,
    int? plantId,
  });

  /// Soft-deletes a reminder.
  Future<void> deleteReminder(int id);
}
