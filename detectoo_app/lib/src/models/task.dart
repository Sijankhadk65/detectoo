import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'task.g.dart';

/// Represents a plant care task/todo item.
abstract class Task implements Built<Task, TaskBuilder> {
  /// Server-assigned identifier used for update/delete/detail calls.
  int get id;

  /// The task description.
  String get title;

  /// Whether the task has been completed.
  bool get done;

  /// When the task is due. Comes straight from the backend; format
  /// for display with [dueDateLabel].
  DateTime get dueDate;

  /// Optional plant this task is attached to.
  int? get plantId;

  /// Human-readable "time until" label for [dueDate].
  ///
  /// Examples: "Today, 8:00 AM", "Tomorrow, 9:00 AM", "Wed, 3:00 PM",
  /// "Apr 20, 2026".
  @BuiltValueField(serialize: false)
  String get dueDateLabel => _formatDueDate(dueDate);

  Task._();

  factory Task([void Function(TaskBuilder) updates]) = _$Task;

  static Serializer<Task> get serializer => _$taskSerializer;
}

String _formatDueDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diff = target.difference(today).inDays;
  final hour12 = date.hour == 0
      ? 12
      : date.hour > 12
          ? date.hour - 12
          : date.hour;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour < 12 ? 'AM' : 'PM';
  final time = '$hour12:$minute $period';

  if (diff == 0) return 'Today, $time';
  if (diff == 1) return 'Tomorrow, $time';
  if (diff == -1) return 'Yesterday, $time';
  if (diff > 1 && diff < 7) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[date.weekday - 1]}, $time';
  }

  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
