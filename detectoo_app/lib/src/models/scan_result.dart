/// Represents the result of a plant scan.
class ScanResult {
  final String plantName;
  final String species;
  final bool isHealthy;
  final List<DetectedIssue> issues;

  const ScanResult({
    required this.plantName,
    required this.species,
    required this.isHealthy,
    required this.issues,
  });
}

/// A single issue detected during a plant scan.
class DetectedIssue {
  final String name;
  final String description;
  final String severity;
  final double confidence;

  const DetectedIssue({
    required this.name,
    required this.description,
    required this.severity,
    required this.confidence,
  });
}
