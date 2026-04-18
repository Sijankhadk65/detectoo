import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:flutter/material.dart' hide Builder;

part 'reminder.g.dart';

/// Represents a plant care reminder.
abstract class Reminder implements Built<Reminder, ReminderBuilder> {
  /// Server-assigned identifier used for update/delete/detail calls.
  int get id;

  /// The reminder description.
  String get title;

  /// When the reminder is due. Comes straight from the backend;
  /// format for display with [timeLabel].
  DateTime get time;

  /// The Material icon code point for display.
  int get iconCodePoint;

  /// Optional plant this reminder is attached to.
  int? get plantId;

  /// Returns the [IconData] for this reminder's icon.
  @BuiltValueField(serialize: false)
  IconData get iconData => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  /// Human-readable "time until" label for [time].
  @BuiltValueField(serialize: false)
  String get timeLabel => _formatTime(time);

  Reminder._();

  factory Reminder([void Function(ReminderBuilder) updates]) = _$Reminder;

  static Serializer<Reminder> get serializer => _$reminderSerializer;
}

String _formatTime(DateTime date) {
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
