/// Central configuration for PassPoint app.
///
/// ⚠️  IMPORTANT: Replace the placeholder values below with real credentials
/// before running. Do NOT commit real credentials to version control.
/// Consider using --dart-define or a .env approach for production.
class AppConfig {
  AppConfig._();

  // ---------------------------------------------------------------------------
  // PMLIL Staff API
  // ---------------------------------------------------------------------------

  /// Base URL of the PMLIL API (no trailing slash)
  static const String apiBaseUrl = 'https://api.pmlil.com';

  /// API auth username (from Postman collection)
  static const String apiUsername = 'PMLI_INTERNAL';

  /// API auth password (from Postman collection)
  static const String apiPassword = 'a8pP9{(992c';

  // ---------------------------------------------------------------------------
  // HQ branch codes — map to single KAMALADI Firestore document
  // ---------------------------------------------------------------------------
  static const Set<String> hqBranchCodes = {'300', '301', '900'};

  /// The Firestore document ID of the KAMALADI HQ branch
  static const String hqFirestoreDocId = 'kamaladi';

  /// The display name for KAMALADI HQ
  static const String hqBranchName = 'KAMALADI';
}
