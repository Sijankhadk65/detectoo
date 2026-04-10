import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:flutter/material.dart' hide Builder;

part 'reminder.g.dart';

/// Represents a plant care reminder.
abstract class Reminder implements Built<Reminder, ReminderBuilder> {
  /// The reminder description.
  String get title;

  /// When the reminder is due (e.g. "Today, 8:00 AM").
  String get time;

  /// The Material icon code point for display.
  int get iconCodePoint;

  /// Returns the [IconData] for this reminder's icon.
  @BuiltValueField(serialize: false)
  IconData get iconData => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Reminder._();

  factory Reminder([void Function(ReminderBuilder) updates]) = _$Reminder;

  static Serializer<Reminder> get serializer => _$reminderSerializer;
}
