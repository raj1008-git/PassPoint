// // import 'dart:developer' as DevLog;
// //
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:isar/isar.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // import '../../data/local/isar_service.dart';
// // import '../../data/local/models/staff_local_model.dart';
// // import 'staff_api_service.dart';
// //
// // class StaffSyncService {
// //   final StaffApiService _apiService;
// //   final FirebaseFirestore _firestore;
// //
// //   static const String _lastSyncKey = 'staff_last_sync_timestamp';
// //   static const Set<String> _hqBranchCodes = {'300', '301', '900'};
// //   static const Set<String> _invalidPhones = {'9800000000', '9700000000'};
// //
// //   StaffSyncService({
// //     required StaffApiService apiService,
// //     FirebaseFirestore? firestore,
// //   }) : _apiService = apiService,
// //        _firestore = firestore ?? FirebaseFirestore.instance;
// //
// //   // ---------------------------------------------------------------------------
// //   // Public API
// //   // ---------------------------------------------------------------------------
// //
// //   Future<void> syncIfNeeded() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final lastSyncMs = prefs.getInt(_lastSyncKey);
// //
// //     if (lastSyncMs == null) {
// //       DevLog.log('StaffSyncService: First install, syncing now...');
// //       await _performSync(prefs);
// //       return;
// //     }
// //
// //     final now = _nowNPT();
// //     final todayAt7PM = DateTime(now.year, now.month, now.day, 19, 0, 0);
// //     final lastSyncNPT = _toNPT(DateTime.fromMillisecondsSinceEpoch(lastSyncMs));
// //
// //     final alreadySyncedToday =
// //         lastSyncNPT.year == now.year &&
// //         lastSyncNPT.month == now.month &&
// //         lastSyncNPT.day == now.day &&
// //         lastSyncNPT.hour >= 19;
// //
// //     if (!alreadySyncedToday && now.isAfter(todayAt7PM)) {
// //       DevLog.log('StaffSyncService: Past 7 PM NPT, syncing...');
// //       await _performSync(prefs);
// //     } else {
// //       DevLog.log('StaffSyncService: Sync not needed. Last sync: $lastSyncNPT');
// //     }
// //   }
// //
// //   Future<SyncResult> forceSync() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     return await _performSync(prefs);
// //   }
// //
// //   Future<StaffLocalModel?> findByPhone(String phone) async {
// //     final isar = IsarService.instance;
// //     return await isar.staffLocalModels
// //         .where()
// //         .phoneEqualTo(phone.trim())
// //         .findFirst();
// //   }
// //
// //   Future<int> getLocalStaffCount() async {
// //     return await IsarService.instance.staffLocalModels.count();
// //   }
// //
// //   // ---------------------------------------------------------------------------
// //   // Core sync logic
// //   // ---------------------------------------------------------------------------
// //
// //   Future<SyncResult> _performSync(SharedPreferences prefs) async {
// //     try {
// //       DevLog.log('StaffSyncService: Starting sync...');
// //
// //       // 1. Fetch from API
// //       final apiEntries = await _apiService.fetchAllStaff();
// //       DevLog.log(
// //         'StaffSyncService: Fetched ${apiEntries.length} entries from API',
// //       );
// //
// //       // 2. Filter
// //       final filtered = _filterEntries(apiEntries);
// //       DevLog.log(
// //         'StaffSyncService: ${filtered.length} entries after filtering',
// //       );
// //
// //       // 3. Save to Isar (full replace)
// //       await _saveToIsar(filtered);
// //
// //       // 4. Update Firestore branches (safe — never overwrites existing docs)
// //       await _syncBranchesToFirestore(filtered);
// //
// //       // 5. Deactivate resigned staff in Firestore
// //       final deactivated = await _deactivateResignedStaff(filtered);
// //
// //       // 6. Save last sync time
// //       await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
// //
// //       DevLog.log('StaffSyncService: Sync complete. Deactivated: $deactivated');
// //       return SyncResult(
// //         success: true,
// //         staffCount: filtered.length,
// //         deactivatedCount: deactivated,
// //       );
// //     } catch (e) {
// //       DevLog.log('StaffSyncService: Sync failed: $e');
// //       return SyncResult(success: false, error: e.toString());
// //     }
// //   }
// //
// //   // ---------------------------------------------------------------------------
// //   // Filtering
// //   // ---------------------------------------------------------------------------
// //
// //   List<StaffApiEntry> _filterEntries(List<StaffApiEntry> entries) {
// //     return entries.where((e) {
// //       if (!e.email.toLowerCase().endsWith('@pmlil.com')) return false;
// //       final phone = e.mobileNo.trim();
// //       if (phone.isEmpty) return false;
// //       if (_invalidPhones.contains(phone)) return false;
// //       if (phone.length < 7) return false;
// //       final name = e.fullName.trim();
// //       if (name.isEmpty) return false;
// //       if (name == name.toUpperCase() && name.length <= 20) return false;
// //       return true;
// //     }).toList();
// //   }
// //
// //   // ---------------------------------------------------------------------------
// //   // Isar persistence (full replace every sync)
// //   // ---------------------------------------------------------------------------
// //
// //   Future<void> _saveToIsar(List<StaffApiEntry> entries) async {
// //     final isar = IsarService.instance;
// //     final now = DateTime.now();
// //
// //     // Deduplicate by phone — HQ entries take priority
// //     final Map<String, StaffApiEntry> byPhone = {};
// //     for (final e in entries) {
// //       if (_hqBranchCodes.contains(e.branchCode)) {
// //         byPhone[e.mobileNo.trim()] = e;
// //       }
// //     }
// //     for (final e in entries) {
// //       if (!_hqBranchCodes.contains(e.branchCode)) {
// //         byPhone.putIfAbsent(e.mobileNo.trim(), () => e);
// //       }
// //     }
// //
// //     final deduped = byPhone.values.toList();
// //     DevLog.log(
// //       'StaffSyncService: ${entries.length} → ${deduped.length} after dedup',
// //     );
// //
// //     final models = deduped.map((e) {
// //       return StaffLocalModel()
// //         ..fullName = e.fullName
// //         ..branchCode = e.branchCode
// //         ..branchName = e.branchName
// //         ..phone = e.mobileNo.trim()
// //         ..email = e.email.trim()
// //         ..address = e.address
// //         ..departmentName = e.departmentName
// //         ..provinceId = e.provinceId
// //         ..provinceName = e.provinceName
// //         ..isHQStaff = _hqBranchCodes.contains(e.branchCode)
// //         ..syncedAt = now;
// //     }).toList();
// //
// //     await isar.writeTxn(() async {
// //       await isar.staffLocalModels.clear();
// //       await isar.staffLocalModels.putAll(models);
// //     });
// //
// //     DevLog.log('StaffSyncService: Saved ${models.length} staff to Isar');
// //   }
// //
// //   // ---------------------------------------------------------------------------
// //   // Firestore branch sync (safe — never overwrites existing docs)
// //   // ---------------------------------------------------------------------------
// //
// //   Future<void> _syncBranchesToFirestore(List<StaffApiEntry> entries) async {
// //     final Map<String, StaffApiEntry> uniqueBranches = {};
// //     for (final e in entries) {
// //       if (!_hqBranchCodes.contains(e.branchCode)) {
// //         uniqueBranches.putIfAbsent(e.branchCode, () => e);
// //       }
// //     }
// //
// //     final branchesRef = _firestore.collection('branches');
// //     final chunks = _chunkMap(uniqueBranches, 400);
// //
// //     for (final chunk in chunks) {
// //       final WriteBatch batch = _firestore.batch();
// //       int writesInBatch = 0;
// //
// //       for (final entry in chunk.entries) {
// //         final branchCode = entry.key;
// //         final staff = entry.value;
// //         final docRef = branchesRef.doc(branchCode);
// //         final snap = await docRef.get();
// //         if (!snap.exists) {
// //           batch.set(docRef, {
// //             'code': branchCode,
// //             'name': staff.branchName.trim(),
// //             'isHeadquarter': false,
// //             'hasDepartments': false,
// //             'hasReceptionist': false,
// //             'createdAt': FieldValue.serverTimestamp(),
// //             'syncedFromApi': true,
// //           });
// //           writesInBatch++;
// //         }
// //       }
// //
// //       if (writesInBatch > 0) {
// //         await batch.commit();
// //         DevLog.log(
// //           'StaffSyncService: Added $writesInBatch new branches to Firestore',
// //         );
// //       }
// //     }
// //   }
// //
// //   // ---------------------------------------------------------------------------
// //   // Deactivate resigned staff
// //   // ---------------------------------------------------------------------------
// //   // Logic:
// //   //   - Get all active staff phones from the fresh API response
// //   //   - Get all Firestore users with role=staff and status=active
// //   //   - Any Firestore staff whose phone is NOT in the API → set status=inactive
// //   //   - Their Firebase Auth account and data are preserved (not deleted)
// //   //   - loginWithPhone already blocks inactive users with a clear error message
// //   // ---------------------------------------------------------------------------
// //
// //   Future<int> _deactivateResignedStaff(
// //     List<StaffApiEntry> activeEntries,
// //   ) async {
// //     // Build set of all active phones from API (already filtered + deduped)
// //     final activePhones = activeEntries.map((e) => e.mobileNo.trim()).toSet();
// //
// //     // Fetch all active staff from Firestore
// //     final snapshot = await _firestore
// //         .collection('users')
// //         .where('role', isEqualTo: 'staff')
// //         .where('status', isEqualTo: 'active')
// //         .get();
// //
// //     if (snapshot.docs.isEmpty) return 0;
// //
// //     final WriteBatch batch = _firestore.batch();
// //     int deactivated = 0;
// //
// //     for (final doc in snapshot.docs) {
// //       final data = doc.data();
// //       final phone = (data['phoneNumber'] as String? ?? '').trim();
// //
// //       // Skip if no phone stored (manually registered staff with no phone)
// //       if (phone.isEmpty) continue;
// //
// //       // If phone not in active API list → resigned → deactivate
// //       if (!activePhones.contains(phone)) {
// //         batch.update(doc.reference, {'status': 'inactive'});
// //         deactivated++;
// //         DevLog.log('StaffSyncService: Deactivating ${data['name']} ($phone)');
// //       }
// //     }
// //
// //     if (deactivated > 0) {
// //       await batch.commit();
// //       DevLog.log('StaffSyncService: Deactivated $deactivated resigned staff');
// //     } else {
// //       DevLog.log('StaffSyncService: No resigned staff found');
// //     }
// //
// //     return deactivated;
// //   }
// //
// //   // ---------------------------------------------------------------------------
// //   // Helpers
// //   // ---------------------------------------------------------------------------
// //
// //   static const Duration _nptOffset = Duration(hours: 5, minutes: 45);
// //   DateTime _nowNPT() => DateTime.now().toUtc().add(_nptOffset);
// //   DateTime _toNPT(DateTime utc) => utc.toUtc().add(_nptOffset);
// //
// //   List<Map<K, V>> _chunkMap<K, V>(Map<K, V> map, int size) {
// //     final result = <Map<K, V>>[];
// //     final entries = map.entries.toList();
// //     for (int i = 0; i < entries.length; i += size) {
// //       final end = (i + size < entries.length) ? i + size : entries.length;
// //       result.add(Map.fromEntries(entries.sublist(i, end)));
// //     }
// //     return result;
// //   }
// // }
// //
// // // ---------------------------------------------------------------------------
// // // Result model
// // // ---------------------------------------------------------------------------
// //
// // class SyncResult {
// //   final bool success;
// //   final int staffCount;
// //   final int deactivatedCount;
// //   final String? error;
// //
// //   const SyncResult({
// //     required this.success,
// //     this.staffCount = 0,
// //     this.deactivatedCount = 0,
// //     this.error,
// //   });
// //
// //   @override
// //   String toString() =>
// //       'SyncResult(success: $success, staffCount: $staffCount, '
// //       'deactivated: $deactivatedCount, error: $error)';
// // }
// import 'dart:developer' as DevLog;
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:isar/isar.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../data/local/isar_service.dart';
// import '../../data/local/models/staff_local_model.dart';
// import 'staff_api_service.dart';
//
// class StaffSyncService {
//   final StaffApiService _apiService;
//   final FirebaseFirestore _firestore;
//
//   static const String _lastSyncKey = 'staff_last_sync_timestamp';
//   static const Set<String> _hqBranchCodes = {'300', '301', '900'};
//   static const Set<String> _invalidPhones = {'9800000000', '9700000000'};
//
//   StaffSyncService({
//     required StaffApiService apiService,
//     FirebaseFirestore? firestore,
//   }) : _apiService = apiService,
//        _firestore = firestore ?? FirebaseFirestore.instance;
//
//   // ---------------------------------------------------------------------------
//   // Public API
//   // ---------------------------------------------------------------------------
//
//   Future<void> syncIfNeeded() async {
//     final prefs = await SharedPreferences.getInstance();
//     final lastSyncMs = prefs.getInt(_lastSyncKey);
//
//     if (lastSyncMs == null) {
//       DevLog.log('StaffSyncService: First install, syncing now...');
//       await _performSync(prefs);
//       return;
//     }
//
//     final now = _nowNPT();
//     final todayAt7PM = DateTime(now.year, now.month, now.day, 19, 0, 0);
//     final lastSyncNPT = _toNPT(DateTime.fromMillisecondsSinceEpoch(lastSyncMs));
//
//     final alreadySyncedToday =
//         lastSyncNPT.year == now.year &&
//         lastSyncNPT.month == now.month &&
//         lastSyncNPT.day == now.day &&
//         lastSyncNPT.hour >= 19;
//
//     if (!alreadySyncedToday && now.isAfter(todayAt7PM)) {
//       DevLog.log('StaffSyncService: Past 7 PM NPT, syncing...');
//       await _performSync(prefs);
//     } else {
//       DevLog.log('StaffSyncService: Sync not needed. Last sync: $lastSyncNPT');
//     }
//   }
//
//   /// Force a full sync regardless of schedule.
//   /// Called by the manual "Sync Staff Data" button on StaffAuthScreen.
//   Future<SyncResult> forceSync() async {
//     final prefs = await SharedPreferences.getInstance();
//     return await _performSync(prefs);
//   }
//
//   /// Look up a staff member by phone in local Isar DB.
//   Future<StaffLocalModel?> findByPhone(String phone) async {
//     final isar = IsarService.instance;
//     return await isar.staffLocalModels
//         .where()
//         .phoneEqualTo(phone.trim())
//         .findFirst();
//   }
//
//   /// Returns total count of staff stored in local Isar DB.
//   Future<int> getLocalStaffCount() async {
//     return await IsarService.instance.staffLocalModels.count();
//   }
//
//   // ---------------------------------------------------------------------------
//   // Core sync logic
//   // ---------------------------------------------------------------------------
//
//   Future<SyncResult> _performSync(SharedPreferences prefs) async {
//     try {
//       DevLog.log('StaffSyncService: Starting sync...');
//
//       // 1. Fetch from API
//       final apiEntries = await _apiService.fetchAllStaff();
//       DevLog.log(
//         'StaffSyncService: Fetched ${apiEntries.length} entries from API',
//       );
//
//       // 2. Filter
//       final filtered = _filterEntries(apiEntries);
//       DevLog.log(
//         'StaffSyncService: ${filtered.length} entries after filtering',
//       );
//
//       // 3. Save to Isar (full replace)
//       await _saveToIsar(filtered);
//
//       // 4. Update Firestore branches (safe — never overwrites existing docs)
//       await _syncBranchesToFirestore(filtered);
//
//       // 5. Save last sync time
//       await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
//
//       // NOTE: Resigned staff deactivation is handled by a Firebase Cloud Function
//       // (deactivateResignedStaff) that runs daily at 7:15 PM NPT on Firebase servers.
//       // It is NOT done here to avoid Firestore permission issues from the client.
//
//       DevLog.log('StaffSyncService: Sync complete.');
//       return SyncResult(success: true, staffCount: filtered.length);
//     } catch (e) {
//       DevLog.log('StaffSyncService: Sync failed: $e');
//       return SyncResult(success: false, error: e.toString());
//     }
//   }
//
//   // ---------------------------------------------------------------------------
//   // Filtering
//   // ---------------------------------------------------------------------------
//
//   List<StaffApiEntry> _filterEntries(List<StaffApiEntry> entries) {
//     return entries.where((e) {
//       if (!e.email.toLowerCase().endsWith('@pmlil.com')) return false;
//       final phone = e.mobileNo.trim();
//       if (phone.isEmpty) return false;
//       if (_invalidPhones.contains(phone)) return false;
//       if (phone.length < 7) return false;
//       final name = e.fullName.trim();
//       if (name.isEmpty) return false;
//       if (name == name.toUpperCase() && name.length <= 20) return false;
//       return true;
//     }).toList();
//   }
//
//   // ---------------------------------------------------------------------------
//   // Isar persistence (full replace every sync)
//   // ---------------------------------------------------------------------------
//
//   Future<void> _saveToIsar(List<StaffApiEntry> entries) async {
//     final isar = IsarService.instance;
//     final now = DateTime.now();
//
//     // Deduplicate by phone — HQ entries (300/301/900) take priority
//     final Map<String, StaffApiEntry> byPhone = {};
//     for (final e in entries) {
//       if (_hqBranchCodes.contains(e.branchCode)) {
//         byPhone[e.mobileNo.trim()] = e;
//       }
//     }
//     for (final e in entries) {
//       if (!_hqBranchCodes.contains(e.branchCode)) {
//         byPhone.putIfAbsent(e.mobileNo.trim(), () => e);
//       }
//     }
//
//     final deduped = byPhone.values.toList();
//     DevLog.log(
//       'StaffSyncService: ${entries.length} → ${deduped.length} after dedup',
//     );
//
//     final models = deduped.map((e) {
//       return StaffLocalModel()
//         ..fullName = e.fullName
//         ..branchCode = e.branchCode
//         ..branchName = e.branchName
//         ..phone = e.mobileNo.trim()
//         ..email = e.email.trim()
//         ..address = e.address
//         ..departmentName = e.departmentName
//         ..provinceId = e.provinceId
//         ..provinceName = e.provinceName
//         ..isHQStaff = _hqBranchCodes.contains(e.branchCode)
//         ..syncedAt = now;
//     }).toList();
//
//     await isar.writeTxn(() async {
//       await isar.staffLocalModels.clear();
//       await isar.staffLocalModels.putAll(models);
//     });
//
//     DevLog.log('StaffSyncService: Saved ${models.length} staff to Isar');
//   }
//
//   // ---------------------------------------------------------------------------
//   // Firestore branch sync (safe — never overwrites existing docs)
//   // ---------------------------------------------------------------------------
//
//   Future<void> _syncBranchesToFirestore(List<StaffApiEntry> entries) async {
//     final Map<String, StaffApiEntry> uniqueBranches = {};
//     for (final e in entries) {
//       if (!_hqBranchCodes.contains(e.branchCode)) {
//         uniqueBranches.putIfAbsent(e.branchCode, () => e);
//       }
//     }
//
//     final branchesRef = _firestore.collection('branches');
//     final chunks = _chunkMap(uniqueBranches, 400);
//
//     for (final chunk in chunks) {
//       final WriteBatch batch = _firestore.batch();
//       int writesInBatch = 0;
//
//       for (final entry in chunk.entries) {
//         final branchCode = entry.key;
//         final staff = entry.value;
//         final docRef = branchesRef.doc(branchCode);
//         final snap = await docRef.get();
//         if (!snap.exists) {
//           batch.set(docRef, {
//             'code': branchCode,
//             'name': staff.branchName.trim(),
//             'isHeadquarter': false,
//             'hasDepartments': false,
//             'hasReceptionist': false,
//             'createdAt': FieldValue.serverTimestamp(),
//             'syncedFromApi': true,
//           });
//           writesInBatch++;
//         }
//       }
//
//       if (writesInBatch > 0) {
//         await batch.commit();
//         DevLog.log(
//           'StaffSyncService: Added $writesInBatch new branches to Firestore',
//         );
//       }
//     }
//   }
//
//   // ---------------------------------------------------------------------------
//   // Helpers
//   // ---------------------------------------------------------------------------
//
//   static const Duration _nptOffset = Duration(hours: 5, minutes: 45);
//   DateTime _nowNPT() => DateTime.now().toUtc().add(_nptOffset);
//   DateTime _toNPT(DateTime utc) => utc.toUtc().add(_nptOffset);
//
//   List<Map<K, V>> _chunkMap<K, V>(Map<K, V> map, int size) {
//     final result = <Map<K, V>>[];
//     final entries = map.entries.toList();
//     for (int i = 0; i < entries.length; i += size) {
//       final end = (i + size < entries.length) ? i + size : entries.length;
//       result.add(Map.fromEntries(entries.sublist(i, end)));
//     }
//     return result;
//   }
// }
//
// // ---------------------------------------------------------------------------
// // Result model
// // ---------------------------------------------------------------------------
//
// class SyncResult {
//   final bool success;
//   final int staffCount;
//   final String? error;
//
//   const SyncResult({required this.success, this.staffCount = 0, this.error});
//
//   @override
//   String toString() =>
//       'SyncResult(success: $success, staffCount: $staffCount, error: $error)';
// }
import 'dart:developer' as DevLog;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local/isar_service.dart';
import '../../data/local/models/staff_local_model.dart';
import 'staff_api_service.dart';

class StaffSyncService {
  final StaffApiService _apiService;
  final FirebaseFirestore _firestore;

  static const String _lastSyncKey = 'staff_last_sync_timestamp';
  static const Set<String> _hqBranchCodes = {'300', '301', '900'};
  static const Set<String> _invalidPhones = {'9800000000', '9700000000'};

  StaffSyncService({
    required StaffApiService apiService,
    FirebaseFirestore? firestore,
  }) : _apiService = apiService,
       _firestore = firestore ?? FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  Future<void> syncIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncMs = prefs.getInt(_lastSyncKey);

    if (lastSyncMs == null) {
      DevLog.log('StaffSyncService: First install, syncing now...');
      await _performSync(prefs);
      return;
    }

    final now = _nowNPT();
    final todayAt7PM = DateTime(now.year, now.month, now.day, 19, 0, 0);
    final lastSyncNPT = _toNPT(DateTime.fromMillisecondsSinceEpoch(lastSyncMs));

    final alreadySyncedToday =
        lastSyncNPT.year == now.year &&
        lastSyncNPT.month == now.month &&
        lastSyncNPT.day == now.day &&
        lastSyncNPT.hour >= 19;

    if (!alreadySyncedToday && now.isAfter(todayAt7PM)) {
      DevLog.log('StaffSyncService: Past 7 PM NPT, syncing...');
      await _performSync(prefs);
    } else {
      DevLog.log('StaffSyncService: Sync not needed. Last sync: $lastSyncNPT');
    }
  }

  /// Force a full sync regardless of schedule.
  /// Called by the manual "Sync Staff Data" button on StaffAuthScreen.
  Future<SyncResult> forceSync() async {
    final prefs = await SharedPreferences.getInstance();
    return await _performSync(prefs);
  }

  /// Look up a staff member by phone in local Isar DB.
  Future<StaffLocalModel?> findByPhone(String phone) async {
    final isar = IsarService.instance;
    return await isar.staffLocalModels
        .where()
        .phoneEqualTo(phone.trim())
        .findFirst();
  }

  /// Returns total count of staff stored in local Isar DB.
  Future<int> getLocalStaffCount() async {
    return await IsarService.instance.staffLocalModels.count();
  }

  // ---------------------------------------------------------------------------
  // Core sync logic
  // ---------------------------------------------------------------------------

  Future<SyncResult> _performSync(SharedPreferences prefs) async {
    try {
      DevLog.log('StaffSyncService: Starting sync...');

      // 1. Fetch from API
      final apiEntries = await _apiService.fetchAllStaff();
      DevLog.log(
        'StaffSyncService: Fetched ${apiEntries.length} entries from API',
      );

      // 2. Filter
      final filtered = _filterEntries(apiEntries);
      DevLog.log(
        'StaffSyncService: ${filtered.length} entries after filtering',
      );

      // 3. Save to Isar (full replace)
      await _saveToIsar(filtered);

      // 4. Update Firestore branches (safe — never overwrites existing docs)
      await _syncBranchesToFirestore(filtered);

      // 5. Save last sync time
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);

      // NOTE: Resigned staff deactivation is handled by a Firebase Cloud Function
      // (deactivateResignedStaff) that runs daily at 7:15 PM NPT on Firebase servers.
      // It is NOT done here to avoid Firestore permission issues from the client.

      DevLog.log('StaffSyncService: Sync complete.');
      return SyncResult(success: true, staffCount: filtered.length);
    } catch (e) {
      DevLog.log('StaffSyncService: Sync failed: $e');
      return SyncResult(success: false, error: e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Filtering
  // ---------------------------------------------------------------------------

  List<StaffApiEntry> _filterEntries(List<StaffApiEntry> entries) {
    return entries.where((e) {
      if (!e.email.toLowerCase().endsWith('@pmlil.com')) return false;
      final phone = e.mobileNo.trim();
      if (phone.isEmpty) return false;
      if (_invalidPhones.contains(phone)) return false;
      if (phone.length < 7) return false;
      final name = e.fullName.trim();
      if (name.isEmpty) return false;
      if (name == name.toUpperCase() && name.length <= 20) return false;
      return true;
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Isar persistence (full replace every sync)
  // ---------------------------------------------------------------------------

  Future<void> _saveToIsar(List<StaffApiEntry> entries) async {
    final isar = IsarService.instance;
    final now = DateTime.now();

    // Deduplicate by phone — HQ entries (300/301/900) take priority
    final Map<String, StaffApiEntry> byPhone = {};
    for (final e in entries) {
      if (_hqBranchCodes.contains(e.branchCode)) {
        byPhone[e.mobileNo.trim()] = e;
      }
    }
    for (final e in entries) {
      if (!_hqBranchCodes.contains(e.branchCode)) {
        byPhone.putIfAbsent(e.mobileNo.trim(), () => e);
      }
    }

    final deduped = byPhone.values.toList();
    DevLog.log(
      'StaffSyncService: ${entries.length} → ${deduped.length} after dedup',
    );

    final models = deduped.map((e) {
      return StaffLocalModel()
        ..fullName = e.fullName
        ..branchCode = e.branchCode
        ..branchName = e.branchName
        ..phone = e.mobileNo.trim()
        ..email = e.email.trim()
        ..address = e.address
        ..departmentName = e.departmentName
        ..provinceId = e.provinceId
        ..provinceName = e.provinceName
        ..isHQStaff = _hqBranchCodes.contains(e.branchCode)
        ..syncedAt = now;
    }).toList();

    await isar.writeTxn(() async {
      await isar.staffLocalModels.clear();
      await isar.staffLocalModels.putAll(models);
    });

    DevLog.log('StaffSyncService: Saved ${models.length} staff to Isar');
  }

  // ---------------------------------------------------------------------------
  // Firestore branch sync (safe — never overwrites existing docs)
  // ---------------------------------------------------------------------------

  Future<void> _syncBranchesToFirestore(List<StaffApiEntry> entries) async {
    final Map<String, StaffApiEntry> uniqueBranches = {};
    for (final e in entries) {
      if (!_hqBranchCodes.contains(e.branchCode)) {
        uniqueBranches.putIfAbsent(e.branchCode, () => e);
      }
    }

    final branchesRef = _firestore.collection('branches');
    final chunks = _chunkMap(uniqueBranches, 400);

    for (final chunk in chunks) {
      final WriteBatch batch = _firestore.batch();
      int writesInBatch = 0;

      for (final entry in chunk.entries) {
        final branchCode = entry.key;
        final staff = entry.value;
        final docRef = branchesRef.doc(branchCode);
        final snap = await docRef.get();
        if (!snap.exists) {
          batch.set(docRef, {
            'code': branchCode,
            'name': staff.branchName.trim(),
            'isHeadquarter': false,
            'hasDepartments': false,
            'hasReceptionist': false,
            'createdAt': FieldValue.serverTimestamp(),
            'syncedFromApi': true,
          });
          writesInBatch++;
        }
      }

      if (writesInBatch > 0) {
        await batch.commit();
        DevLog.log(
          'StaffSyncService: Added $writesInBatch new branches to Firestore',
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static const Duration _nptOffset = Duration(hours: 5, minutes: 45);
  DateTime _nowNPT() => DateTime.now().toUtc().add(_nptOffset);
  DateTime _toNPT(DateTime utc) => utc.toUtc().add(_nptOffset);

  List<Map<K, V>> _chunkMap<K, V>(Map<K, V> map, int size) {
    final result = <Map<K, V>>[];
    final entries = map.entries.toList();
    for (int i = 0; i < entries.length; i += size) {
      final end = (i + size < entries.length) ? i + size : entries.length;
      result.add(Map.fromEntries(entries.sublist(i, end)));
    }
    return result;
  }
}

// ---------------------------------------------------------------------------
// Result model
// ---------------------------------------------------------------------------

class SyncResult {
  final bool success;
  final int staffCount;
  final String? error;

  const SyncResult({required this.success, this.staffCount = 0, this.error});

  @override
  String toString() =>
      'SyncResult(success: $success, staffCount: $staffCount, error: $error)';
}
