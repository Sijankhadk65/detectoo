import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:flutter/material.dart' hide Builder;

part 'plant.g.dart';

/// Represents a plant owned by the user.
abstract class Plant implements Built<Plant, PlantBuilder> {
  /// The plant name.
  String get name;

  /// The Material icon code point for display.
  int get iconCodePoint;

  /// The health status of the plant.
  PlantHealthStatus get healthStatus;

  /// When the plant was last watered (e.g. "2 hours ago").
  String get lastWatered;

  /// Returns the [IconData] for this plant's icon.
  @BuiltValueField(serialize: false)
  IconData get iconData =>
      IconData(iconCodePoint, fontFamily: 'MaterialIcons');

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
