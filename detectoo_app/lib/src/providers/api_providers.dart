import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/api_client.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/care_tasks_repository.dart';
import '../data/repositories/care_tasks_repository_impl.dart';
import '../data/repositories/plants_repository.dart';
import '../data/repositories/plants_repository_impl.dart';
import '../data/repositories/recovery_repository.dart';
import '../data/repositories/recovery_repository_impl.dart';
import '../data/repositories/reminders_repository.dart';
import '../data/repositories/reminders_repository_impl.dart';
import '../data/repositories/scans_repository.dart';
import '../data/repositories/scans_repository_impl.dart';
import '../data/storage/token_storage.dart';
import '../models/plant.dart';
import '../models/recovery_plan.dart';
import '../models/reminder.dart';
import '../models/scan_result.dart';
import '../models/task.dart';

/// Shared [TokenStorage] used for auth token persistence.
///
/// Override this in tests with `ProviderScope.overrides` to inject an
/// [InMemoryTokenStorage].
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return SecureTokenStorage();
});

/// Shared [ApiClient] wired up with the current [TokenStorage].
///
/// Repositories depend on this provider, never on `Dio` directly.
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return ApiClient(tokenStorage: storage);
});

/// Provides an [AuthRepository]. Override in tests to inject a fake.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    client: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

/// Provides a [PlantsRepository]. Override in tests to inject a fake.
final plantsRepositoryProvider = Provider<PlantsRepository>((ref) {
  return PlantsRepositoryImpl(client: ref.watch(apiClientProvider));
});

/// Provides a [ScansRepository]. Override in tests to inject a fake.
final scansRepositoryProvider = Provider<ScansRepository>((ref) {
  return ScansRepositoryImpl(client: ref.watch(apiClientProvider));
});

/// Provides a [RecoveryRepository]. Override in tests to inject a fake.
final recoveryRepositoryProvider = Provider<RecoveryRepository>((ref) {
  return RecoveryRepositoryImpl(client: ref.watch(apiClientProvider));
});

/// Provides a [RemindersRepository]. Override in tests to inject a fake.
final remindersRepositoryProvider = Provider<RemindersRepository>((ref) {
  return RemindersRepositoryImpl(client: ref.watch(apiClientProvider));
});

/// Provides a [CareTasksRepository]. Override in tests to inject a fake.
final careTasksRepositoryProvider = Provider<CareTasksRepository>((ref) {
  return CareTasksRepositoryImpl(client: ref.watch(apiClientProvider));
});

/// Fetches the current user's plants. Invalidate this provider after
/// create/update/delete to refresh the list.
final plantsListProvider = FutureProvider<List<Plant>>((ref) {
  return ref.watch(plantsRepositoryProvider).listPlants();
});

/// Fetches the current user's scans. Invalidate after create/update/delete.
final scansListProvider = FutureProvider<List<ScanResult>>((ref) {
  return ref.watch(scansRepositoryProvider).listScans();
});

/// Fetches the current user's active recovery plans (without steps).
final recoveryPlansProvider = FutureProvider<List<RecoveryPlan>>((ref) {
  return ref
      .watch(recoveryRepositoryProvider)
      .listRecoveryPlans(isActive: true);
});

/// Fetches the active recovery plan (with steps) for a given plant.
///
/// Returns `null` when the plant has no active recovery plan on the
/// server. The returned plan is always the newest active plan for
/// that plant.
final recoveryPlanForPlantProvider =
    FutureProvider.family<RecoveryPlan?, int>((ref, plantId) async {
  final repo = ref.watch(recoveryRepositoryProvider);
  final plans =
      await repo.listRecoveryPlans(plantId: plantId, isActive: true);
  if (plans.isEmpty) return null;
  return repo.getRecoveryPlan(plans.first.id);
});

/// Fetches the current user's reminders, ordered by time ascending.
final remindersListProvider = FutureProvider<List<Reminder>>((ref) {
  return ref.watch(remindersRepositoryProvider).listReminders();
});

/// Fetches the current user's care tasks, ordered by due_date ascending.
final careTasksListProvider = FutureProvider<List<Task>>((ref) {
  return ref.watch(careTasksRepositoryProvider).listCareTasks();
});
