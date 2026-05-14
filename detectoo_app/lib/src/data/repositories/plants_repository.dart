import 'dart:io';

import '../../models/plant.dart';

/// Domain contract for plant management.
///
/// Screens and providers depend on this interface, never on
/// [ApiClient] directly, so the transport can be faked in tests.
abstract class PlantsRepository {
  /// Fetches a page of plants owned by the current user.
  ///
  /// The backend default is 10 items per page; callers that want
  /// everything in one go can pass a larger [itemsPerPage].
  Future<List<Plant>> listPlants({
    int page = 1,
    int itemsPerPage = 100,
  });

  /// Fetches a single plant by ID.
  Future<Plant> getPlant(int id);

  /// Creates a new plant owned by the current user.
  ///
  /// [healthStatus] defaults to [PlantHealthStatus.healthy] on the
  /// server when omitted.
  Future<Plant> createPlant({
    required String name,
    required int iconCodePoint,
    PlantHealthStatus healthStatus = PlantHealthStatus.healthy,
    DateTime? lastWatered,
  });

  /// Updates mutable fields on an existing plant. Only non-null
  /// arguments are sent.
  Future<void> updatePlant(
    int id, {
    String? name,
    int? iconCodePoint,
    PlantHealthStatus? healthStatus,
    DateTime? lastWatered,
  });

  /// Soft-deletes a plant. The server marks it `is_deleted` so it
  /// stops appearing in subsequent `listPlants` results.
  Future<void> deletePlant(int id);

  /// Uploads [photo] to the backend and returns the mock plant record
  /// the server creates from it.
  Future<Plant> createPlantFromPhoto(File photo);
}
