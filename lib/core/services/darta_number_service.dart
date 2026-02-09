import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/dev.log.dart';

/// Service for generating unique Darta (Registration) Numbers
/// Uses Firestore transactions to ensure atomicity and prevent duplicates
class DartaNumberService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Counter document paths
  static const String _countersCollection = 'counters';
  static const String _hqCounterDoc = 'hq_products';
  static const String _branchCounterDoc = 'branch_products';

  /// Generate next HQ darta number (HQ-1, HQ-2, HQ-3...)
  /// Used for: HQ staff → Branch staff products
  static Future<String> generateHQDartaNumber() async {
    try {
      final counterRef = _firestore
          .collection(_countersCollection)
          .doc(_hqCounterDoc);

      // Use transaction for atomic increment
      return await _firestore.runTransaction<String>((transaction) async {
        final counterDoc = await transaction.get(counterRef);

        int currentCount = 0;
        if (counterDoc.exists) {
          currentCount = counterDoc.data()?['count'] as int? ?? 0;
        }

        // Increment counter
        final newCount = currentCount + 1;

        // Update counter document
        transaction.set(counterRef, {
          'count': newCount,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Generate darta number
        final dartaNumber = 'HQ-$newCount';
        devLog(
          'Generated HQ darta number',
          params: {'number': dartaNumber, 'count': newCount},
        );

        return dartaNumber;
      });
    } catch (e) {
      devLog(
        'Error generating HQ darta number',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  /// Generate next Branch darta number (BR-500, BR-501, BR-502...)
  /// Used for: Branch staff → HQ staff products AND Public check-ins
  static Future<String> generateBranchDartaNumber() async {
    try {
      final counterRef = _firestore
          .collection(_countersCollection)
          .doc(_branchCounterDoc);

      // Use transaction for atomic increment
      return await _firestore.runTransaction<String>((transaction) async {
        final counterDoc = await transaction.get(counterRef);

        int currentCount = 499; // Start from 500 (499 + 1)
        if (counterDoc.exists) {
          currentCount = counterDoc.data()?['count'] as int? ?? 499;
        }

        // Increment counter
        final newCount = currentCount + 1;

        // Update counter document
        transaction.set(counterRef, {
          'count': newCount,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Generate darta number
        final dartaNumber = 'BR-$newCount';
        devLog(
          'Generated Branch darta number',
          params: {'number': dartaNumber, 'count': newCount},
        );

        return dartaNumber;
      });
    } catch (e) {
      devLog(
        'Error generating Branch darta number',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  /// Generate darta number based on routing logic
  /// - HQ → Branch: Uses HQ counter (HQ-1)
  /// - Branch → HQ: Uses Branch counter (BR-500)
  /// - Public: Uses Branch counter (BR-500)
  static Future<String> generateDartaNumber({
    required bool isHQStaff,
    required bool targetIsBranch,
  }) async {
    // HQ staff sending to Branch → HQ counter
    if (isHQStaff && targetIsBranch) {
      return await generateHQDartaNumber();
    }

    // Branch staff → HQ OR Public check-in → Branch counter
    return await generateBranchDartaNumber();
  }

  /// Get current counter values (for debugging/admin)
  static Future<Map<String, int>> getCurrentCounters() async {
    try {
      final hqDoc = await _firestore
          .collection(_countersCollection)
          .doc(_hqCounterDoc)
          .get();

      final branchDoc = await _firestore
          .collection(_countersCollection)
          .doc(_branchCounterDoc)
          .get();

      return {
        'hq': hqDoc.exists ? (hqDoc.data()?['count'] as int? ?? 0) : 0,
        'branch': branchDoc.exists
            ? (branchDoc.data()?['count'] as int? ?? 499)
            : 499,
      };
    } catch (e) {
      devLog('Error fetching counters', params: {'error': e.toString()});
      return {'hq': 0, 'branch': 499};
    }
  }

  /// Initialize counters (run once during setup if needed)
  static Future<void> initializeCounters() async {
    try {
      final batch = _firestore.batch();

      // Initialize HQ counter
      final hqRef = _firestore
          .collection(_countersCollection)
          .doc(_hqCounterDoc);
      batch.set(hqRef, {
        'count': 0,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Initialize Branch counter (starting at 499, so first number is 500)
      final branchRef = _firestore
          .collection(_countersCollection)
          .doc(_branchCounterDoc);
      batch.set(branchRef, {
        'count': 499,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();
      devLog('Darta number counters initialized');
    } catch (e) {
      devLog('Error initializing counters', params: {'error': e.toString()});
      rethrow;
    }
  }
}
