import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'recovery.g.dart';

/// Represents the recovery status of a plant.
abstract class Recovery implements Built<Recovery, RecoveryBuilder> {
  /// The name of the plant being treated.
  String get plantName;

  /// The condition being treated.
  String get condition;

  /// Recovery progress as a value between 0.0 and 1.0.
  double get progress;

  /// Human-readable status label (e.g. "Recovering", "Treatment Started").
  String get status;

  Recovery._();

  factory Recovery([void Function(RecoveryBuilder) updates]) = _$Recovery;

  static Serializer<Recovery> get serializer => _$recoverySerializer;
}
