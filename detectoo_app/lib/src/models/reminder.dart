import 'package:flutter/material.dart';

/// Represents a plant care reminder.
class Reminder {
  final String title;
  final String time;
  final IconData icon;

  const Reminder({
    required this.title,
    required this.time,
    required this.icon,
  });
}
