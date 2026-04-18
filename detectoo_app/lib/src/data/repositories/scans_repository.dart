import '../../models/scan_result.dart';

/// Domain contract for plant scans.
///
/// Screens and providers depend on this interface, never on
/// [ApiClient] directly, so the transport can be faked in tests.
abstract class ScansRepository {
  /// Fetches a page of scans recorded by the current user.
  ///
  /// When [plantId] is provided, results are restricted to that plant.
  Future<List<ScanResult>> listScans({
    int? plantId,
    int page = 1,
    int itemsPerPage = 100,
  });

  /// Fetches a single scan by ID.
  Future<ScanResult> getScan(int id);

  /// Records a new plant scan.
  Future<ScanResult> createScan({
    required String plantName,
    required String species,
    required bool isHealthy,
    List<DetectedIssue> issues = const [],
    String? imageUrl,
    int? plantId,
  });

  /// Attaches the scan to a plant after the fact (the only mutable
  /// field on a scan).
  Future<void> updateScan(int id, {int? plantId});

  /// Soft-deletes a scan.
  Future<void> deleteScan(int id);
}
