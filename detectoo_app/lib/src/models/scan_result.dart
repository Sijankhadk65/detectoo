import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'scan_result.g.dart';

/// Represents the result of a plant scan.
abstract class ScanResult implements Built<ScanResult, ScanResultBuilder> {
  /// Server-assigned identifier. `0` for locally-created mock results.
  int get id;

  /// The identified plant name.
  String get plantName;

  /// The scientific species name.
  String get species;

  /// Whether the plant was found to be healthy.
  bool get isHealthy;

  /// List of detected issues, if any.
  BuiltList<DetectedIssue> get issues;

  /// Optional plant this scan is linked to.
  int? get plantId;

  /// Optional URL to the captured image.
  String? get imageUrl;

  /// When this scan was recorded. Null for locally-created mock results.
  DateTime? get createdAt;

  ScanResult._();

  factory ScanResult([void Function(ScanResultBuilder) updates]) = _$ScanResult;

  static Serializer<ScanResult> get serializer => _$scanResultSerializer;
}

/// A single issue detected during a plant scan.
abstract class DetectedIssue
    implements Built<DetectedIssue, DetectedIssueBuilder> {
  /// The name of the detected issue.
  String get name;

  /// A detailed description of the issue.
  String get description;

  /// Severity level (e.g. "Mild", "Moderate", "Severe").
  String get severity;

  /// Detection confidence as a value between 0.0 and 1.0.
  double get confidence;

  DetectedIssue._();

  factory DetectedIssue([void Function(DetectedIssueBuilder) updates]) =
      _$DetectedIssue;

  static Serializer<DetectedIssue> get serializer => _$detectedIssueSerializer;
}
