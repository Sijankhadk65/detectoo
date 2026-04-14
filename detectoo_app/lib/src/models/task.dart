import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'task.g.dart';

/// Represents a plant care task/todo item.
abstract class Task implements Built<Task, TaskBuilder> {
  /// The task description.
  String get title;

  /// Whether the task has been completed.
  bool get done;

  /// When the task is due (e.g. "Today, 8:00 AM").
  String get dueDate;

  Task._();

  factory Task([void Function(TaskBuilder) updates]) = _$Task;

  static Serializer<Task> get serializer => _$taskSerializer;
}
