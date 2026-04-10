/// Represents the recovery status of a plant.
class Recovery {
  final String plantName;
  final String condition;
  final double progress;
  final String status;

  const Recovery({
    required this.plantName,
    required this.condition,
    required this.progress,
    required this.status,
  });
}
