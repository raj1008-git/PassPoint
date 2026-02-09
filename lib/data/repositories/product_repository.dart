import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/cloudinary_service.dart';
import '../../core/services/darta_number_service.dart';
import '../../core/utils/dev.log.dart';
import '../../features/product/model/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;
  final CloudinaryService _cloudinary;

  ProductRepository({
    FirebaseFirestore? firestore,
    CloudinaryService? cloudinary,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _cloudinary = cloudinary ?? CloudinaryService();

  // Create product (delivery person submission)
  Future<void> createProduct({
    required String registrationNumber,
    required DateTime registrationDate,
    required String receivedLetterNumber,
    required DateTime receivedLetterDate,
    required String senderOfficeName,
    required String subject,
    required String targetDepartmentId,
    required String targetDepartmentName,
    required String targetPersonName,
    File? productPhoto,
    String? deliveryPersonName,
    String? deliveryPersonContact,
  }) async {
    try {
      devLog(
        'Creating product',
        params: {'registrationNumber': registrationNumber, 'subject': subject},
      );

      String? photoUrl;
      if (productPhoto != null) {
        photoUrl = await _cloudinary.uploadImage(
          productPhoto,
          folder: 'pass_point/products',
        );
      }

      final id = const Uuid().v4();
      final now = Timestamp.now();

      final product = ProductModel(
        id: id,
        registrationNumber: registrationNumber,
        registrationDate: Timestamp.fromDate(registrationDate),
        receivedLetterNumber: receivedLetterNumber,
        receivedLetterDate: Timestamp.fromDate(receivedLetterDate),
        senderOfficeName: senderOfficeName,
        subject: subject,
        targetDepartmentId: targetDepartmentId,
        targetDepartmentName: targetDepartmentName,
        targetPersonName: targetPersonName,
        productPhotoUrl: photoUrl,
        deliveryPersonName: deliveryPersonName,
        deliveryPersonContact: deliveryPersonContact,
        currentStatus: 'submitted',
        createdAt: now,
        currentDepartmentId: null,
        currentDepartmentName: null,
        currentPersonName: null,
        statusHistory: [
          {
            'status': 'submitted',
            'timestamp': now,
            'action': 'Product submitted for delivery',
            'performedBy': deliveryPersonName ?? 'Delivery Person',
          },
        ],
      );

      await _firestore.collection('products').doc(id).set(product.toMap());
      devLog('Product created successfully', params: {'id': id});
    } catch (e) {
      devLog('Error creating product', params: {'error': e.toString()});
      rethrow;
    }
  }

  // Get all products stream (for receptionist)
  Stream<List<ProductModel>> getAllProductsStream() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProductModel.fromSnapshot(doc))
              .toList();
        });
  }

  // Get products assigned to staff
  Stream<List<ProductModel>> getStaffProductsStream(String staffName) {
    return _firestore
        .collection('products')
        .where('currentPersonName', isEqualTo: staffName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProductModel.fromSnapshot(doc))
              .toList();
        });
  }

  // Receptionist receives product
  Future<void> receiveByReception(
    String productId,
    String receptionistName,
  ) async {
    try {
      devLog('Reception receiving product', params: {'productId': productId});

      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) throw Exception('Product not found');

      final product = ProductModel.fromSnapshot(doc);
      final now = Timestamp.now();

      final updatedHistory = List<Map<String, dynamic>>.from(
        product.statusHistory,
      );
      updatedHistory.add({
        'status': 'received_by_reception',
        'timestamp': now,
        'action': 'Received by reception desk',
        'performedBy': receptionistName,
        'department': 'Reception',
      });

      await _firestore.collection('products').doc(productId).update({
        'currentStatus': 'received_by_reception',
        'currentDepartmentId': product.targetDepartmentId,
        'currentDepartmentName': product.targetDepartmentName,
        'currentPersonName': product.targetPersonName,
        'statusHistory': updatedHistory,
      });

      devLog('Product received by reception');
    } catch (e) {
      devLog('Error receiving product', params: {'error': e.toString()});
      rethrow;
    }
  }

  // Staff forwards product
  Future<void> forwardProduct({
    required String productId,
    required String fromStaffName,
    required String fromDepartment,
    required String toDepartmentId,
    required String toDepartmentName,
    required String toPersonName,
    required String feedback,
  }) async {
    try {
      devLog('Forwarding product', params: {'productId': productId});

      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) throw Exception('Product not found');

      final product = ProductModel.fromSnapshot(doc);
      final now = Timestamp.now();

      final updatedHistory = List<Map<String, dynamic>>.from(
        product.statusHistory,
      );
      updatedHistory.add({
        'status': 'forwarded',
        'timestamp': now,
        'action': 'Forwarded to another department',
        'performedBy': fromStaffName,
        'fromDepartment': fromDepartment,
        'toDepartment': toDepartmentName,
        'toPerson': toPersonName,
        'feedback': feedback,
      });

      await _firestore.collection('products').doc(productId).update({
        'currentStatus': 'forwarded',
        'currentDepartmentId': toDepartmentId,
        'currentDepartmentName': toDepartmentName,
        'currentPersonName': toPersonName,
        'statusHistory': updatedHistory,
      });

      devLog('Product forwarded successfully');
    } catch (e) {
      devLog('Error forwarding product', params: {'error': e.toString()});
      rethrow;
    }
  }

  // Staff completes product
  Future<void> completeProduct({
    required String productId,
    required String staffName,
    required String department,
    required String feedback,
    required String signatureUrl,
  }) async {
    try {
      devLog('Completing product', params: {'productId': productId});

      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) throw Exception('Product not found');

      final product = ProductModel.fromSnapshot(doc);
      final now = Timestamp.now();

      final updatedHistory = List<Map<String, dynamic>>.from(
        product.statusHistory,
      );
      updatedHistory.add({
        'status': 'completed',
        'timestamp': now,
        'action': 'Product received and completed',
        'performedBy': staffName,
        'department': department,
        'feedback': feedback,
        'signatureUrl': signatureUrl,
      });

      await _firestore.collection('products').doc(productId).update({
        'currentStatus': 'completed',
        'completedAt': now,
        'statusHistory': updatedHistory,
      });

      devLog('Product completed successfully');
    } catch (e) {
      devLog('Error completing product', params: {'error': e.toString()});
      rethrow;
    }
  }

  // Upload signature to Cloudinary
  Future<String> uploadSignature(File signatureFile) async {
    return await _cloudinary.uploadImage(
      signatureFile,
      folder: 'pass_point/product_signatures',
    );
  }

  /// CREATE STAFF PRODUCT (NEW METHOD)
  /// Staff creates product from dashboard for inter-branch/department transfer
  /// CREATE STAFF PRODUCT (FIXED)
  Future<String> createStaffProduct({
    required String staffUid,
    required String staffName,
    required String staffBranch,
    required String? staffDepartment,
    required String receivedLetterNumber,
    required DateTime receivedLetterDate,
    required String subject,
    required String targetType,
    required String? targetBranchId,
    required String? targetBranchName,
    required String? targetDepartmentId,
    required String? targetDepartmentName,
    required String targetStaffName,
  }) async {
    try {
      devLog(
        'Creating staff product',
        params: {
          'staffName': staffName,
          'staffBranch': staffBranch,
          'targetType': targetType,
        },
      );

      final isHQStaff = staffBranch.toUpperCase() == 'KAMALADI';
      final targetIsBranch = targetType == 'branch';
      final skipReceptionist = isHQStaff && targetIsBranch;

      if (!isHQStaff && targetIsBranch) {
        throw Exception(
          'Branch-to-Branch transfer not allowed. Please route through HQ.',
        );
      }

      final dartaNumber = await DartaNumberService.generateDartaNumber(
        isHQStaff: isHQStaff,
        targetIsBranch: targetIsBranch,
      );

      final productId = _firestore.collection('products').doc().id;

      String currentStatus;
      String? currentDeptId;
      String? currentDeptName;
      String? currentPersonName;

      if (skipReceptionist) {
        currentStatus = 'forwarded';
        currentDeptId = targetBranchId;
        currentDeptName = targetBranchName;
        currentPersonName = targetStaffName;
      } else {
        currentStatus = 'submitted';
        currentDeptId = null;
        currentDeptName = null;
        currentPersonName = null;
      }

      // FIXED: Use Timestamp.now() instead of FieldValue.serverTimestamp()
      final now = Timestamp.now();

      final statusHistory = [
        {
          'status': 'submitted',
          'action': skipReceptionist
              ? 'Product registered by $staffName (HQ staff) - Direct delivery'
              : 'Product registered by $staffName (Branch staff)',
          'performedBy': staffName,
          'department': staffDepartment ?? staffBranch,
          'timestamp': now,
        },
      ];

      if (skipReceptionist) {
        statusHistory.add({
          'status': 'forwarded',
          'action':
              'Auto-forwarded to ${targetBranchName ?? 'Unknown'} - $targetStaffName',
          'performedBy': 'System (HQ→Branch direct delivery)',
          'fromDepartment': staffDepartment ?? 'KAMALADI',
          'toDepartment': targetBranchName ?? 'Unknown',
          'toPerson': targetStaffName,
          'timestamp': now,
        });
      }

      List<String> unreadByStaff = [];
      if (skipReceptionist) {
        final targetStaffDoc = await _firestore
            .collection('users')
            .where('name', isEqualTo: targetStaffName)
            .where('branchName', isEqualTo: targetBranchName)
            .limit(1)
            .get();

        if (targetStaffDoc.docs.isNotEmpty) {
          unreadByStaff.add(targetStaffDoc.docs.first.id);
        }
      }

      final productData = {
        'id': productId,
        'registrationNumber': dartaNumber,
        'registrationDate': now,
        'receivedLetterNumber': receivedLetterNumber,
        'receivedLetterDate': Timestamp.fromDate(receivedLetterDate),
        'senderOfficeName':
            '$staffBranch${staffDepartment != null ? " - $staffDepartment" : ""}',
        'subject': subject,
        'sourceType': 'staff',
        'sourceBranch': staffBranch,
        'sourceDepartment': staffDepartment,
        'createdByStaffId': staffUid,
        'skipReceptionist': skipReceptionist,
        'targetDepartmentId': targetDepartmentId ?? targetBranchId ?? '',
        'targetDepartmentName': targetDepartmentName ?? targetBranchName ?? '',
        'targetPersonName': targetStaffName,
        'targetBranch': targetIsBranch ? targetBranchName : null,
        'productPhotoUrl': null,
        'deliveryPersonName': null,
        'deliveryPersonContact': null,
        'currentStatus': currentStatus,
        'createdAt': now,
        'completedAt': null,
        'currentDepartmentId': currentDeptId,
        'currentDepartmentName': currentDeptName,
        'currentPersonName': currentPersonName,
        'statusHistory': statusHistory,
        'unreadByStaff': unreadByStaff,
      };

      await _firestore.collection('products').doc(productId).set(productData);

      devLog(
        'Staff product created successfully',
        params: {
          'productId': productId,
          'dartaNumber': dartaNumber,
          'skipReceptionist': skipReceptionist,
        },
      );

      return productId;
    } catch (e) {
      devLog('Error creating staff product', params: {'error': e.toString()});
      rethrow;
    }
  }

  /// Get staff by name and branch (helper method)
  Future<String?> getStaffUidByNameAndBranch(
    String staffName,
    String branchName,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('name', isEqualTo: staffName)
          .where('branchName', isEqualTo: branchName)
          .where('role', isEqualTo: 'staff')
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return querySnapshot.docs.first.id;
    } catch (e) {
      devLog('Error fetching staff UID', params: {'error': e.toString()});
      return null;
    }
  }

  /// Get staff by name and department (for HQ)
  Future<String?> getStaffUidByNameAndDepartment(
    String staffName,
    String departmentId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('name', isEqualTo: staffName)
          .where('departmentId', isEqualTo: departmentId)
          .where('role', isEqualTo: 'staff')
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return querySnapshot.docs.first.id;
    } catch (e) {
      devLog('Error fetching staff UID', params: {'error': e.toString()});
      return null;
    }
  }

  /// Get staff members by branch (for dropdown)
  Future<List<Map<String, String>>> getStaffByBranch(String branchName) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('branchName', isEqualTo: branchName)
          .where('role', isEqualTo: 'staff')
          .where('status', isEqualTo: 'active')
          .orderBy('name')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'name': data['name'] as String,
          'branch': data['branchName'] as String,
        };
      }).toList();
    } catch (e) {
      devLog('Error fetching staff by branch', params: {'error': e.toString()});
      return [];
    }
  }
  /// Get products CREATED BY staff (sent by them)
  Stream<List<ProductModel>> getSentProductsStream(String staffUid) {
    return _firestore
        .collection('products')
        .where('createdByStaffId', isEqualTo: staffUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromSnapshot(doc))
          .toList();
    });
  }

  /// Get ALL products related to staff (received + sent)
  Stream<List<ProductModel>> getAllStaffProductsStream(
      String staffName,
      String staffUid,
      ) {
    // This combines products assigned to them AND created by them
    // Note: Firestore doesn't support OR queries in streams easily,
    // so we'll merge in the UI layer
    return _firestore
        .collection('products')
        .where('createdByStaffId', isEqualTo: staffUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromSnapshot(doc))
          .toList();
    });
  }
}
