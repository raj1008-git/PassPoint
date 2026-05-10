// lib/data/repositories/employee_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/dev.log.dart';
import '../models/employee_model.dart';

class EmployeeRepository {
  final FirebaseFirestore _firestore;

  EmployeeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Internal reference helper
  // ---------------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('employees');

  // ---------------------------------------------------------------------------
  // Lookup by phone — used in add_invitee_screen auto-fill
  // Returns null if not found (triggers manual entry mode)
  // ---------------------------------------------------------------------------

  Future<EmployeeModel?> getByPhone(String phone) async {
    try {
      devLog('EmployeeRepository.getByPhone', params: {'phone': phone});

      final snapshot = await _col
          .where('mobileNo', isEqualTo: phone.trim())
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return EmployeeModel.fromSnapshot(snapshot.docs.first);
    } catch (e) {
      devLog(
        'EmployeeRepository.getByPhone error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Search by name fragment — for invitee search / autocomplete
  // Firestore prefix search: name >= query AND name < query + '\uf8ff'
  // ---------------------------------------------------------------------------

  Future<List<EmployeeModel>> searchByName(String query) async {
    try {
      devLog('EmployeeRepository.searchByName', params: {'query': query});

      final trimmed = query.trim();
      if (trimmed.isEmpty) return [];

      final snapshot = await _col
          .where('status', isEqualTo: 'active')
          .where('fullName', isGreaterThanOrEqualTo: trimmed)
          .where('fullName', isLessThanOrEqualTo: '$trimmed\uf8ff')
          .orderBy('fullName')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => EmployeeModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      devLog(
        'EmployeeRepository.searchByName error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Get all active employees — used in bulk invite flows
  // ---------------------------------------------------------------------------

  Future<List<EmployeeModel>> getAllActive() async {
    try {
      devLog('EmployeeRepository.getAllActive');

      final snapshot = await _col
          .where('status', isEqualTo: 'active')
          .orderBy('fullName')
          .get();

      return snapshot.docs
          .map((doc) => EmployeeModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      devLog(
        'EmployeeRepository.getAllActive error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Get employees by branch — for branch-filtered invite flows
  // ---------------------------------------------------------------------------

  Future<List<EmployeeModel>> getByBranch(String branchName) async {
    try {
      devLog(
        'EmployeeRepository.getByBranch',
        params: {'branchName': branchName},
      );

      final snapshot = await _col
          .where('branchName', isEqualTo: branchName)
          .where('status', isEqualTo: 'active')
          .orderBy('fullName')
          .get();

      return snapshot.docs
          .map((doc) => EmployeeModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      devLog(
        'EmployeeRepository.getByBranch error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Get single employee by rowId
  // ---------------------------------------------------------------------------

  Future<EmployeeModel?> getByRowId(String rowId) async {
    try {
      devLog('EmployeeRepository.getByRowId', params: {'rowId': rowId});

      final doc = await _col.doc(rowId).get();
      if (!doc.exists) return null;

      return EmployeeModel.fromSnapshot(doc);
    } catch (e) {
      devLog(
        'EmployeeRepository.getByRowId error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }
}