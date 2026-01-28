import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/dev.log.dart';
import '../models/department_model.dart';

class DepartmentRepository {
  final FirebaseFirestore _firestore;

  DepartmentRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Stream of all departments (real-time)
  Stream<List<Department>> getDepartmentsStream() {
    return _firestore.collection('departments').orderBy('name').snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) => Department.fromSnapshot(doc))
            .toList();
      },
    );
  }

  // Get all departments (one-time fetch)
  Future<List<Department>> getDepartments() async {
    try {
      final snapshot = await _firestore
          .collection('departments')
          .orderBy('name')
          .get();
      return snapshot.docs.map((doc) => Department.fromSnapshot(doc)).toList();
    } catch (e) {
      devLog('Error fetching departments', params: {'error': e.toString()});
      rethrow;
    }
  }

  // Create department
  Future<String> createDepartment(String name) async {
    try {
      devLog('Creating department', params: {'name': name});

      final docRef = await _firestore.collection('departments').add({
        'name': name.trim(),
        'createdAt': Timestamp.now(),
      });

      devLog('Department created', params: {'id': docRef.id});
      return docRef.id;
    } catch (e) {
      devLog('Error creating department', params: {'error': e.toString()});
      rethrow;
    }
  }

  // Update department
  Future<void> updateDepartment(String id, String newName) async {
    try {
      devLog('Updating department', params: {'id': id, 'newName': newName});

      await _firestore.collection('departments').doc(id).update({
        'name': newName.trim(),
      });

      devLog('Department updated successfully');
    } catch (e) {
      devLog('Error updating department', params: {'error': e.toString()});
      rethrow;
    }
  }

  // Delete department
  Future<void> deleteDepartment(String id) async {
    try {
      devLog('Deleting department', params: {'id': id});

      // Check if any staff members are assigned to this department
      final usersSnapshot = await _firestore
          .collection('users')
          .where('departmentId', isEqualTo: id)
          .limit(1)
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        throw Exception(
          'Cannot delete department. Staff members are assigned to it.',
        );
      }

      await _firestore.collection('departments').doc(id).delete();

      devLog('Department deleted successfully');
    } catch (e) {
      devLog('Error deleting department', params: {'error': e.toString()});
      rethrow;
    }
  }

  // Get department by ID
  Future<Department?> getDepartmentById(String id) async {
    try {
      final doc = await _firestore.collection('departments').doc(id).get();
      if (doc.exists) {
        return Department.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      devLog(
        'Error fetching department by ID',
        params: {'error': e.toString()},
      );
      return null;
    }
  }
}
