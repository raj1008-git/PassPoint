import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/dev.log.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Stream of pending staff registrations (real-time)
  Stream<List<UserModel>> getPendingStaffStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'staff')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromSnapshot(doc))
              .toList();
        });
  }

  // Stream of active staff members (real-time)
  Stream<List<UserModel>> getActiveStaffStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'staff')
        .where('status', isEqualTo: 'active')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromSnapshot(doc))
              .toList();
        });
  }

  // Get staff by department (real-time)
  Stream<List<UserModel>> getStaffByDepartmentStream(String departmentId) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'staff')
        .where('status', isEqualTo: 'active')
        .where('departmentId', isEqualTo: departmentId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromSnapshot(doc))
              .toList();
        });
  }

  // Approve staff registration
  Future<void> approveStaff(String userId) async {
    try {
      devLog('Approving staff', params: {'userId': userId});

      await _firestore.collection('users').doc(userId).update({
        'status': 'active',
      });

      devLog('Staff approved successfully');
    } catch (e) {
      devLog('Error approving staff', params: {'error': e.toString()});
      rethrow;
    }
  }

  // Reject staff registration (delete from Firestore and optionally Firebase Auth)
  Future<void> rejectStaff(String userId) async {
    try {
      devLog('Rejecting staff', params: {'userId': userId});

      // Delete from Firestore
      await _firestore.collection('users').doc(userId).delete();

      // Optionally delete from Firebase Auth (requires admin SDK in production)
      // For now, we'll leave the auth account (they won't be able to login anyway)

      devLog('Staff rejected successfully');
    } catch (e) {
      devLog('Error rejecting staff', params: {'error': e.toString()});
      rethrow;
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      devLog('Error fetching user by ID', params: {'error': e.toString()});
      return null;
    }
  }

  // Update user
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      devLog('Updating user', params: {'userId': userId, 'updates': updates});

      await _firestore.collection('users').doc(userId).update(updates);

      devLog('User updated successfully');
    } catch (e) {
      devLog('Error updating user', params: {'error': e.toString()});
      rethrow;
    }
  }

  // Get all staff (active only)
  Future<List<UserModel>> getActiveStaff() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'staff')
          .where('status', isEqualTo: 'active')
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
    } catch (e) {
      devLog('Error fetching active staff', params: {'error': e.toString()});
      rethrow;
    }
  }

  // Get staff names by department for "Person to Meet" dropdown
  Future<List<String>> getStaffNamesByDepartment(String departmentId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'staff')
          .where('status', isEqualTo: 'active')
          .where('departmentId', isEqualTo: departmentId)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => (doc.data()['name'] as String?) ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
    } catch (e) {
      devLog('Error fetching staff names', params: {'error': e.toString()});
      return [];
    }
  }
  // ADD THESE METHODS TO YOUR EXISTING UserRepository CLASS:

  /// Get staff by branch (for branch filtering)
  Stream<List<UserModel>> getStaffByBranchStream(String branchId) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'staff')
        .where('status', isEqualTo: 'active')
        .where('branchId', isEqualTo: branchId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromSnapshot(doc))
              .toList();
        });
  }

  /// Get HQ staff (for approval workflow)
  Future<List<UserModel>> getHQStaff() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'staff')
          .where('status', isEqualTo: 'active')
          .where('branchName', isEqualTo: 'KAMALADI')
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
    } catch (e) {
      devLog('Error fetching HQ staff', params: {'error': e.toString()});
      rethrow;
    }
  }

  /// Get staff by phone number (for login)
  Future<UserModel?> getStaffByPhone(String phoneNumber) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber.trim())
          .where('role', isEqualTo: 'staff')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return UserModel.fromSnapshot(snapshot.docs.first);
    } catch (e) {
      devLog('Error fetching staff by phone', params: {'error': e.toString()});
      return null;
    }
  }
}
