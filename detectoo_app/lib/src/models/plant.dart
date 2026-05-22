import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:flutter/material.dart' hide Builder;

part 'plant.g.dart';

/// Represents a plant owned by the user.
abstract class Plant implements Built<Plant, PlantBuilder> {
  /// Server-assigned identifier used for update/delete/detail calls.
  int get id;

  /// The plant name.
  String get name;

  /// The Material icon code point for display.
  int get iconCodePoint;

  /// The health status of the plant.
  PlantHealthStatus get healthStatus;

  /// When the plant was last watered, or `null` if it hasn't been
  /// watered yet. Comes straight from the backend; format for display
  /// with [lastWateredLabel].
  DateTime? get lastWatered;

  /// URL of the photo uploaded when this plant was created.
  /// `null` for plants created without a photo.
  String? get imageUrl;

  /// Sunlight requirement: `low`, `indirect`, `bright`, or `direct`.
  String? get sunlight;

  /// Humidity preference: `low`, `medium`, or `high`.
  String? get humidity;

  /// Returns the [IconData] for this plant's icon.
  @BuiltValueField(serialize: false)
  IconData get iconData =>
      IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  /// Human-readable "time ago" label for [lastWatered].
  ///
  /// Examples: "just now", "2 hours ago", "Yesterday", "3 days ago",
  /// or "Never" when no watering has been recorded.
  @BuiltValueField(serialize: false)
  String get lastWateredLabel {
    final watered = lastWatered;
    if (watered == null) return 'Never';

    final now = DateTime.now();
    final diff = now.difference(watered);

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return m == 1 ? '1 minute ago' : '$m minutes ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return h == 1 ? '1 hour ago' : '$h hours ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) {
      final w = (diff.inDays / 7).floor();
      return w == 1 ? '1 week ago' : '$w weeks ago';
    }
    if (diff.inDays < 365) {
      final mo = (diff.inDays / 30).floor();
      return mo == 1 ? '1 month ago' : '$mo months ago';
    }
    final y = (diff.inDays / 365).floor();
    return y == 1 ? '1 year ago' : '$y years ago';
  }

  Plant._();

  factory Plant([void Function(PlantBuilder) updates]) = _$Plant;

  static Serializer<Plant> get serializer => _$plantSerializer;
}

/// Health status of a plant.
class PlantHealthStatus extends EnumClass {
  static const PlantHealthStatus healthy = _$healthy;
  static const PlantHealthStatus needsAttention = _$needsAttention;
  static const PlantHealthStatus recovering = _$recovering;

  const PlantHealthStatus._(super.name);

  static BuiltSet<PlantHealthStatus> get values => _$plantHealthStatusValues;

  static PlantHealthStatus valueOf(String name) =>
      _$plantHealthStatusValueOf(name);

  static Serializer<PlantHealthStatus> get serializer =>
      _$plantHealthStatusSerializer;
}

/// UI properties for [PlantHealthStatus].
extension PlantHealthStatusUI on PlantHealthStatus {
  /// Human-readable label for the status.
  String get label {
    switch (this) {
      case PlantHealthStatus.healthy:
        return 'Healthy';
      case PlantHealthStatus.needsAttention:
        return 'Needs Attention';
      case PlantHealthStatus.recovering:
        return 'Recovering';
    }
    return '';
  }

  /// Display color for the status.
  Color get color {
    switch (this) {
      case PlantHealthStatus.healthy:
        return const Color(0xFF2E7D32);
      case PlantHealthStatus.needsAttention:
        return const Color(0xFFE65100);
      case PlantHealthStatus.recovering:
        return const Color(0xFF1565C0);
    }
    return const Color(0xFF616161);
  }
}
