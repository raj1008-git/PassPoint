import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/dev.log.dart';
import '../models/branch_model.dart';

class BranchRepository {
  final FirebaseFirestore _firestore;

  BranchRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream of all branches (real-time, sorted alphabetically)
  Stream<List<BranchModel>> getBranchesStream() {
    return _firestore.collection('branches').orderBy('name').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) => BranchModel.fromSnapshot(doc)).toList();
    });
  }

  /// Get all branches (one-time fetch)
  Future<List<BranchModel>> getBranches() async {
    try {
      final snapshot = await _firestore
          .collection('branches')
          .orderBy('name')
          .get();
      return snapshot.docs.map((doc) => BranchModel.fromSnapshot(doc)).toList();
    } catch (e) {
      devLog('Error fetching branches', params: {'error': e.toString()});
      rethrow;
    }
  }

  /// Get branch by ID
  Future<BranchModel?> getBranchById(String id) async {
    try {
      final doc = await _firestore.collection('branches').doc(id).get();
      if (doc.exists) {
        return BranchModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      devLog('Error fetching branch by ID', params: {'error': e.toString()});
      return null;
    }
  }

  /// Get HQ branch (Kamaladi)
  Future<BranchModel?> getHeadquarters() async {
    try {
      final snapshot = await _firestore
          .collection('branches')
          .where('isHeadquarter', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return BranchModel.fromSnapshot(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      devLog('Error fetching HQ', params: {'error': e.toString()});
      return null;
    }
  }

  /// Search branches by name (for dropdown search)
  Future<List<BranchModel>> searchBranches(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getBranches();
      }

      final snapshot = await _firestore
          .collection('branches')
          .orderBy('name')
          .get();

      final allBranches = snapshot.docs
          .map((doc) => BranchModel.fromSnapshot(doc))
          .toList();

      // Filter locally (Firestore doesn't support case-insensitive search)
      final queryLower = query.toLowerCase();
      return allBranches
          .where(
            (branch) =>
                branch.name.toLowerCase().contains(queryLower) ||
                branch.code.toLowerCase().contains(queryLower),
          )
          .toList();
    } catch (e) {
      devLog('Error searching branches', params: {'error': e.toString()});
      return [];
    }
  }
}
