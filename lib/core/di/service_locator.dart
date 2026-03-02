import '../config/app_config.dart';
import '../services/staff_api_service.dart';
import '../services/staff_syn_service.dart';

/// Simple service locator — no external DI library needed.
/// Access via [ServiceLocator.staffSync] etc.
class ServiceLocator {
  ServiceLocator._();

  static StaffApiService? _staffApi;
  static StaffSyncService? _staffSync;

  static StaffApiService get staffApi {
    _staffApi ??= StaffApiService(
      baseUrl: AppConfig.apiBaseUrl,
      apiUsername: AppConfig.apiUsername,
      apiPassword: AppConfig.apiPassword,
    );
    return _staffApi!;
  }

  static StaffSyncService get staffSync {
    _staffSync ??= StaffSyncService(apiService: staffApi);
    return _staffSync!;
  }
}
